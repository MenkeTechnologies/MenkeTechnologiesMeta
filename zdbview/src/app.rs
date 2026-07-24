//! The interactive terminal application: state, key handling, and rendering.

use anyhow::Result;
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind, KeyModifiers};
use ratatui::layout::{Constraint, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{
    Block, Borders, Cell, Clear, List, ListItem, ListState, Paragraph, Row, Table, TableState,
};
use ratatui::{DefaultTerminal, Frame};

use std::path::PathBuf;

use crate::mru::{self, Entry};
use crate::rkyv_inspect::RkyvStore;
use crate::sqlite::{RowsView, SqliteStore};
use crate::store::{Kind, Store};

/// How many rows per SQLite page.
const PAGE: i64 = 500;
/// Minimum length for an extracted rkyv string run.
const MIN_STRING: usize = 4;

/// Which pane has keyboard focus.
#[derive(PartialEq, Eq, Clone, Copy)]
enum Focus {
    Left,
    Right,
}

/// Modal input state layered over Normal browsing.
enum Mode {
    Normal,
    /// Editing a SQLite cell in place; buffer holds the pending value.
    EditCell(String),
    /// A raw SQL command line (`:`); buffer holds the statement.
    Command(String),
    /// A `/` search prompt; buffer holds the pattern being typed.
    Search(String),
    /// Confirm a destructive action (delete row).
    ConfirmDelete,
}

/// The three read-only views for a rkyv/binary file.
#[derive(PartialEq, Eq, Clone, Copy)]
enum RkyvView {
    Info,
    Strings,
    Hex,
}

pub struct App {
    store: Store,
    focus: Focus,
    mode: Mode,
    status: String,
    quit: bool,

    // SQLite state
    table_idx: usize,
    rows: Option<RowsView>,
    page_offset: i64,
    row_idx: usize,
    col_idx: usize,

    // rkyv state
    rkyv_view: RkyvView,
    strings: Vec<crate::rkyv_inspect::StringHit>,
    string_idx: usize,
    hex_row: usize,

    /// True after a lone `g`, awaiting the second `g` of a `gg` motion.
    pending_g: bool,
    /// Active search pattern (empty = no search); `n`/`N` cycle its matches.
    search: String,
}

impl App {
    pub fn new(store: Store) -> Self {
        let mut app = App {
            store,
            focus: Focus::Left,
            mode: Mode::Normal,
            status: String::new(),
            quit: false,
            table_idx: 0,
            rows: None,
            page_offset: 0,
            row_idx: 0,
            col_idx: 0,
            rkyv_view: RkyvView::Info,
            strings: Vec::new(),
            string_idx: 0,
            hex_row: 0,
            pending_g: false,
            search: String::new(),
        };
        app.init();
        app
    }

    fn init(&mut self) {
        match &self.store {
            Store::Sqlite(s) => {
                if !s.tables.is_empty() {
                    self.load_table();
                }
                self.status = "arrows/hjkl move · Tab focus · e edit · a add · d delete · : SQL · q quit".into();
            }
            Store::Rkyv(r) => {
                self.strings = r.strings(MIN_STRING);
                self.status = "1 Info · 2 Strings · 3 Hex · j/k scroll · q quit  (rkyv: read-only structural view)".into();
            }
        }
    }

    pub fn run(&mut self, terminal: &mut DefaultTerminal) -> Result<()> {
        while !self.quit {
            terminal.draw(|f| self.render(f))?;
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    self.on_key(key);
                }
            }
        }
        Ok(())
    }

    // ----- key handling -----------------------------------------------------

    fn on_key(&mut self, key: KeyEvent) {
        let code = key.code;
        // Modal input first. Snapshot the buffer into a local so no borrow of
        // `self.mode` is held across the `&mut self` dispatch call.
        enum Modal {
            Edit(String),
            Cmd(String),
            Search(String),
            Confirm,
            None,
        }
        let modal = match &self.mode {
            Mode::EditCell(buf) => Modal::Edit(buf.clone()),
            Mode::Command(buf) => Modal::Cmd(buf.clone()),
            Mode::Search(buf) => Modal::Search(buf.clone()),
            Mode::ConfirmDelete => Modal::Confirm,
            Mode::Normal => Modal::None,
        };
        match modal {
            Modal::Edit(buf) => return self.key_edit_cell(code, buf),
            Modal::Cmd(buf) => return self.key_command(code, buf),
            Modal::Search(buf) => return self.key_search(code, buf),
            Modal::Confirm => return self.key_confirm_delete(code),
            Modal::None => {}
        }

        match &self.store {
            Store::Sqlite(_) => self.key_sqlite(key),
            Store::Rkyv(_) => self.key_rkyv(key),
        }
    }

    fn key_sqlite(&mut self, key: KeyEvent) {
        let code = key.code;
        let ctrl = key.modifiers.contains(KeyModifiers::CONTROL);

        // Ctrl-f / Ctrl-b page forward / back (vim page motions).
        if ctrl {
            match code {
                KeyCode::Char('f') => self.page(PAGE),
                KeyCode::Char('b') => self.page(-PAGE),
                _ => {}
            }
            return;
        }

        // `gg` motion: a lone `g` arms, the next `g` fires. Any other key
        // disarms.
        if code == KeyCode::Char('g') {
            if self.pending_g {
                self.pending_g = false;
                self.goto_top();
            } else {
                self.pending_g = true;
            }
            return;
        }
        self.pending_g = false;

        match code {
            KeyCode::Char('G') => self.goto_bottom(),
            KeyCode::Char('/') => self.mode = Mode::Search(String::new()),
            KeyCode::Char('n') => self.search_next(true),
            KeyCode::Char('N') => self.search_next(false),
            KeyCode::Char('q') | KeyCode::Esc => self.quit = true,
            KeyCode::Tab => {
                self.focus = if self.focus == Focus::Left {
                    Focus::Right
                } else {
                    Focus::Left
                };
            }
            KeyCode::Up | KeyCode::Char('k') => match self.focus {
                Focus::Left => self.select_table(self.table_idx.wrapping_sub(1)),
                Focus::Right => self.row_idx = self.row_idx.saturating_sub(1),
            },
            KeyCode::Down | KeyCode::Char('j') => match self.focus {
                Focus::Left => self.select_table(self.table_idx + 1),
                Focus::Right => {
                    if let Some(r) = &self.rows {
                        if self.row_idx + 1 < r.rows.len() {
                            self.row_idx += 1;
                        }
                    }
                }
            },
            KeyCode::Left | KeyCode::Char('h') => {
                if self.focus == Focus::Right {
                    self.col_idx = self.col_idx.saturating_sub(1);
                }
            }
            KeyCode::Right | KeyCode::Char('l') => {
                if self.focus == Focus::Right {
                    if let Some(r) = &self.rows {
                        if self.col_idx + 1 < r.columns.len() {
                            self.col_idx += 1;
                        }
                    }
                }
            }
            KeyCode::Enter => {
                if self.focus == Focus::Left {
                    self.focus = Focus::Right;
                }
            }
            KeyCode::PageDown => self.page(PAGE),
            KeyCode::PageUp => self.page(-PAGE),
            KeyCode::Char('e') => self.begin_edit_cell(),
            KeyCode::Char('a') => self.insert_row(),
            KeyCode::Char('d') => {
                if self.focus == Focus::Right && self.current_rowid().is_some() {
                    self.mode = Mode::ConfirmDelete;
                }
            }
            KeyCode::Char(':') => self.mode = Mode::Command(String::new()),
            _ => {}
        }
    }

    fn key_rkyv(&mut self, key: KeyEvent) {
        let code = key.code;
        if code == KeyCode::Char('g') {
            if self.pending_g {
                self.pending_g = false;
                self.rkyv_goto_top();
            } else {
                self.pending_g = true;
            }
            return;
        }
        self.pending_g = false;

        match code {
            KeyCode::Char('G') => self.rkyv_goto_bottom(),
            KeyCode::Char('/') => self.mode = Mode::Search(String::new()),
            KeyCode::Char('n') => self.search_next(true),
            KeyCode::Char('N') => self.search_next(false),
            KeyCode::Char('q') | KeyCode::Esc => self.quit = true,
            KeyCode::Char('1') => self.rkyv_view = RkyvView::Info,
            KeyCode::Char('2') => self.rkyv_view = RkyvView::Strings,
            KeyCode::Char('3') => self.rkyv_view = RkyvView::Hex,
            KeyCode::Up | KeyCode::Char('k') => match self.rkyv_view {
                RkyvView::Strings => self.string_idx = self.string_idx.saturating_sub(1),
                RkyvView::Hex => self.hex_row = self.hex_row.saturating_sub(1),
                RkyvView::Info => {}
            },
            KeyCode::Down | KeyCode::Char('j') => match self.rkyv_view {
                RkyvView::Strings => {
                    if self.string_idx + 1 < self.strings.len() {
                        self.string_idx += 1;
                    }
                }
                RkyvView::Hex => self.hex_row += 1,
                RkyvView::Info => {}
            },
            KeyCode::PageDown => {
                if self.rkyv_view == RkyvView::Hex {
                    self.hex_row += 16;
                }
            }
            KeyCode::PageUp => {
                if self.rkyv_view == RkyvView::Hex {
                    self.hex_row = self.hex_row.saturating_sub(16);
                }
            }
            _ => {}
        }
    }

    fn key_edit_cell(&mut self, code: KeyCode, mut buf: String) {
        match code {
            KeyCode::Esc => self.mode = Mode::Normal,
            KeyCode::Enter => {
                self.commit_edit_cell(&buf);
                self.mode = Mode::Normal;
            }
            KeyCode::Backspace => {
                buf.pop();
                self.mode = Mode::EditCell(buf);
            }
            KeyCode::Char(c) => {
                buf.push(c);
                self.mode = Mode::EditCell(buf);
            }
            _ => {}
        }
    }

    fn key_command(&mut self, code: KeyCode, mut buf: String) {
        match code {
            KeyCode::Esc => self.mode = Mode::Normal,
            KeyCode::Enter => {
                self.run_sql(&buf);
                self.mode = Mode::Normal;
            }
            KeyCode::Backspace => {
                buf.pop();
                self.mode = Mode::Command(buf);
            }
            KeyCode::Char(c) => {
                buf.push(c);
                self.mode = Mode::Command(buf);
            }
            _ => {}
        }
    }

    fn key_search(&mut self, code: KeyCode, mut buf: String) {
        match code {
            KeyCode::Esc => self.mode = Mode::Normal,
            KeyCode::Enter => {
                self.search = buf;
                self.mode = Mode::Normal;
                self.search_next(true);
            }
            KeyCode::Backspace => {
                buf.pop();
                self.mode = Mode::Search(buf);
            }
            KeyCode::Char(c) => {
                buf.push(c);
                self.mode = Mode::Search(buf);
            }
            _ => {}
        }
    }

    fn key_confirm_delete(&mut self, code: KeyCode) {
        match code {
            KeyCode::Char('y') | KeyCode::Char('Y') => {
                self.delete_current_row();
                self.mode = Mode::Normal;
            }
            _ => self.mode = Mode::Normal,
        }
    }

    // ----- SQLite operations ------------------------------------------------

    fn sqlite(&self) -> Option<&SqliteStore> {
        match &self.store {
            Store::Sqlite(s) => Some(s),
            _ => None,
        }
    }

    fn current_table(&self) -> Option<String> {
        self.sqlite()
            .and_then(|s| s.tables.get(self.table_idx).cloned())
    }

    fn current_rowid(&self) -> Option<i64> {
        self.rows
            .as_ref()
            .and_then(|r| r.rowids.get(self.row_idx).copied().flatten())
    }

    fn select_table(&mut self, idx: usize) {
        let n = self.sqlite().map(|s| s.tables.len()).unwrap_or(0);
        if n == 0 {
            return;
        }
        self.table_idx = idx.min(n - 1);
        self.page_offset = 0;
        self.row_idx = 0;
        self.col_idx = 0;
        self.load_table();
    }

    fn load_table(&mut self) {
        let (table, res) = match (self.current_table(), self.sqlite()) {
            (Some(t), Some(s)) => {
                let r = s.rows(&t, PAGE, self.page_offset);
                (t, r)
            }
            _ => return,
        };
        match res {
            Ok(v) => {
                self.rows = Some(v);
                if self.row_idx >= self.rows.as_ref().map(|r| r.rows.len()).unwrap_or(0) {
                    self.row_idx = 0;
                }
            }
            Err(e) => self.status = format!("load {}: {}", table, e),
        }
    }

    fn page(&mut self, delta: i64) {
        if self.focus != Focus::Right {
            return;
        }
        let total = self.rows.as_ref().map(|r| r.total).unwrap_or(0);
        let next = (self.page_offset + delta).max(0);
        if next < total {
            self.page_offset = next;
            self.row_idx = 0;
            self.load_table();
        }
    }

    fn begin_edit_cell(&mut self) {
        if self.focus != Focus::Right {
            return;
        }
        let cur = self
            .rows
            .as_ref()
            .and_then(|r| r.rows.get(self.row_idx))
            .and_then(|row| row.get(self.col_idx))
            .cloned()
            .unwrap_or_default();
        if self.current_rowid().is_some() {
            self.mode = Mode::EditCell(cur);
        } else {
            self.status = "row has no rowid — cannot edit (WITHOUT ROWID table)".into();
        }
    }

    fn commit_edit_cell(&mut self, val: &str) {
        let (table, rowid, col) = match (
            self.current_table(),
            self.current_rowid(),
            self.rows.as_ref().and_then(|r| r.columns.get(self.col_idx).cloned()),
        ) {
            (Some(t), Some(rid), Some(c)) => (t, rid, c),
            _ => return,
        };
        let res = self.sqlite().unwrap().update_cell(&table, rowid, &col, val);
        match res {
            Ok(()) => {
                self.status = format!("updated {}.{}", table, col);
                self.load_table();
            }
            Err(e) => self.status = format!("update failed: {}", e),
        }
    }

    fn insert_row(&mut self) {
        let table = match self.current_table() {
            Some(t) => t,
            None => return,
        };
        match self.sqlite().unwrap().insert_blank(&table) {
            Ok(()) => {
                self.status = format!("inserted default row into {}", table);
                self.load_table();
            }
            Err(e) => self.status = format!("insert failed: {}", e),
        }
    }

    fn delete_current_row(&mut self) {
        let (table, rowid) = match (self.current_table(), self.current_rowid()) {
            (Some(t), Some(r)) => (t, r),
            _ => return,
        };
        match self.sqlite().unwrap().delete_row(&table, rowid) {
            Ok(()) => {
                self.status = format!("deleted row {} from {}", rowid, table);
                self.row_idx = self.row_idx.saturating_sub(1);
                self.load_table();
            }
            Err(e) => self.status = format!("delete failed: {}", e),
        }
    }

    fn run_sql(&mut self, sql: &str) {
        if sql.trim().is_empty() {
            return;
        }
        match self.sqlite().unwrap().exec(sql) {
            Ok(n) => {
                self.status = format!("ok, {} row(s) affected", n);
                self.load_table();
            }
            Err(e) => self.status = format!("sql error: {}", e),
        }
    }

    /// `gg` — jump to the first table (left) or first row of the first page
    /// (right).
    fn goto_top(&mut self) {
        match self.focus {
            Focus::Left => self.select_table(0),
            Focus::Right => {
                self.page_offset = 0;
                self.row_idx = 0;
                self.load_table();
            }
        }
    }

    /// `G` — jump to the last table (left) or the last row of the last page
    /// (right).
    fn goto_bottom(&mut self) {
        match self.focus {
            Focus::Left => {
                let n = self.sqlite().map(|s| s.tables.len()).unwrap_or(0);
                if n > 0 {
                    self.select_table(n - 1);
                }
            }
            Focus::Right => {
                let total = self.rows.as_ref().map(|r| r.total).unwrap_or(0);
                if total > 0 {
                    self.page_offset = ((total - 1) / PAGE) * PAGE;
                    self.load_table();
                    let last = self.rows.as_ref().map(|r| r.rows.len()).unwrap_or(0);
                    self.row_idx = last.saturating_sub(1);
                }
            }
        }
    }

    // ----- rkyv navigation --------------------------------------------------

    fn rkyv_goto_top(&mut self) {
        match self.rkyv_view {
            RkyvView::Strings => self.string_idx = 0,
            RkyvView::Hex => self.hex_row = 0,
            RkyvView::Info => {}
        }
    }

    fn rkyv_goto_bottom(&mut self) {
        match self.rkyv_view {
            RkyvView::Strings => self.string_idx = self.strings.len().saturating_sub(1),
            RkyvView::Hex => {
                let len = match &self.store {
                    Store::Rkyv(r) => r.len(),
                    _ => 0,
                };
                self.hex_row = len.saturating_sub(1) / 16;
            }
            RkyvView::Info => {}
        }
    }

    // ----- search (`/`, `n`, `N`) -------------------------------------------

    /// Move to the next (`forward`) or previous match of `self.search`.
    /// SQLite search scans the loaded page across all columns; rkyv search
    /// scans the string list or the raw bytes depending on the active view.
    fn search_next(&mut self, forward: bool) {
        if self.search.is_empty() {
            return;
        }
        match &self.store {
            Store::Sqlite(_) => self.search_sqlite(forward),
            Store::Rkyv(_) => self.search_rkyv(forward),
        }
    }

    fn search_sqlite(&mut self, forward: bool) {
        let term = self.search.to_lowercase();
        match self.focus {
            Focus::Left => {
                let tables = self.sqlite().map(|s| s.tables.clone()).unwrap_or_default();
                match find_next(tables.len(), self.table_idx, forward, |i| {
                    tables[i].to_lowercase().contains(&term)
                }) {
                    Some(i) => self.select_table(i),
                    None => self.status = format!("not found: {}", self.search),
                }
            }
            Focus::Right => {
                let n = self.rows.as_ref().map(|r| r.rows.len()).unwrap_or(0);
                let rows = match &self.rows {
                    Some(r) => &r.rows,
                    None => return,
                };
                match find_next(n, self.row_idx, forward, |i| {
                    rows[i].iter().any(|c| c.to_lowercase().contains(&term))
                }) {
                    Some(i) => {
                        self.row_idx = i;
                        self.status = format!("/{}  (row {})", self.search, i);
                    }
                    None => self.status = format!("not found on page: {}", self.search),
                }
            }
        }
    }

    fn search_rkyv(&mut self, forward: bool) {
        let term = self.search.to_lowercase();
        match self.rkyv_view {
            RkyvView::Strings => {
                match find_next(self.strings.len(), self.string_idx, forward, |i| {
                    self.strings[i].text.to_lowercase().contains(&term)
                }) {
                    Some(i) => self.string_idx = i,
                    None => self.status = format!("not found: {}", self.search),
                }
            }
            RkyvView::Hex => {
                let bytes = match &self.store {
                    Store::Rkyv(r) => r.bytes.clone(),
                    _ => return,
                };
                let cur = self.hex_row * 16;
                match find_bytes(&bytes, self.search.as_bytes(), cur, forward) {
                    Some(off) => {
                        self.hex_row = off / 16;
                        self.status = format!("/{}  (offset {:#x})", self.search, off);
                    }
                    None => self.status = format!("not found: {}", self.search),
                }
            }
            RkyvView::Info => {}
        }
    }

    // ----- rendering --------------------------------------------------------

    fn render(&mut self, f: &mut Frame) {
        let outer =
            Layout::vertical([Constraint::Min(1), Constraint::Length(1)]).split(f.area());
        match &self.store {
            Store::Sqlite(_) => self.render_sqlite(f, outer[0]),
            Store::Rkyv(_) => self.render_rkyv(f, outer[0]),
        }
        self.render_status(f, outer[1]);

        // Modal overlays.
        match &self.mode {
            Mode::EditCell(buf) => self.render_input(f, "edit cell (Enter=save, Esc=cancel)", buf),
            Mode::Command(buf) => self.render_input(f, "SQL (Enter=run, Esc=cancel)", buf),
            Mode::Search(buf) => self.render_input(f, "search / (Enter, Esc)", buf),
            Mode::ConfirmDelete => {
                self.render_input(f, "delete this row? (y = yes, any = no)", "")
            }
            Mode::Normal => {}
        }
    }

    fn render_sqlite(&self, f: &mut Frame, area: Rect) {
        let cols =
            Layout::horizontal([Constraint::Length(24), Constraint::Min(10)]).split(area);

        let s = self.sqlite().unwrap();
        // Left: table list.
        let items: Vec<ListItem> = s
            .tables
            .iter()
            .map(|t| ListItem::new(t.clone()))
            .collect();
        let mut lstate = ListState::default();
        lstate.select(Some(self.table_idx));
        let left_border = self.pane_style(Focus::Left);
        let list = List::new(items)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(left_border)
                    .title(format!(
                        " {} — tables ({}) ",
                        s.path.file_name().and_then(|n| n.to_str()).unwrap_or("db"),
                        s.tables.len()
                    )),
            )
            .highlight_style(Style::default().add_modifier(Modifier::REVERSED));
        f.render_stateful_widget(list, cols[0], &mut lstate);

        // Right: row grid.
        let title = match self.current_table() {
            Some(t) => {
                let total = self.rows.as_ref().map(|r| r.total).unwrap_or(0);
                format!(
                    " {} — rows {}..{} of {} ",
                    t,
                    self.page_offset,
                    self.page_offset + self.rows.as_ref().map(|r| r.rows.len() as i64).unwrap_or(0),
                    total
                )
            }
            None => " (no table) ".into(),
        };

        if let Some(rv) = &self.rows {
            let header = Row::new(
                rv.columns
                    .iter()
                    .enumerate()
                    .map(|(i, c)| {
                        let st = if i == self.col_idx && self.focus == Focus::Right {
                            Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)
                        } else {
                            Style::default().add_modifier(Modifier::BOLD)
                        };
                        Cell::from(c.clone()).style(st)
                    })
                    .collect::<Vec<_>>(),
            );
            let body = rv.rows.iter().map(|row| {
                Row::new(row.iter().map(|c| Cell::from(truncate(c, 40))).collect::<Vec<_>>())
            });
            let widths: Vec<Constraint> =
                rv.columns.iter().map(|_| Constraint::Length(20)).collect();
            let mut tstate = TableState::default();
            tstate.select(Some(self.row_idx));
            let table = Table::new(body, widths)
                .header(header)
                .block(
                    Block::default()
                        .borders(Borders::ALL)
                        .border_style(self.pane_style(Focus::Right))
                        .title(title),
                )
                .row_highlight_style(Style::default().add_modifier(Modifier::REVERSED));
            f.render_stateful_widget(table, cols[1], &mut tstate);
        } else {
            let p = Paragraph::new("no rows").block(
                Block::default()
                    .borders(Borders::ALL)
                    .border_style(self.pane_style(Focus::Right))
                    .title(title),
            );
            f.render_widget(p, cols[1]);
        }
    }

    fn render_rkyv(&self, f: &mut Frame, area: Rect) {
        let r = match &self.store {
            Store::Rkyv(r) => r,
            _ => return,
        };
        match self.rkyv_view {
            RkyvView::Info => self.render_rkyv_info(f, area, r),
            RkyvView::Strings => self.render_rkyv_strings(f, area),
            RkyvView::Hex => self.render_rkyv_hex(f, area, r),
        }
    }

    fn render_rkyv_info(&self, f: &mut Frame, area: Rect, r: &RkyvStore) {
        let lines = vec![
            Line::from(vec![
                Span::styled("file:    ", Style::default().fg(Color::DarkGray)),
                Span::raw(r.path.display().to_string()),
            ]),
            Line::from(vec![
                Span::styled("size:    ", Style::default().fg(Color::DarkGray)),
                Span::raw(format!("{} bytes", r.len())),
            ]),
            Line::from(vec![
                Span::styled("strings: ", Style::default().fg(Color::DarkGray)),
                Span::raw(format!("{} runs (>= {} printable bytes)", self.strings.len(), MIN_STRING)),
            ]),
            Line::from(""),
            Line::from(Span::styled(
                "rkyv archives are not self-describing: no field names or type tags",
                Style::default().fg(Color::Yellow),
            )),
            Line::from(Span::styled(
                "are stored in the format, so the schema cannot be recovered generically.",
                Style::default().fg(Color::Yellow),
            )),
            Line::from(Span::styled(
                "Views:  2 Strings (embedded text)   3 Hex (raw byte structure)",
                Style::default().fg(Color::DarkGray),
            )),
        ];
        let p = Paragraph::new(lines).block(
            Block::default()
                .borders(Borders::ALL)
                .title(" rkyv / binary — Info "),
        );
        f.render_widget(p, area);
    }

    fn render_rkyv_strings(&self, f: &mut Frame, area: Rect) {
        let items: Vec<ListItem> = self
            .strings
            .iter()
            .map(|h| {
                ListItem::new(Line::from(vec![
                    Span::styled(format!("{:08x}  ", h.offset), Style::default().fg(Color::DarkGray)),
                    Span::raw(truncate(&h.text, 200)),
                ]))
            })
            .collect();
        let mut st = ListState::default();
        st.select(Some(self.string_idx.min(self.strings.len().saturating_sub(1))));
        let list = List::new(items)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .title(format!(" Strings ({}) ", self.strings.len())),
            )
            .highlight_style(Style::default().add_modifier(Modifier::REVERSED));
        f.render_stateful_widget(list, area, &mut st);
    }

    fn render_rkyv_hex(&self, f: &mut Frame, area: Rect, r: &RkyvStore) {
        let rows_visible = area.height.saturating_sub(2) as usize;
        let start = self.hex_row * 16;
        let mut lines = Vec::new();
        for i in 0..rows_visible {
            let off = start + i * 16;
            if off >= r.len() {
                break;
            }
            lines.push(Line::from(r.hex_row(off)));
        }
        let p = Paragraph::new(lines).block(
            Block::default()
                .borders(Borders::ALL)
                .title(format!(" Hex — offset {:#x} / {} bytes ", start, r.len())),
        );
        f.render_widget(p, area);
    }

    fn render_status(&self, f: &mut Frame, area: Rect) {
        let p = Paragraph::new(self.status.clone())
            .style(Style::default().fg(Color::Black).bg(Color::Gray));
        f.render_widget(p, area);
    }

    fn render_input(&self, f: &mut Frame, title: &str, buf: &str) {
        let area = centered(f.area(), 60, 3);
        f.render_widget(Clear, area);
        let p = Paragraph::new(format!("{}_", buf)).block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Cyan))
                .title(format!(" {} ", title)),
        );
        f.render_widget(p, area);
    }

    fn pane_style(&self, which: Focus) -> Style {
        if self.focus == which {
            Style::default().fg(Color::Cyan)
        } else {
            Style::default().fg(Color::DarkGray)
        }
    }
}

/// Recent-files picker shown when zdbview is launched with no file argument.
/// Returns the chosen file, or `None` if the user quits.
pub fn pick_mru(terminal: &mut DefaultTerminal, entries: &[Entry]) -> Result<Option<PathBuf>> {
    let mut idx = 0usize;
    let mut pending_g = false;
    loop {
        terminal.draw(|f| render_picker(f, entries, idx))?;
        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            if key.code == KeyCode::Char('g') {
                if pending_g {
                    pending_g = false;
                    idx = 0;
                } else {
                    pending_g = true;
                }
                continue;
            }
            pending_g = false;
            match key.code {
                KeyCode::Char('q') | KeyCode::Esc => return Ok(None),
                KeyCode::Char('G') => idx = entries.len().saturating_sub(1),
                KeyCode::Up | KeyCode::Char('k') => idx = idx.saturating_sub(1),
                KeyCode::Down | KeyCode::Char('j') => {
                    if idx + 1 < entries.len() {
                        idx += 1;
                    }
                }
                KeyCode::Enter => {
                    if let Some(e) = entries.get(idx) {
                        return Ok(Some(e.path.clone()));
                    }
                }
                _ => {}
            }
        }
    }
}

fn render_picker(f: &mut Frame, entries: &[Entry], idx: usize) {
    let outer = Layout::vertical([Constraint::Min(1), Constraint::Length(1)]).split(f.area());

    if entries.is_empty() {
        let p = Paragraph::new(vec![
            Line::from(""),
            Line::from("  No recent files."),
            Line::from(""),
            Line::from(Span::styled(
                "  Open one with:  zdbview <file>",
                Style::default().fg(Color::DarkGray),
            )),
        ])
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(" zdbview — recent "),
        );
        f.render_widget(p, outer[0]);
    } else {
        let items: Vec<ListItem> = entries
            .iter()
            .map(|e| {
                let name = e
                    .path
                    .file_name()
                    .and_then(|n| n.to_str())
                    .unwrap_or("?");
                let dir = e
                    .path
                    .parent()
                    .and_then(|p| p.to_str())
                    .unwrap_or("");
                let (badge, color) = match e.kind {
                    Kind::Sqlite => ("sqlite", Color::Green),
                    Kind::Rkyv => ("rkyv  ", Color::Magenta),
                };
                ListItem::new(Line::from(vec![
                    Span::styled(format!(" {} ", badge), Style::default().fg(color)),
                    Span::styled(format!("{:<28}", truncate(name, 28)), Style::default().add_modifier(Modifier::BOLD)),
                    Span::styled(format!("{:>10}  ", mru::rel_age(e.opened)), Style::default().fg(Color::DarkGray)),
                    Span::styled(truncate(dir, 60), Style::default().fg(Color::DarkGray)),
                ]))
            })
            .collect();
        let mut st = ListState::default();
        st.select(Some(idx.min(entries.len().saturating_sub(1))));
        let list = List::new(items)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .title(format!(" zdbview — recent files ({}) ", entries.len())),
            )
            .highlight_style(Style::default().add_modifier(Modifier::REVERSED));
        f.render_stateful_widget(list, outer[0], &mut st);
    }

    let help = Paragraph::new("j/k move · Enter open · q quit")
        .style(Style::default().fg(Color::Black).bg(Color::Gray));
    f.render_widget(help, outer[1]);
}

/// Find the next index (wrapping) from `from` for which `pred` holds, scanning
/// `forward` or backward. Returns `None` if nothing matches.
fn find_next(len: usize, from: usize, forward: bool, pred: impl Fn(usize) -> bool) -> Option<usize> {
    if len == 0 {
        return None;
    }
    for step in 1..=len {
        let i = if forward {
            (from + step) % len
        } else {
            (from + len - (step % len)) % len
        };
        if pred(i) {
            return Some(i);
        }
    }
    None
}

/// Find the byte offset of `needle` in `hay`, searching from just past `cur`
/// (or just before it, when not `forward`). Case-sensitive. `None` if absent.
fn find_bytes(hay: &[u8], needle: &[u8], cur: usize, forward: bool) -> Option<usize> {
    if needle.is_empty() || hay.len() < needle.len() {
        return None;
    }
    let last = hay.len() - needle.len();
    if forward {
        let start = (cur + 1).min(last + 1);
        (start..=last).find(|&i| &hay[i..i + needle.len()] == needle)
    } else {
        let start = cur.min(last + 1);
        (0..start).rev().find(|&i| &hay[i..i + needle.len()] == needle)
    }
}

/// Truncate a display string to `max` chars, appending an ellipsis.
fn truncate(s: &str, max: usize) -> String {
    if s.chars().count() <= max {
        s.to_string()
    } else {
        let mut out: String = s.chars().take(max.saturating_sub(1)).collect();
        out.push('…');
        out
    }
}

/// A centered rect `w` cols wide and `h` rows tall inside `area`.
fn centered(area: Rect, w: u16, h: u16) -> Rect {
    let w = w.min(area.width);
    let h = h.min(area.height);
    Rect {
        x: area.x + (area.width - w) / 2,
        y: area.y + (area.height - h) / 2,
        width: w,
        height: h,
    }
}

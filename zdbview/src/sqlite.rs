//! SQLite backend: full generic CRUD over any database file.
//!
//! Rows are addressed by `rowid` for edit/delete, which works for every
//! ordinary table. `WITHOUT ROWID` tables lose in-place edit/delete addressing
//! (the SELECT still lists them read-only).

use anyhow::{Context, Result};
use rusqlite::types::ValueRef;
use rusqlite::{params, Connection};
use std::path::{Path, PathBuf};

pub struct SqliteStore {
    conn: Connection,
    pub path: PathBuf,
    pub tables: Vec<String>,
}

/// A page of rows for one table, stringified for display.
pub struct RowsView {
    pub columns: Vec<String>,
    pub rows: Vec<Vec<String>>,
    /// `rowid` for each row, used to target edit/delete. `None` when the table
    /// has no accessible rowid (a `WITHOUT ROWID` table).
    pub rowids: Vec<Option<i64>>,
    pub total: i64,
}

impl SqliteStore {
    pub fn open(path: &Path) -> Result<Self> {
        let conn = Connection::open(path)
            .with_context(|| format!("open sqlite {}", path.display()))?;
        let tables = list_tables(&conn)?;
        Ok(Self {
            conn,
            path: path.to_path_buf(),
            tables,
        })
    }

    pub fn count(&self, table: &str) -> Result<i64> {
        let n: i64 = self.conn.query_row(
            &format!("SELECT COUNT(*) FROM \"{}\"", esc(table)),
            [],
            |r| r.get(0),
        )?;
        Ok(n)
    }

    pub fn columns(&self, table: &str) -> Result<Vec<String>> {
        let mut stmt = self
            .conn
            .prepare(&format!("PRAGMA table_info(\"{}\")", esc(table)))?;
        let cols = stmt
            .query_map([], |r| r.get::<_, String>(1))?
            .collect::<Result<Vec<_>, _>>()?;
        Ok(cols)
    }

    /// Fetch one page of rows. Includes `rowid` for edit/delete addressing when
    /// the table exposes it.
    pub fn rows(&self, table: &str, limit: i64, offset: i64) -> Result<RowsView> {
        let columns = self.columns(table)?;
        let total = self.count(table)?;
        let ncols = columns.len();

        // Try to select rowid alongside the real columns. Falls back to a
        // plain select for WITHOUT ROWID tables where `rowid` is not a column.
        let with_rowid = self
            .conn
            .prepare(&format!(
                "SELECT rowid, * FROM \"{}\" LIMIT {} OFFSET {}",
                esc(table),
                limit,
                offset
            ))
            .is_ok();

        let sql = if with_rowid {
            format!(
                "SELECT rowid, * FROM \"{}\" LIMIT {} OFFSET {}",
                esc(table),
                limit,
                offset
            )
        } else {
            format!(
                "SELECT * FROM \"{}\" LIMIT {} OFFSET {}",
                esc(table),
                limit,
                offset
            )
        };

        let mut stmt = self.conn.prepare(&sql)?;
        let mut rows_out = Vec::new();
        let mut rowids = Vec::new();
        let mut q = stmt.query([])?;
        while let Some(row) = q.next()? {
            let (base, rid) = if with_rowid {
                (1usize, row.get::<_, i64>(0).ok())
            } else {
                (0usize, None)
            };
            rowids.push(rid);
            let mut cells = Vec::with_capacity(ncols);
            for i in 0..ncols {
                cells.push(value_to_string(row, base + i));
            }
            rows_out.push(cells);
        }

        Ok(RowsView {
            columns,
            rows: rows_out,
            rowids,
            total,
        })
    }

    pub fn update_cell(&self, table: &str, rowid: i64, col: &str, val: &str) -> Result<()> {
        self.conn.execute(
            &format!(
                "UPDATE \"{}\" SET \"{}\" = ?1 WHERE rowid = ?2",
                esc(table),
                esc(col)
            ),
            params![val, rowid],
        )?;
        Ok(())
    }

    pub fn delete_row(&self, table: &str, rowid: i64) -> Result<()> {
        self.conn.execute(
            &format!("DELETE FROM \"{}\" WHERE rowid = ?1", esc(table)),
            params![rowid],
        )?;
        Ok(())
    }

    /// Insert one row using each column's default value.
    pub fn insert_blank(&self, table: &str) -> Result<()> {
        self.conn.execute(
            &format!("INSERT INTO \"{}\" DEFAULT VALUES", esc(table)),
            [],
        )?;
        Ok(())
    }

    /// Run an arbitrary statement (the `:` command line). Returns rows affected.
    pub fn exec(&self, sql: &str) -> Result<usize> {
        Ok(self.conn.execute(sql, [])?)
    }
}

fn value_to_string(row: &rusqlite::Row, idx: usize) -> String {
    match row.get_ref(idx) {
        Ok(ValueRef::Null) => "NULL".into(),
        Ok(ValueRef::Integer(i)) => i.to_string(),
        Ok(ValueRef::Real(f)) => f.to_string(),
        Ok(ValueRef::Text(t)) => String::from_utf8_lossy(t).into_owned(),
        Ok(ValueRef::Blob(b)) => format!("<blob {} bytes>", b.len()),
        Err(_) => "?".into(),
    }
}

fn list_tables(conn: &Connection) -> Result<Vec<String>> {
    let mut stmt = conn.prepare(
        "SELECT name FROM sqlite_master \
         WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' \
         ORDER BY name",
    )?;
    let names = stmt
        .query_map([], |r| r.get::<_, String>(0))?
        .collect::<Result<Vec<_>, _>>()?;
    Ok(names)
}

/// Escape a double-quoted SQL identifier.
fn esc(ident: &str) -> String {
    ident.replace('"', "\"\"")
}

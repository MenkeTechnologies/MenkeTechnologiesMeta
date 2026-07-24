//! zdbview — terminal inspector and CRUD editor for rkyv archives and SQLite
//! databases.
//!
//! SQLite files are fully self-describing, so zdbview offers complete generic
//! CRUD: browse tables, edit any cell, insert/delete rows, run raw SQL.
//!
//! rkyv archives are NOT self-describing (the format stores no field names or
//! type tags — see https://rkyv.org/format.html). For an arbitrary archive
//! zdbview therefore provides a structural inspector: hex/ascii dump and the
//! embedded string runs. Typed field-name CRUD requires a supplied schema
//! descriptor (future work).

mod app;
mod mru;
mod rkyv_inspect;
mod sqlite;
mod store;

use anyhow::Result;
use clap::Parser;
use ratatui::DefaultTerminal;
use std::path::PathBuf;

#[derive(Parser)]
#[command(
    name = "zdbview",
    about = "Terminal inspector and CRUD editor for rkyv archives and SQLite databases"
)]
struct Cli {
    /// File to open. With no file, shows a picker of recently opened files.
    file: Option<PathBuf>,
    /// Force treating the file as a SQLite database
    #[arg(long, conflicts_with = "rkyv")]
    sqlite: bool,
    /// Force treating the file as a rkyv archive
    #[arg(long)]
    rkyv: bool,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let mut terminal = ratatui::init();
    let res = run(&cli, &mut terminal);
    ratatui::restore();
    res
}

fn run(cli: &Cli, terminal: &mut DefaultTerminal) -> Result<()> {
    // Resolve the file to open: explicit argument, or a pick from the MRU list.
    let file = match &cli.file {
        Some(f) => f.clone(),
        None => {
            let recent: Vec<mru::Entry> =
                mru::load().into_iter().filter(|e| e.path.exists()).collect();
            match app::pick_mru(terminal, &recent)? {
                Some(p) => p,
                None => return Ok(()), // user quit the picker
            }
        }
    };

    let kind = store::detect(&file, cli.sqlite, cli.rkyv)?;
    let (store, actual) = store::Store::open(&file, kind)?;
    mru::record(&file, actual);
    app::App::new(store).run(terminal)
}

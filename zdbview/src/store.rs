//! File-kind detection and the top-level store enum.

use anyhow::{Context, Result};
use std::io::Read;
use std::path::Path;

/// Which backend a file is opened with.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Kind {
    Sqlite,
    Rkyv,
}

/// The SQLite file header magic (first 16 bytes of every SQLite database).
const SQLITE_MAGIC: &[u8] = b"SQLite format 3\0";

/// Decide how to open `path`. Explicit `--sqlite`/`--rkyv` win; otherwise the
/// SQLite header magic is authoritative — its presence means SQLite, its
/// absence in a readable header means NOT SQLite (extension is ignored, because
/// e.g. zshrs stores rkyv shards under a `.db` name). The extension is only a
/// tie-breaker when the file is too short to carry a header.
pub fn detect(path: &Path, force_sqlite: bool, force_rkyv: bool) -> Result<Kind> {
    if force_sqlite {
        return Ok(Kind::Sqlite);
    }
    if force_rkyv {
        return Ok(Kind::Rkyv);
    }

    let mut buf = [0u8; 16];
    let mut f =
        std::fs::File::open(path).with_context(|| format!("open {}", path.display()))?;
    let n = f.read(&mut buf)?;

    if n >= SQLITE_MAGIC.len() {
        // Full header available: magic is the sole authority.
        return Ok(if &buf[..SQLITE_MAGIC.len()] == SQLITE_MAGIC {
            Kind::Sqlite
        } else {
            Kind::Rkyv
        });
    }

    // Too short for a SQLite header — fall back to the extension hint.
    match path.extension().and_then(|e| e.to_str()) {
        Some("db") | Some("sqlite") | Some("sqlite3") => Ok(Kind::Sqlite),
        _ => Ok(Kind::Rkyv),
    }
}

/// The opened backend, holding whichever store was selected.
pub enum Store {
    Sqlite(crate::sqlite::SqliteStore),
    Rkyv(crate::rkyv_inspect::RkyvStore),
}

impl Store {
    /// Open `path` with the detected `kind`. Returns the store and the kind
    /// actually used: if a SQLite open fails (the file only looked like a
    /// database), it falls back to the rkyv/binary inspector rather than error.
    pub fn open(path: &Path, kind: Kind) -> Result<(Self, Kind)> {
        match kind {
            Kind::Sqlite => match crate::sqlite::SqliteStore::open(path) {
                Ok(s) => Ok((Store::Sqlite(s), Kind::Sqlite)),
                Err(_) => {
                    let r = crate::rkyv_inspect::RkyvStore::open(path)?;
                    Ok((Store::Rkyv(r), Kind::Rkyv))
                }
            },
            Kind::Rkyv => {
                let r = crate::rkyv_inspect::RkyvStore::open(path)?;
                Ok((Store::Rkyv(r), Kind::Rkyv))
            }
        }
    }
}

//! Most-recently-used file tracking.
//!
//! Every successful open is recorded to `$XDG_CACHE_HOME/zdbview/recent`
//! (falling back to `~/.cache/zdbview/recent`), most-recent-first, deduped by
//! absolute path and capped. Running `zdbview` with no argument shows this list
//! as a picker.

use crate::store::Kind;
use std::path::{Path, PathBuf};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

/// Maximum number of remembered files.
const CAP: usize = 50;

pub struct Entry {
    pub path: PathBuf,
    pub kind: Kind,
    pub opened: SystemTime,
}

/// Path of the MRU store file.
fn store_file() -> PathBuf {
    let base = std::env::var_os("XDG_CACHE_HOME")
        .map(PathBuf::from)
        .or_else(|| std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".cache")))
        .unwrap_or_else(|| PathBuf::from(".cache"));
    base.join("zdbview").join("recent")
}

fn kind_str(k: Kind) -> &'static str {
    match k {
        Kind::Sqlite => "sqlite",
        Kind::Rkyv => "rkyv",
    }
}

fn parse_kind(s: &str) -> Option<Kind> {
    match s {
        "sqlite" => Some(Kind::Sqlite),
        "rkyv" => Some(Kind::Rkyv),
        _ => None,
    }
}

/// Load the MRU list (most-recent-first) from the default location.
pub fn load() -> Vec<Entry> {
    load_path(&store_file())
}

/// Record `path` as the most-recently-used file at the default location.
pub fn record(path: &Path, kind: Kind) {
    record_path(&store_file(), path, kind);
}

pub(crate) fn load_path(file: &Path) -> Vec<Entry> {
    let content = match std::fs::read_to_string(file) {
        Ok(c) => c,
        Err(_) => return Vec::new(),
    };
    let mut out = Vec::new();
    for line in content.lines() {
        let mut it = line.splitn(3, '\t');
        let (Some(ts), Some(kind), Some(path)) = (it.next(), it.next(), it.next()) else {
            continue;
        };
        let Ok(secs) = ts.parse::<u64>() else { continue };
        let Some(kind) = parse_kind(kind) else { continue };
        out.push(Entry {
            path: PathBuf::from(path),
            kind,
            opened: UNIX_EPOCH + Duration::from_secs(secs),
        });
    }
    out
}

pub(crate) fn record_path(file: &Path, path: &Path, kind: Kind) {
    let abs = std::fs::canonicalize(path).unwrap_or_else(|_| path.to_path_buf());
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);

    let mut entries = load_path(file);
    entries.retain(|e| e.path != abs);
    entries.insert(
        0,
        Entry {
            path: abs,
            kind,
            opened: UNIX_EPOCH + Duration::from_secs(now),
        },
    );
    entries.truncate(CAP);

    if let Some(dir) = file.parent() {
        let _ = std::fs::create_dir_all(dir);
    }
    let mut buf = String::new();
    for e in &entries {
        let secs = e
            .opened
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_secs())
            .unwrap_or(0);
        buf.push_str(&format!("{}\t{}\t{}\n", secs, kind_str(e.kind), e.path.display()));
    }
    // Write to a temp file then rename so a concurrent reader never sees a
    // half-written list.
    let tmp = file.with_extension("tmp");
    if std::fs::write(&tmp, &buf).is_ok() {
        let _ = std::fs::rename(&tmp, file);
    }
}

/// Human-readable age like "3m ago".
pub fn rel_age(t: SystemTime) -> String {
    let secs = SystemTime::now()
        .duration_since(t)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    if secs < 60 {
        format!("{}s ago", secs)
    } else if secs < 3600 {
        format!("{}m ago", secs / 60)
    } else if secs < 86400 {
        format!("{}h ago", secs / 3600)
    } else {
        format!("{}d ago", secs / 86400)
    }
}

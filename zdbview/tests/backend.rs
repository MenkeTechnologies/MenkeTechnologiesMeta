//! Backend CRUD/inspection tests. These exercise the SQLite and rkyv stores
//! directly — the layer the TUI drives — without needing a terminal.

use std::io::Write;

// Pull the crate's modules in by path. The binary crate exposes them via the
// integration test harness only if declared in a lib; since zdbview is a bin,
// re-include the sources under test.
#[path = "../src/store.rs"]
mod store;
#[path = "../src/sqlite.rs"]
mod sqlite;
#[path = "../src/rkyv_inspect.rs"]
mod rkyv_inspect;
#[path = "../src/mru.rs"]
mod mru;

use sqlite::SqliteStore;
use rkyv_inspect::RkyvStore;
use store::{detect, Kind};

fn tmp(name: &str) -> std::path::PathBuf {
    let mut p = std::env::temp_dir();
    p.push(format!("zdbview_test_{}_{}", std::process::id(), name));
    p
}

#[test]
fn sqlite_full_crud_roundtrip() {
    let path = tmp("crud.db");
    let _ = std::fs::remove_file(&path);

    // Build a table with rusqlite directly, then drive it through SqliteStore.
    let conn = rusqlite::Connection::open(&path).unwrap();
    conn.execute("CREATE TABLE items (name TEXT, qty INTEGER)", [])
        .unwrap();
    conn.execute("INSERT INTO items (name, qty) VALUES ('a', 1)", [])
        .unwrap();
    conn.execute("INSERT INTO items (name, qty) VALUES ('b', 2)", [])
        .unwrap();
    drop(conn);

    let store = SqliteStore::open(&path).unwrap();
    assert_eq!(store.tables, vec!["items".to_string()]);
    assert_eq!(store.count("items").unwrap(), 2);
    assert_eq!(store.columns("items").unwrap(), vec!["name", "qty"]);

    let view = store.rows("items", 100, 0).unwrap();
    assert_eq!(view.total, 2);
    assert_eq!(view.rows.len(), 2);
    assert_eq!(view.rows[0], vec!["a".to_string(), "1".to_string()]);
    let rowid_a = view.rowids[0].expect("rowid present");

    // UPDATE
    store.update_cell("items", rowid_a, "qty", "42").unwrap();
    let view = store.rows("items", 100, 0).unwrap();
    assert_eq!(view.rows[0], vec!["a".to_string(), "42".to_string()]);

    // INSERT (default values)
    store.insert_blank("items").unwrap();
    assert_eq!(store.count("items").unwrap(), 3);

    // DELETE
    store.delete_row("items", rowid_a).unwrap();
    assert_eq!(store.count("items").unwrap(), 2);
    let view = store.rows("items", 100, 0).unwrap();
    assert!(view.rows.iter().all(|r| r[0] != "a"));

    // raw exec
    let affected = store.exec("UPDATE items SET name = 'z'").unwrap();
    assert_eq!(affected, 2);

    let _ = std::fs::remove_file(&path);
}

#[test]
fn rkyv_structural_strings_and_hex() {
    let path = tmp("archive.rkyv");
    // A synthetic binary blob: some bytes + an embedded string + more bytes.
    let mut f = std::fs::File::create(&path).unwrap();
    f.write_all(&[0x00, 0x01, 0x02]).unwrap();
    f.write_all(b"hello_field").unwrap();
    f.write_all(&[0xff, 0xfe]).unwrap();
    f.write_all(b"key").unwrap(); // len 3 — below MIN, must be skipped at min=4
    drop(f);

    let store = RkyvStore::open(&path).unwrap();
    assert_eq!(store.len(), 3 + 11 + 2 + 3);

    let hits = store.strings(4);
    assert_eq!(hits.len(), 1, "only the >=4 run should match");
    assert_eq!(hits[0].text, "hello_field");
    assert_eq!(hits[0].offset, 3);

    // shorter min picks up the 3-char run too
    let hits = store.strings(3);
    assert_eq!(hits.len(), 2);

    // hex row format: offset + 16 columns
    let row = store.hex_row(0);
    assert!(row.starts_with("00000000  "));
    assert!(row.contains("|"));

    let _ = std::fs::remove_file(&path);
}

#[test]
fn mru_record_dedup_and_order() {
    let file = tmp("recent.list");
    let _ = std::fs::remove_file(&file);

    // Create three real files to record (paths must exist for canonicalize).
    let a = tmp("mru_a.db");
    let b = tmp("mru_b.rkyv");
    std::fs::write(&a, b"x").unwrap();
    std::fs::write(&b, b"y").unwrap();

    mru::record_path(&file, &a, Kind::Sqlite);
    mru::record_path(&file, &b, Kind::Rkyv);
    // Re-record `a`: it must move to the front, not duplicate.
    mru::record_path(&file, &a, Kind::Sqlite);

    let entries = mru::load_path(&file);
    assert_eq!(entries.len(), 2, "dedup by path");
    assert_eq!(entries[0].path, std::fs::canonicalize(&a).unwrap());
    assert_eq!(entries[0].kind, Kind::Sqlite);
    assert_eq!(entries[1].path, std::fs::canonicalize(&b).unwrap());

    for p in [&file, &a, &b] {
        let _ = std::fs::remove_file(p);
    }
}

#[test]
fn detect_rkyv_when_db_extension_but_not_sqlite() {
    // A .db file that is NOT a SQLite database (the plugins.db case) must be
    // detected as rkyv, because the magic check is authoritative.
    let path = tmp("fake.db");
    std::fs::write(&path, b"this is definitely not a sqlite header at all").unwrap();
    assert!(matches!(detect(&path, false, false).unwrap(), Kind::Rkyv));
    let _ = std::fs::remove_file(&path);
}

#[test]
fn detect_sqlite_by_magic_and_extension() {
    // Real sqlite file → magic detection.
    let dbpath = tmp("detect.db");
    let _ = std::fs::remove_file(&dbpath);
    let conn = rusqlite::Connection::open(&dbpath).unwrap();
    conn.execute("CREATE TABLE t (x)", []).unwrap();
    drop(conn);
    assert!(matches!(detect(&dbpath, false, false).unwrap(), Kind::Sqlite));

    // Non-sqlite file with unknown extension → rkyv default.
    let binpath = tmp("blob.bin");
    std::fs::write(&binpath, [0u8, 1, 2, 3]).unwrap();
    assert!(matches!(detect(&binpath, false, false).unwrap(), Kind::Rkyv));

    // Force flags win.
    assert!(matches!(detect(&binpath, true, false).unwrap(), Kind::Sqlite));
    assert!(matches!(detect(&dbpath, false, true).unwrap(), Kind::Rkyv));

    let _ = std::fs::remove_file(&dbpath);
    let _ = std::fs::remove_file(&binpath);
}

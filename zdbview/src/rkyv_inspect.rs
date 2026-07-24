//! rkyv (and generic binary) structural inspector.
//!
//! rkyv archives are not self-describing — the format stores no field names or
//! type tags (https://rkyv.org/format.html), so a generic reader cannot recover
//! the schema. What it CAN do without the Rust type is show the raw structure:
//! a hex/ascii dump and the runs of printable text embedded in the archive
//! (strings, keys, interned identifiers). Typed CRUD would require a supplied
//! schema descriptor and is deferred.

use anyhow::{Context, Result};
use std::path::{Path, PathBuf};

pub struct RkyvStore {
    pub path: PathBuf,
    pub bytes: Vec<u8>,
}

/// A run of printable ASCII found in the archive, with its byte offset.
pub struct StringHit {
    pub offset: usize,
    pub text: String,
}

impl RkyvStore {
    pub fn open(path: &Path) -> Result<Self> {
        let bytes =
            std::fs::read(path).with_context(|| format!("read {}", path.display()))?;
        Ok(Self {
            path: path.to_path_buf(),
            bytes,
        })
    }

    pub fn len(&self) -> usize {
        self.bytes.len()
    }

    /// Extract runs of printable ASCII of at least `min_len` bytes.
    pub fn strings(&self, min_len: usize) -> Vec<StringHit> {
        let mut hits = Vec::new();
        let mut start: Option<usize> = None;
        for (i, &b) in self.bytes.iter().enumerate() {
            let printable = (0x20..0x7f).contains(&b);
            match (printable, start) {
                (true, None) => start = Some(i),
                (false, Some(s)) => {
                    if i - s >= min_len {
                        hits.push(StringHit {
                            offset: s,
                            text: String::from_utf8_lossy(&self.bytes[s..i]).into_owned(),
                        });
                    }
                    start = None;
                }
                _ => {}
            }
        }
        if let Some(s) = start {
            if self.bytes.len() - s >= min_len {
                hits.push(StringHit {
                    offset: s,
                    text: String::from_utf8_lossy(&self.bytes[s..]).into_owned(),
                });
            }
        }
        hits
    }

    /// One 16-byte `offset  hex bytes  |ascii|` line, `xxd` style.
    pub fn hex_row(&self, offset: usize) -> String {
        let end = (offset + 16).min(self.bytes.len());
        let chunk = &self.bytes[offset.min(self.bytes.len())..end];
        let mut hex = String::with_capacity(50);
        for i in 0..16 {
            if i < chunk.len() {
                hex.push_str(&format!("{:02x} ", chunk[i]));
            } else {
                hex.push_str("   ");
            }
            if i == 7 {
                hex.push(' ');
            }
        }
        let ascii: String = chunk
            .iter()
            .map(|&b| if (0x20..0x7f).contains(&b) { b as char } else { '.' })
            .collect();
        format!("{:08x}  {} |{}|", offset, hex, ascii)
    }
}

# Documentation

- **`index.html`** — Static documentation hub (open in a browser). Links to Rust API HTML and summarizes test commands.
- **`api/`** — Copy of `cargo doc` output for the `app_lib` crate. Regenerate with:

  ```bash
  pnpm run doc:sync
  ```

  Do not edit files under `api/` by hand; they are overwritten on each sync.

- **Root `README.md`** — Full product and developer guide (features, testing counts, architecture).

JavaScript tests (`pnpm test` / `node --test test/*.test.js`) are **Node-only unit** checks; they do **not** run the WebView, Tauri IPC, or the real `applyFilter` / filter-persistence pipeline. See README → *[0x04] TESTING* for the suite scope.

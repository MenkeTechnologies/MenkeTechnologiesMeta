#!/usr/bin/env node
// gen-doc-inventory.mjs — regenerate docs/inventory.html: a HUD-format, clickable
// inventory of every doc page served under docs/. Every link points at the DEPLOYED
// GitHub Pages URL so the inventory works when shared/opened anywhere. Counts are
// derived at run time (never hardcoded). Run from the meta repo root:
//   node bin/gen-doc-inventory.mjs
import { readdirSync, readFileSync, writeFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const DOCS = 'docs';
const SELF = 'inventory.html';
const BASE = 'https://menketechnologies.github.io/MenkeTechnologiesMeta/'; // deployed GH Pages root for docs/

function walk(dir) {
  const out = [];
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (e.endsWith('.html')) out.push(p);
  }
  return out;
}

const all = walk(DOCS).map(p => p.slice(DOCS.length + 1)); // path relative to docs/
const hud = all.filter(p => !p.includes('/api/') && p !== SELF).sort();
const apiByGroup = {};
const apiIndexByGroup = {};
for (const p of all) if (p.includes('/api/')) {
  const g = p.split('/')[0];
  apiByGroup[g] = (apiByGroup[g] || 0) + 1;
  if (p.endsWith('/index.html')) {
    const cur = apiIndexByGroup[g];
    if (!cur || p.split('/').length < cur.split('/').length) apiIndexByGroup[g] = p;
  }
}

const titleOf = rel => {
  const html = readFileSync(join(DOCS, rel), 'utf8');
  const m = html.match(/<title>([\s\S]*?)<\/title>/i);
  return (m ? m[1] : rel).replace(/\s+/g, ' ').trim();
};
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const deployed = rel => BASE + rel.split('/').map(encodeURIComponent).join('/');
const ext = ' target="_blank" rel="noopener noreferrer"';

const groups = {};
for (const rel of hud) {
  const g = rel.includes('/') ? rel.split('/')[0] : 'Meta root';
  (groups[g] ||= []).push(rel);
}
const names = Object.keys(groups).sort((a, b) =>
  a === 'Meta root' ? -1 : b === 'Meta root' ? 1 : a.localeCompare(b));
const totalApi = Object.values(apiByGroup).reduce((a, b) => a + b, 0);

const sections = names.map(g => {
  const pages = groups[g].sort();
  const api = apiByGroup[g];
  const items = pages.map(rel =>
    `        <li><a href="${esc(deployed(rel))}"${ext}>${esc(titleOf(rel))}</a> <span class="inv-path">${esc(rel)}</span></li>`
  ).join('\n');
  const apiHref = apiIndexByGroup[g];
  const apiLine = api
    ? `\n        <li class="inv-api">` + (apiHref
        ? `<a href="${esc(deployed(apiHref))}"${ext}>${api} API reference pages</a>`
        : `${api} API reference pages`) + ` <span class="inv-path">${esc(g)}/api/</span></li>`
    : '';
  return `      <section class="inv-group">
    <h2 class="inv-group-title">${esc(g)} <span class="inv-count">${pages.length}</span></h2>
    <ul class="inv-list">
${items}${apiLine}
    </ul>
  </section>`;
}).join('\n');

const nav = (label, rel, current) => current
  ? `          <span class="current">${label}</span>`
  : `          <a href="${esc(deployed(rel))}"${ext}>${label}</a>`;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <meta name="description" content="MenkeTechnologiesMeta documentation inventory — a complete, clickable index of every HUD documentation page deployed under docs/ across all submodules, plus per-submodule API reference page counts. Every link points at the live GitHub Pages deployment.">
  <title>MenkeTechnologiesMeta — Doc Inventory</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;700;900&amp;family=Share+Tech+Mono&amp;display=swap" rel="stylesheet">
  <link rel="stylesheet" href="hud-static.css">
  <link rel="stylesheet" href="tutorial.css">
  <style>
    .tutorial-main { max-width: 78rem; }
    .inv-summary { font-family: 'Share Tech Mono', ui-monospace, monospace; font-size: 12px; color: var(--text-dim); margin: 0 0 1.5rem; }
    .inv-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(22rem, 1fr)); gap: 1.1rem; }
    .inv-group { border: 1px solid var(--border); background: var(--bg-card); padding: 0.9rem 1.1rem 1.1rem; }
    .inv-group-title { font-family: 'Orbitron', sans-serif; font-size: 13px; letter-spacing: 1px; text-transform: uppercase; color: var(--accent); margin: 0 0 0.6rem; display: flex; align-items: baseline; gap: 0.5rem; }
    .inv-count { font-family: 'Share Tech Mono', monospace; font-size: 11px; color: var(--cyan); border: 1px solid var(--border); padding: 0 0.35rem; }
    .inv-list { list-style: none; margin: 0; padding: 0; }
    .inv-list li { padding: 0.2rem 0; border-top: 1px dashed var(--border); display: flex; flex-direction: column; }
    .inv-list li:first-child { border-top: none; }
    .inv-list a { color: var(--text); text-decoration: none; font-size: 13px; }
    .inv-list a:hover { color: var(--accent); text-decoration: underline; }
    .inv-path { font-family: 'Share Tech Mono', monospace; font-size: 10px; color: var(--text-muted); }
    .inv-api a { color: var(--cyan); }
  </style>
</head>
<body>
  <header class="tutorial-header">
    <div class="tutorial-header-inner">
      <div>
        <h1 class="tutorial-brand">// DOC INVENTORY</h1>
        <nav class="tutorial-crumbs" aria-label="Breadcrumb">
${nav('Docs', 'index.html', false)}
          <span class="sep">/</span>
          <span class="current">Inventory</span>
          <span class="sep">/</span>
${nav('Engineering report', 'report.html', false)}
          <span class="sep">/</span>
${nav('Port reports', 'port-reports.html', false)}
          <span class="sep">/</span>
${nav('Invention ledger', 'inventions.html', false)}
          <span class="sep">/</span>
          <a href="https://github.com/MenkeTechnologies/MenkeTechnologiesMeta" target="_blank" rel="noopener noreferrer">GitHub</a>
        </nav>
        <p class="docs-build-line">${hud.length} HUD documentation pages across ${names.length} sections · ${totalApi} API reference pages · all links point at the live GitHub Pages deployment · generated by bin/gen-doc-inventory.mjs</p>
      </div>
      <div class="tutorial-toolbar">
        <button type="button" class="btn btn-secondary" id="btnTheme" title="Toggle light/dark">Theme</button>
        <button type="button" class="btn btn-secondary active" id="btnCrt" title="CRT scanline overlay">CRT</button>
        <button type="button" class="btn btn-secondary active" id="btnNeon" title="Neon border pulse">Neon</button>
        <a class="btn btn-secondary" href="${BASE}index.html" target="_blank" rel="noopener noreferrer">Home</a>
        <a class="btn btn-secondary" href="https://github.com/MenkeTechnologies/MenkeTechnologiesMeta" target="_blank" rel="noopener noreferrer">GitHub</a>
      </div>
    </div>
  </header>
  <main class="tutorial-main">
    <p class="inv-summary">// ${hud.length} pages · ${names.length} sections · ${totalApi} API pages — every link opens the live GitHub Pages deployment</p>
    <div class="inv-grid">
${sections}
    </div>
  </main>
  <script src="hud-theme.js"></script>
</body>
</html>
`;

writeFileSync(join(DOCS, SELF), html);
console.log(`wrote ${DOCS}/${SELF}: ${hud.length} HUD pages, ${names.length} sections, ${totalApi} API pages (deployed links)`);

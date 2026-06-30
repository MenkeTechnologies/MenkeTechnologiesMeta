#!/usr/bin/env node
// gen-doc-inventory.mjs — regenerate docs/inventory.html: a HUD-format, clickable
// inventory of every doc page under docs/, PLUS a chrome-sync audit flagging "fake"
// pages (not wired to shared hud-static.css / hud-theme.js / tutorial.css, or with a
// missing/unstyled header, or a header with no nav links = a dead-end). Links point at
// the live GitHub Pages deployment. Derived at run time. From repo root:
//   node bin/gen-doc-inventory.mjs
import { readdirSync, readFileSync, writeFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
const DOCS = 'docs', SELF = 'inventory.html';
const BASE = 'https://menketechnologies.github.io/MenkeTechnologiesMeta/';
function walk(dir){const o=[];for(const e of readdirSync(dir)){const p=join(dir,e);if(statSync(p).isDirectory())o.push(...walk(p));else if(e.endsWith('.html'))o.push(p);}return o;}
const all = walk(DOCS).map(p => p.slice(DOCS.length + 1));
const hud = all.filter(p => !p.includes('/api/') && p !== SELF).sort();
const apiByGroup = {}, apiIndexByGroup = {};
for (const p of all) if (p.includes('/api/')) { const g=p.split('/')[0]; apiByGroup[g]=(apiByGroup[g]||0)+1; if(p.endsWith('/index.html')){const c=apiIndexByGroup[g]; if(!c||p.split('/').length<c.split('/').length)apiIndexByGroup[g]=p;} }
const esc = s => s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const deployed = rel => BASE + rel.split('/').map(encodeURIComponent).join('/');
const ext = ' target="_blank" rel="noopener noreferrer"';
function analyze(rel){
  const h = readFileSync(join(DOCS, rel), 'utf8');
  const title = (h.match(/<title>([\s\S]*?)<\/title>/i) || [, rel])[1].replace(/\s+/g,' ').trim();
  const hudStatic = /hud-static\.css/.test(h), hudTheme = /hud-theme\.js/.test(h);
  const hdr = (h.match(/<header[\s\S]*?<\/header>/i) || [''])[0];
  const hasHeader = /<header[\s>]/.test(h);
  const tutHeader = /class="tutorial-header"/.test(h);
  const tutCss = /tutorial\.css/.test(h) || /\.tutorial-header/.test(h);
  const headerNav = /<a [^>]*href=/.test(hdr);
  const issues = [];
  if (!hudStatic) issues.push('no hud-static.css');
  if (!hudTheme) issues.push('no hud-theme.js (no color schemes)');
  if (!hasHeader) issues.push('no header');
  else if (tutHeader && !tutCss) issues.push('unstyled header (no tutorial.css)');
  if (hasHeader && !headerNav) issues.push('header has no nav links (dead-end)');
  return { rel, title, hudStatic, hudTheme, hasHeader, headerNav, ok: issues.length === 0, issues };
}
const meta = hud.map(analyze), fakes = meta.filter(m => !m.ok);
const groups = {};
for (const m of meta){ const g = m.rel.includes('/') ? m.rel.split('/')[0] : 'Meta root'; (groups[g] ||= []).push(m); }
const names = Object.keys(groups).sort((a,b)=> a==='Meta root'?-1 : b==='Meta root'?1 : a.localeCompare(b));
const totalApi = Object.values(apiByGroup).reduce((a,b)=>a+b,0);
const yes='<span class="ok">✓</span>', no='<span class="bad">✗</span>';
const sections = names.map(g => {
  const pages = groups[g].slice().sort((a,b)=>a.rel.localeCompare(b.rel));
  const api = apiByGroup[g], apiHref = apiIndexByGroup[g];
  const items = pages.map(m => {
    const badge = m.ok ? '<span class="badge badge-ok">OK</span>' : `<span class="badge badge-bad" title="${esc(m.issues.join('; '))}">FAKE</span>`;
    const flags = `<span class="flags">CSS ${m.hudStatic?yes:no} JS ${m.hudTheme?yes:no} HDR ${m.hasHeader?yes:no} NAV ${m.headerNav?yes:no}</span>`;
    const note = m.ok ? '' : `<span class="issue">${esc(m.issues.join(' · '))}</span>`;
    return `        <li>${badge} <a href="${esc(deployed(m.rel))}"${ext}>${esc(m.title)}</a> ${flags}<span class="inv-path">${esc(m.rel)}</span>${note}</li>`;
  }).join('\n');
  const apiLine = api ? `\n        <li class="inv-api"><span class="badge badge-api">API</span> ` + (apiHref ? `<a href="${esc(deployed(apiHref))}"${ext}>${api} API reference pages</a>` : `${api} API reference pages`) + ` <span class="inv-path">${esc(g)}/api/</span></li>` : '';
  return `      <section class="inv-group">\n    <h2 class="inv-group-title">${esc(g)} <span class="inv-count">${pages.length}</span></h2>\n    <ul class="inv-list">\n${items}${apiLine}\n    </ul>\n  </section>`;
}).join('\n');
const auditBlock = fakes.length
  ? `      <section class="inv-audit inv-audit-bad">\n    <h2 class="inv-group-title">⚠ Fake / unsynced doc pages <span class="inv-count">${fakes.length}</span></h2>\n    <ul class="inv-list">\n${fakes.map(m=>`        <li><span class="badge badge-bad">FAKE</span> <a href="${esc(deployed(m.rel))}"${ext}>${esc(m.rel)}</a> <span class="issue">${esc(m.issues.join(' · '))}</span></li>`).join('\n')}\n    </ul>\n  </section>`
  : `      <section class="inv-audit inv-audit-ok">\n    <h2 class="inv-group-title">✓ Chrome sync: all ${meta.length} pages wired to shared hud-static.css + hud-theme.js + styled header + nav links</h2>\n  </section>`;
const nav = (label, rel) => `          <a href="${esc(deployed(rel))}"${ext}>${label}</a>`;
const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <meta name="description" content="MenkeTechnologiesMeta documentation inventory + chrome-sync audit — a complete clickable index of every HUD doc page under docs/, verifying each loads the shared hud-static.css + hud-theme.js + tutorial.css chrome, has a styled header, and has header nav links. Fake/unsynced/dead-end pages are flagged.">
  <title>MenkeTechnologiesMeta — Doc Inventory &amp; Chrome Audit</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;600;700;900&amp;family=Share+Tech+Mono&amp;display=swap" rel="stylesheet">
  <link rel="stylesheet" href="hud-static.css">
  <link rel="stylesheet" href="tutorial.css">
  <style>
    .tutorial-main { max-width: 84rem; }
    .inv-summary { font-family: 'Share Tech Mono', ui-monospace, monospace; font-size: 12px; color: var(--text-dim); margin: 0 0 1.2rem; }
    .inv-audit { border: 1px solid var(--border); padding: 0.8rem 1.1rem 1rem; margin: 0 0 1.5rem; }
    .inv-audit-bad { border-color: var(--red); background: color-mix(in srgb, var(--red) 8%, transparent); }
    .inv-audit-ok { border-color: var(--green); background: var(--green-bg); }
    .inv-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(27rem, 1fr)); gap: 1.1rem; }
    .inv-group { border: 1px solid var(--border); background: var(--bg-card); padding: 0.9rem 1.1rem 1.1rem; }
    .inv-group-title { font-family: 'Orbitron', sans-serif; font-size: 13px; letter-spacing: 1px; text-transform: uppercase; color: var(--accent); margin: 0 0 0.6rem; display: flex; align-items: baseline; gap: 0.5rem; }
    .inv-count { font-family: 'Share Tech Mono', monospace; font-size: 11px; color: var(--cyan); border: 1px solid var(--border); padding: 0 0.35rem; }
    .inv-list { list-style: none; margin: 0; padding: 0; }
    .inv-list li { padding: 0.3rem 0; border-top: 1px dashed var(--border); font-size: 13px; }
    .inv-list li:first-child { border-top: none; }
    .inv-list a { color: var(--text); text-decoration: none; }
    .inv-list a:hover { color: var(--accent); text-decoration: underline; }
    .inv-path { display: block; font-family: 'Share Tech Mono', monospace; font-size: 10px; color: var(--text-muted); }
    .issue { display: block; font-family: 'Share Tech Mono', monospace; font-size: 10px; color: var(--red); }
    .flags { font-family: 'Share Tech Mono', monospace; font-size: 10px; color: var(--text-dim); margin-left: 0.4rem; }
    .ok { color: var(--green); } .bad { color: var(--red); }
    .badge { font-family: 'Orbitron', sans-serif; font-size: 9px; letter-spacing: 1px; padding: 1px 5px; border: 1px solid var(--border); }
    .badge-ok { color: var(--green); border-color: var(--green); }
    .badge-bad { color: var(--red); border-color: var(--red); }
    .badge-api { color: var(--cyan); border-color: var(--cyan); }
    .inv-api a { color: var(--cyan); }
  </style>
</head>
<body>
  <header class="tutorial-header">
    <div class="tutorial-header-inner">
      <div>
        <h1 class="tutorial-brand">// DOC INVENTORY &amp; CHROME AUDIT</h1>
        <nav class="tutorial-crumbs" aria-label="Breadcrumb">
${nav('Docs','index.html')}
          <span class="sep">/</span>
          <span class="current">Inventory</span>
          <span class="sep">/</span>
${nav('Engineering report','report.html')}
          <span class="sep">/</span>
${nav('Port reports','port-reports.html')}
          <span class="sep">/</span>
${nav('Invention ledger','inventions.html')}
          <span class="sep">/</span>
          <a href="https://github.com/MenkeTechnologies/MenkeTechnologiesMeta" target="_blank" rel="noopener noreferrer">GitHub</a>
        </nav>
        <p class="docs-build-line">${meta.length} HUD pages · ${meta.filter(m=>m.ok).length} chrome-synced · ${fakes.length} fake/unsynced · ${names.length} sections · ${totalApi} API pages · all links live on GitHub Pages · generated by bin/gen-doc-inventory.mjs</p>
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
    <p class="inv-summary">// ${meta.length} pages · ${meta.filter(m=>m.ok).length} synced · ${fakes.length} fake · ${totalApi} API — CSS=hud-static.css · JS=hud-theme.js (8 schemes) · HDR=styled header · NAV=header nav links · every link live</p>
${auditBlock}
    <div class="inv-grid">
${sections}
    </div>
  </main>
  <script src="hud-theme.js"></script>
</body>
</html>
`;
writeFileSync(join(DOCS, SELF), html);
console.log(`wrote ${DOCS}/${SELF}: ${meta.length} pages, ${meta.filter(m=>m.ok).length} synced, ${fakes.length} fake, ${totalApi} API`);

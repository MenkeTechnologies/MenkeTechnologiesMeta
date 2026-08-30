#!/usr/bin/env node
// Render docs/INVENTIONS.md into the entry cards of docs/inventions.html.
//
// INVENTIONS.md is the ledger; inventions.html is its published face. The two
// drifted 108 entries apart once, because every edit had to be made twice by
// hand. This rebuilds every <article class="inv"> — number, title, confidence
// badge, body — plus the summary counts, from the Markdown. Page chrome (head,
// styles, header, scheme strip, per-section <h2> and figures, the appendix) is
// left exactly as found, so a diagram or a style stays where it was put.
//
// Usage: bin/sync-inventions-html.mjs [--check]
//   --check exits 1 without writing when the page is out of date.

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = join(dirname(fileURLToPath(import.meta.url)), '..');
const mdPath = join(repo, 'docs/INVENTIONS.md');
const htmlPath = join(repo, 'docs/inventions.html');
const check = process.argv.includes('--check');

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

// A private-use sentinel: no ledger text contains one, so a code span parked
// under it cannot collide with the emphasis pass that runs over the rest.
const MARK = '';

/** Markdown inline spans to HTML, with code spans held out of the emphasis pass. */
function inline(text) {
  const code = [];
  let t = text.replace(/`([^`]+)`/g, (_, c) => MARK + (code.push(c) - 1) + MARK);
  t = esc(t);
  t = t.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  t = t.replace(/\*([^*]+)\*/g, '<em>$1</em>');
  return t.replace(new RegExp(MARK + '(\\d+)' + MARK, 'g'), (_, i) => `<code>${esc(code[i])}</code>`);
}

// ---- parse the ledger -----------------------------------------------------

const lines = readFileSync(mdPath, 'utf8').split('\n');
const sections = [];
let section = null;
let entry = null;

const closeEntry = () => {
  if (!entry) return;
  while (entry.body.length && entry.body.at(-1) === '') entry.body.pop();
  while (entry.note.length && entry.note.at(-1) === '') entry.note.pop();
  section.entries.push(entry);
  entry = null;
};

for (const line of lines) {
  const head = line.match(/^## (.+)$/);
  if (head) {
    closeEntry();
    // The appendix carries prose, not entries; it keeps whatever the page has.
    section = { title: head[1], entries: [] };
    sections.push(section);
    continue;
  }
  if (!section) continue;

  const m = line.match(/^\*\*(\d+[a-z]*)\.\s+(.*?)\*\*\s+—\s+`(high|med|low)`\s*$/);
  if (m) {
    closeEntry();
    const [, id, rawTitle, conf] = m;
    const star = rawTitle.startsWith('★ ');
    entry = { id, conf, star, title: star ? rawTitle.slice(2) : rawTitle, body: [], note: [] };
    continue;
  }
  if (!entry) continue;
  if (line.trim() === '---') { closeEntry(); continue; }
  if (line.startsWith('>')) { entry.note.push(line.replace(/^>\s?/, '')); continue; }
  entry.body.push(line);
}
closeEntry();

const withEntries = sections.filter((s) => s.entries.length);
const all = withEntries.flatMap((s) => s.entries);
if (!all.length) throw new Error('no entries parsed from INVENTIONS.md');

/** Wrapped Markdown lines are one paragraph; a blank line starts the next. */
const paragraphs = (buf) =>
  buf
    .join('\n')
    .split(/\n\s*\n/)
    .map((p) => p.replace(/\s*\n\s*/g, ' ').trim())
    .filter(Boolean);

function renderEntry(e) {
  const title = (e.star ? '<span class="star">★</span> ' : '') + inline(e.title);
  const out = [
    `      <article class="inv conf-${e.conf}" id="inv-${e.id}">`,
    '        <div class="inv-head">',
    `          <span class="inv-num">${e.id}</span>`,
    `          <h4 class="inv-title">${title}</h4>`,
    `          <span class="inv-conf c-${e.conf}">${e.conf.toUpperCase()}</span>`,
    '        </div>',
  ];
  for (const p of paragraphs(e.body)) out.push(`        <p class="inv-body">${inline(p)}</p>`);
  for (const p of paragraphs(e.note)) out.push(`        <p class="inv-note">${inline(p)}</p>`);
  out.push('      </article>');
  return out.join('\n');
}

// ---- splice into the page -------------------------------------------------

let html = readFileSync(htmlPath, 'utf8');
const before = html;

// Figures are placed by hand — some open a section, some sit between two cards.
// Record which card each one trails so the rebuild puts it back where it was.
const figuresAfter = new Map();
{
  let anchor = null;
  for (const line of before.split('\n')) {
    const card = line.match(/id="inv-([0-9a-z]+)"/);
    if (card) { anchor = card[1]; continue; }
    if (/id="sec-\d+"/.test(line)) { anchor = null; continue; }
    if (!anchor || !line.includes('class="inv-fig"')) continue;
    if (!figuresAfter.has(anchor)) figuresAfter.set(anchor, []);
    figuresAfter.get(anchor).push(line.trimEnd());
  }
}

// Each <section id="sec-N"> keeps its heading and figures; its cards are rebuilt.
const sectionRe = /(<section class="tutorial-section" id="sec-(\d+)">\n)([\s\S]*?)(\n {4}<\/section>)/g;
html = html.replace(sectionRe, (whole, open, n, inner, close) => {
  const src = withEntries[Number(n)];
  if (!src) return whole; // appendix and any other prose section
  const firstCard = inner.indexOf('      <article class="inv');
  if (firstCard === -1) return whole;
  const preamble = inner.slice(0, firstCard).replace(/\s*$/, '');
  const heading = `      <h2>${inline(src.title)}</h2>`;
  const rebuiltPreamble = preamble.replace(/^ {6}<h2>[\s\S]*?<\/h2>/, heading);
  const cards = src.entries
    .map((e) => [renderEntry(e), ...(figuresAfter.get(e.id) ?? [])].join('\n'))
    .join('\n');
  return `${open}${rebuiltPreamble}\n${cards}${close}`;
});

// ---- summary counts, all derived ------------------------------------------

const tally = { high: 0, med: 0, low: 0 };
for (const e of all) tally[e.conf]++;
const lettered = all.filter((e) => /[a-z]$/.test(e.id));
const numeric = all.length - lettered.length;
const confSlash = `${tally.high} high / ${tally.med} med / ${tally.low} low`;
const confComma = `${tally.high} high, ${tally.med} med, ${tally.low} low`;

const swap = (re, to) => {
  if (!re.test(html)) throw new Error(`page shape changed, cannot update: ${re}`);
  html = html.replace(re, to);
};

swap(/(<meta name="description" content="[^"]*?)\d+ candidate/, `$1${all.length} candidate`);
swap(/(<meta name="description" content="[^"]*?)\d+ high \/ \d+ med \/ \d+ low/, `$1${confSlash}`);
swap(/(<p class="docs-build-line">)\d+ candidate world-firsts/, `$1${all.length} candidate world-firsts`);
swap(/(<p class="docs-build-line">[^<]*?)\d+ high \/ \d+ med \/ \d+ low/, `$1${confSlash}`);
swap(/(<div class="stat-card"><div class="n">)\d+(<\/div><div class="l">candidates)/, `$1${all.length}$2`);
swap(/(<div class="stat-card"><div class="n">)\d+(<\/div><div class="l">categories)/, `$1${withEntries.length}$2`);
for (const c of ['high', 'med', 'low']) {
  swap(
    new RegExp(`(<div class="stat-card conf-${c}"><div class="n">)\\d+(</div><div class="l">${c} conf)`),
    `$1${tally[c]}$2`,
  );
}
swap(/(<p>Total: )\d+( candidates)/, `$1${all.length}$2`);
swap(/(<p>Total: [^<]*?)\d+( numeric entries)/, `$1${numeric}$2`);
// 11a 11b 11c … 11n reads as 11a–11n; a lone letter stays as it is. The ledger
// keeps a couple of sub-entries out of order (appended after later siblings), so
// sort before collapsing or a run breaks in the middle.
const letterRuns = [];
const letteredSorted = [...lettered].sort((a, b) =>
  a.id.localeCompare(b.id, 'en', { numeric: true }),
);
for (const { id } of letteredSorted) {
  const [, stem, letter] = id.match(/^(\d+)([a-z])$/) ?? [];
  const run = letterRuns.at(-1);
  if (run && run.stem === stem && run.next === letter) {
    run.end = letter;
    run.next = String.fromCharCode(letter.charCodeAt(0) + 1);
  } else {
    letterRuns.push({ stem, start: letter, end: letter, next: String.fromCharCode(letter.charCodeAt(0) + 1) });
  }
}
const letterList = letterRuns
  .map((r) => (r.start === r.end ? `${r.stem}${r.start}` : `${r.stem}${r.start}–${r.stem}${r.end}`))
  .join(', ');
swap(
  /(<p>Total: [^<]*?plus )\d+( lettered sub-entries \()[^)]*\)/,
  `$1${lettered.length}$2${letterList})`,
);
swap(/(<p>Total: [^<]*?By confidence: )\d+ high, \d+ med, \d+ low/, `$1${confComma}`);

// The category cards count what each section actually holds.
let card = 0;
html = html.replace(
  /(<a class="toc-card" href="#sec-\d+"><span class="toc-n">)\d+(<\/span><span class="toc-t">)[^<]*(<\/span>)/g,
  (whole, a, b, c) => {
    const s = withEntries[card++];
    return s ? `${a}${s.entries.length}${b}${inline(s.title)}${c}` : whole;
  },
);

// A pull-quote under a card needs a rule; the page ships none.
if (html.includes('class="inv-note"') && !html.includes('.inv-note {')) {
  swap(
    /(\n {4}\.tutorial-main \{)/,
    `
    .inv-note {
      margin: 0.6rem 0 0; padding: 0.5rem 0.9rem;
      border-left: 2px solid var(--accent);
      background: color-mix(in srgb, var(--bg-secondary) 70%, transparent);
      color: var(--text-dim); font-size: 0.92em; line-height: 1.55;
    }$1`,
  );
}

// The ledger states its own totals in prose; derive those too, so the two files
// cannot disagree about how many entries the ledger holds.
const mdBefore = readFileSync(mdPath, 'utf8');
let md = mdBefore
  .replace(/^Total: \d+ candidates/m, `Total: ${all.length} candidates`)
  .replace(/(^Total: [\s\S]{0,200}?)\d+( numeric entries)/m, `$1${numeric}$2`)
  .replace(
    /(^Total: [\s\S]{0,400}?plus\s*\n?)\d+( lettered sub-entries \()[^)]*\)/m,
    `$1${lettered.length}$2${letterList})`,
  )
  .replace(/By confidence: \d+ high, \d+ med, \d+ low\./, `By confidence: ${confComma}.`);

if (check) {
  const stale = [html !== before && 'inventions.html', md !== mdBefore && 'INVENTIONS.md'].filter(Boolean);
  if (stale.length) {
    console.error(`${stale.join(' and ')} out of date — run bin/sync-inventions-html.mjs`);
    process.exit(1);
  }
  console.log(`ledger and page agree (${all.length} entries, ${confComma})`);
} else {
  const wrote = [];
  if (html !== before) { writeFileSync(htmlPath, html); wrote.push('inventions.html'); }
  if (md !== mdBefore) { writeFileSync(mdPath, md); wrote.push('INVENTIONS.md'); }
  console.log(
    wrote.length
      ? `${wrote.join(' + ')} rebuilt: ${all.length} entries across ${withEntries.length} categories, ${confComma}`
      : `already current (${all.length} entries, ${confComma})`,
  );
}

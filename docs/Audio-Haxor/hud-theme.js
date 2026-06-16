/**
 * Static HUD pages (docs hub, generated i18n report): theme, CRT, neon, and color schemes.
 * Shared layout/CSS: docs/hud-static.css (loaded by docs/index.html; inlined by i18n_catalog_audit.py).
 * Preset palettes mirror frontend/js/settings.js COLOR_SCHEMES — keep in sync when editing schemes.
 */
(function () {
  'use strict';

  /** Keep in sync with `formatBuildCommitDateLine` / `formatBuildMetaLine` in `frontend/js/utils.js`. */
  function formatBuildCommitDateLine(info) {
    if (!info || typeof info !== 'object') return '';
    var parts = [];
    var full = info.gitShaFull && String(info.gitShaFull).trim();
    if (full && full !== 'unknown') parts.push('Commit: ' + full);
    else if (info.gitShaShort && info.gitShaShort !== 'unknown') parts.push('Commit: ' + info.gitShaShort);
    if (info.gitCommitDate && String(info.gitCommitDate).length >= 10) {
      parts.push('Commit date: ' + String(info.gitCommitDate).slice(0, 10));
    }
    return parts.join(' · ');
  }

  function formatBuildMetaLine(info) {
    if (!info || !info.version) return '';
    var head = 'Version: v' + String(info.version);
    var tail = formatBuildCommitDateLine(info);
    return tail ? head + ' · ' + tail : head;
  }

  var STORAGE = {
    theme: 'audio-haxor-hud-theme',
    crt: 'audio-haxor-hud-crt',
    neon: 'audio-haxor-hud-neon',
    scheme: 'audio-haxor-hud-color-scheme',
  };

  var LEGACY_THEME = ['audio-haxor-docs-theme', 'audio-haxor-i18n-report-theme'];
  var LEGACY_CRT = ['audio-haxor-docs-crt', 'audio-haxor-i18n-report-crt'];
  var LEGACY_NEON = ['audio-haxor-docs-neon', 'audio-haxor-i18n-report-neon'];

  var SCHEME_VAR_KEYS = [
    '--accent', '--accent-light', '--accent-glow',
    '--cyan', '--cyan-glow', '--cyan-dim',
    '--magenta', '--magenta-glow',
    '--green', '--green-bg',
    '--yellow', '--yellow-glow',
    '--orange', '--orange-bg',
    '--red',
    '--text', '--text-dim', '--text-muted',
    '--bg-primary', '--bg-secondary', '--bg-card', '--bg-hover',
    '--border', '--border-glow',
  ];

  var SCHEME_ORDER = ['cyberpunk', 'midnight', 'matrix', 'ember', 'arctic'];

  var COLOR_SCHEMES = {
    cyberpunk: {
      label: 'Cyberpunk',
      desc: 'Hot pink + cyan neon (default)',
      vars: {
        '--accent': '#ff2a6d', '--accent-light': '#ff6b9d',
        '--accent-glow': 'rgba(255, 42, 109, 0.4)',
        '--cyan': '#05d9e8', '--cyan-glow': 'rgba(5, 217, 232, 0.4)',
        '--cyan-dim': 'rgba(5, 217, 232, 0.15)',
        '--magenta': '#d300c5', '--magenta-glow': 'rgba(211, 0, 197, 0.3)',
        '--green': '#39ff14', '--green-bg': 'rgba(57, 255, 20, 0.08)',
        '--yellow': '#f9f002', '--yellow-glow': 'rgba(249, 240, 2, 0.2)',
        '--orange': '#ff6b35', '--orange-bg': 'rgba(255, 107, 53, 0.1)',
        '--red': '#ff073a',
        '--text': '#e0f0ff', '--text-dim': '#7a8ba8', '--text-muted': '#3d4f6a',
        '--bg-primary': '#05050a', '--bg-secondary': '#0a0a14',
        '--bg-card': '#0d0d1a', '--bg-hover': '#12122a',
        '--border': '#1a1a3e', '--border-glow': '#2a1a4e',
      },
      lightVars: {
        '--accent': '#d6196e', '--accent-light': '#e84d8a',
        '--accent-glow': 'rgba(214, 25, 110, 0.15)',
        '--cyan': '#0891b2', '--cyan-glow': 'rgba(8, 145, 178, 0.2)',
        '--cyan-dim': 'rgba(8, 145, 178, 0.08)',
        '--magenta': '#a300a3', '--magenta-glow': 'rgba(163, 0, 163, 0.15)',
        '--green': '#15803d', '--green-bg': 'rgba(21, 128, 61, 0.08)',
        '--yellow': '#a16207', '--yellow-glow': 'rgba(161, 98, 7, 0.1)',
        '--orange': '#c2410c', '--orange-bg': 'rgba(194, 65, 12, 0.06)',
        '--red': '#dc2626',
        '--text': '#1e293b', '--text-dim': '#475569', '--text-muted': '#94a3b8',
        '--bg-primary': '#f0f2f5', '--bg-secondary': '#e4e7ec',
        '--bg-card': '#ffffff', '--bg-hover': '#f7f8fa',
        '--border': '#cbd5e1', '--border-glow': '#a5b4c8',
      },
    },
    midnight: {
      label: 'Midnight',
      desc: 'Deep blue + electric purple',
      vars: {
        '--accent': '#7c3aed', '--accent-light': '#a78bfa',
        '--accent-glow': 'rgba(124, 58, 237, 0.4)',
        '--cyan': '#38bdf8', '--cyan-glow': 'rgba(56, 189, 248, 0.4)',
        '--cyan-dim': 'rgba(56, 189, 248, 0.15)',
        '--magenta': '#6366f1', '--magenta-glow': 'rgba(99, 102, 241, 0.3)',
        '--green': '#34d399', '--green-bg': 'rgba(52, 211, 153, 0.08)',
        '--yellow': '#c084fc', '--yellow-glow': 'rgba(192, 132, 252, 0.2)',
        '--orange': '#818cf8', '--orange-bg': 'rgba(129, 140, 248, 0.1)',
        '--red': '#f472b6',
        '--text': '#e0e7ff', '--text-dim': '#94a3b8', '--text-muted': '#475569',
        '--bg-primary': '#050510', '--bg-secondary': '#0a0a1e',
        '--bg-card': '#0d0d28', '--bg-hover': '#141432',
        '--border': '#1e1e4a', '--border-glow': '#2e1e5a',
      },
      lightVars: {
        '--accent': '#6d28d9', '--accent-light': '#8b5cf6',
        '--accent-glow': 'rgba(109, 40, 217, 0.15)',
        '--cyan': '#0284c7', '--cyan-glow': 'rgba(2, 132, 199, 0.2)',
        '--cyan-dim': 'rgba(2, 132, 199, 0.08)',
        '--magenta': '#4f46e5', '--magenta-glow': 'rgba(79, 70, 229, 0.15)',
        '--green': '#059669', '--green-bg': 'rgba(5, 150, 105, 0.08)',
        '--yellow': '#7c3aed', '--yellow-glow': 'rgba(124, 58, 237, 0.1)',
        '--orange': '#6366f1', '--orange-bg': 'rgba(99, 102, 241, 0.06)',
        '--red': '#e11d48',
        '--text': '#1e1b4b', '--text-dim': '#4338ca', '--text-muted': '#a5b4fc',
        '--bg-primary': '#eef2ff', '--bg-secondary': '#e0e7ff',
        '--bg-card': '#ffffff', '--bg-hover': '#f5f3ff',
        '--border': '#c7d2fe', '--border-glow': '#a5b4fc',
      },
    },
    matrix: {
      label: 'Matrix',
      desc: 'Terminal green on black',
      vars: {
        '--accent': '#22c55e', '--accent-light': '#4ade80',
        '--accent-glow': 'rgba(34, 197, 94, 0.4)',
        '--cyan': '#39ff14', '--cyan-glow': 'rgba(57, 255, 20, 0.4)',
        '--cyan-dim': 'rgba(57, 255, 20, 0.15)',
        '--magenta': '#16a34a', '--magenta-glow': 'rgba(22, 163, 74, 0.3)',
        '--green': '#4ade80', '--green-bg': 'rgba(74, 222, 128, 0.08)',
        '--yellow': '#a3e635', '--yellow-glow': 'rgba(163, 230, 53, 0.2)',
        '--orange': '#86efac', '--orange-bg': 'rgba(134, 239, 172, 0.1)',
        '--red': '#ef4444',
        '--text': '#d1fae5', '--text-dim': '#6ee7b7', '--text-muted': '#365314',
        '--bg-primary': '#020a02', '--bg-secondary': '#061006',
        '--bg-card': '#081408', '--bg-hover': '#0e200e',
        '--border': '#1a3a1a', '--border-glow': '#1a4a1a',
      },
      lightVars: {
        '--accent': '#16a34a', '--accent-light': '#22c55e',
        '--accent-glow': 'rgba(22, 163, 74, 0.15)',
        '--cyan': '#15803d', '--cyan-glow': 'rgba(21, 128, 61, 0.2)',
        '--cyan-dim': 'rgba(21, 128, 61, 0.08)',
        '--magenta': '#166534', '--magenta-glow': 'rgba(22, 101, 52, 0.15)',
        '--green': '#22c55e', '--green-bg': 'rgba(34, 197, 94, 0.08)',
        '--yellow': '#65a30d', '--yellow-glow': 'rgba(101, 163, 13, 0.1)',
        '--orange': '#4ade80', '--orange-bg': 'rgba(74, 222, 128, 0.06)',
        '--red': '#dc2626',
        '--text': '#14532d', '--text-dim': '#166534', '--text-muted': '#86efac',
        '--bg-primary': '#f0fdf4', '--bg-secondary': '#dcfce7',
        '--bg-card': '#ffffff', '--bg-hover': '#f0fdf4',
        '--border': '#bbf7d0', '--border-glow': '#86efac',
      },
    },
    ember: {
      label: 'Ember',
      desc: 'Warm amber + orange tones',
      vars: {
        '--accent': '#f59e0b', '--accent-light': '#fbbf24',
        '--accent-glow': 'rgba(245, 158, 11, 0.4)',
        '--cyan': '#fb923c', '--cyan-glow': 'rgba(251, 146, 60, 0.4)',
        '--cyan-dim': 'rgba(251, 146, 60, 0.15)',
        '--magenta': '#ea580c', '--magenta-glow': 'rgba(234, 88, 12, 0.3)',
        '--green': '#84cc16', '--green-bg': 'rgba(132, 204, 22, 0.08)',
        '--yellow': '#fde047', '--yellow-glow': 'rgba(253, 224, 71, 0.2)',
        '--orange': '#f97316', '--orange-bg': 'rgba(249, 115, 22, 0.1)',
        '--red': '#dc2626',
        '--text': '#fef3c7', '--text-dim': '#d97706', '--text-muted': '#92400e',
        '--bg-primary': '#0a0502', '--bg-secondary': '#120a04',
        '--bg-card': '#1a0e06', '--bg-hover': '#24140a',
        '--border': '#3e2a1a', '--border-glow': '#4e3a1a',
      },
      lightVars: {
        '--accent': '#d97706', '--accent-light': '#f59e0b',
        '--accent-glow': 'rgba(217, 119, 6, 0.15)',
        '--cyan': '#ea580c', '--cyan-glow': 'rgba(234, 88, 12, 0.2)',
        '--cyan-dim': 'rgba(234, 88, 12, 0.08)',
        '--magenta': '#c2410c', '--magenta-glow': 'rgba(194, 65, 12, 0.15)',
        '--green': '#65a30d', '--green-bg': 'rgba(101, 163, 13, 0.08)',
        '--yellow': '#a16207', '--yellow-glow': 'rgba(161, 98, 7, 0.1)',
        '--orange': '#c2410c', '--orange-bg': 'rgba(194, 65, 12, 0.06)',
        '--red': '#dc2626',
        '--text': '#451a03', '--text-dim': '#92400e', '--text-muted': '#fbbf24',
        '--bg-primary': '#fffbeb', '--bg-secondary': '#fef3c7',
        '--bg-card': '#ffffff', '--bg-hover': '#fffbeb',
        '--border': '#fde68a', '--border-glow': '#fbbf24',
      },
    },
    arctic: {
      label: 'Arctic',
      desc: 'Cool whites + icy blue',
      vars: {
        '--accent': '#0ea5e9', '--accent-light': '#38bdf8',
        '--accent-glow': 'rgba(14, 165, 233, 0.4)',
        '--cyan': '#67e8f9', '--cyan-glow': 'rgba(103, 232, 249, 0.4)',
        '--cyan-dim': 'rgba(103, 232, 249, 0.15)',
        '--magenta': '#06b6d4', '--magenta-glow': 'rgba(6, 182, 212, 0.3)',
        '--green': '#2dd4bf', '--green-bg': 'rgba(45, 212, 191, 0.08)',
        '--yellow': '#a5f3fc', '--yellow-glow': 'rgba(165, 243, 252, 0.2)',
        '--orange': '#22d3ee', '--orange-bg': 'rgba(34, 211, 238, 0.1)',
        '--red': '#f43f5e',
        '--text': '#ecfeff', '--text-dim': '#a5f3fc', '--text-muted': '#155e75',
        '--bg-primary': '#020a0e', '--bg-secondary': '#041218',
        '--bg-card': '#061a22', '--bg-hover': '#0a2430',
        '--border': '#1a3a4e', '--border-glow': '#1a4a5e',
      },
      lightVars: {
        '--accent': '#0284c7', '--accent-light': '#0ea5e9',
        '--accent-glow': 'rgba(2, 132, 199, 0.15)',
        '--cyan': '#0891b2', '--cyan-glow': 'rgba(8, 145, 178, 0.2)',
        '--cyan-dim': 'rgba(8, 145, 178, 0.08)',
        '--magenta': '#0e7490', '--magenta-glow': 'rgba(14, 116, 144, 0.15)',
        '--green': '#0d9488', '--green-bg': 'rgba(13, 148, 136, 0.08)',
        '--yellow': '#155e75', '--yellow-glow': 'rgba(21, 94, 117, 0.1)',
        '--orange': '#06b6d4', '--orange-bg': 'rgba(6, 182, 212, 0.06)',
        '--red': '#e11d48',
        '--text': '#164e63', '--text-dim': '#0e7490', '--text-muted': '#a5f3fc',
        '--bg-primary': '#ecfeff', '--bg-secondary': '#cffafe',
        '--bg-card': '#ffffff', '--bg-hover': '#ecfeff',
        '--border': '#a5f3fc', '--border-glow': '#67e8f9',
      },
    },
  };

  var DOT_KEYS = ['--accent', '--cyan', '--magenta', '--green', '--yellow', '--orange', '--red', '--text'];

  function readStoredPrimary(primaryKey, legacyKeys, fallback) {
    try {
      var v = localStorage.getItem(primaryKey);
      if (v !== null) return v;
      for (var i = 0; i < legacyKeys.length; i++) {
        var o = localStorage.getItem(legacyKeys[i]);
        if (o !== null) {
          localStorage.setItem(primaryKey, o);
          return o;
        }
      }
    } catch (e) { /* ignore */ }
    return fallback;
  }

  function writeStored(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (e) { /* ignore */ }
  }

  function escapeHtml(s) {
    var d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  function clearInlineSchemeVars() {
    var root = document.documentElement.style;
    for (var i = 0; i < SCHEME_VAR_KEYS.length; i++) {
      root.removeProperty(SCHEME_VAR_KEYS[i]);
    }
  }

  function readStoredScheme() {
    try {
      var v = localStorage.getItem(STORAGE.scheme);
      if (v && COLOR_SCHEMES[v]) return v;
    } catch (e) { /* ignore */ }
    return 'cyberpunk';
  }

  function applyColorScheme(name) {
    if (!COLOR_SCHEMES[name]) name = 'cyberpunk';
    writeStored(STORAGE.scheme, name);
    var isLight = document.documentElement.getAttribute('data-theme') === 'light';
    var scheme = COLOR_SCHEMES[name];
    var vars = isLight && scheme.lightVars ? scheme.lightVars : scheme.vars;
    clearInlineSchemeVars();
    var root = document.documentElement.style;
    for (var k in vars) {
      if (Object.prototype.hasOwnProperty.call(vars, k)) {
        root.setProperty(k, vars[k]);
      }
    }
    document.querySelectorAll('.scheme-btn[data-hud-scheme]').forEach(function (b) {
      b.classList.toggle('active', b.getAttribute('data-hud-scheme') === name);
    });
  }

  function reapplyCurrentScheme() {
    applyColorScheme(readStoredScheme());
  }

  function applyTheme(mode) {
    var html = document.documentElement;
    if (mode === 'light') html.setAttribute('data-theme', 'light');
    else html.removeAttribute('data-theme');
  }

  function applyCrt(on) {
    var app = document.querySelector('.app');
    var h = document.getElementById('crtH');
    var v = document.getElementById('crtV');
    var btn = document.getElementById('btnCrt');
    if (app) app.classList.toggle('no-crt', !on);
    if (h) h.hidden = !on;
    if (v) v.hidden = !on;
    if (btn) btn.classList.toggle('active', on);
  }

  function applyNeon(on) {
    document.body.classList.toggle('no-neon-glow', !on);
    var btn = document.getElementById('btnNeon');
    if (btn) btn.classList.toggle('active', on);
  }

  function initTheme() {
    var saved = readStoredPrimary(STORAGE.theme, LEGACY_THEME, '');
    if (saved === 'light' || saved === 'dark') {
      applyTheme(saved === 'light' ? 'light' : 'dark');
    } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
      applyTheme('light');
    } else {
      applyTheme('dark');
    }
  }

  function initCrt() {
    var v = readStoredPrimary(STORAGE.crt, LEGACY_CRT, 'on');
    applyCrt(v !== 'off');
  }

  function initNeon() {
    var v = readStoredPrimary(STORAGE.neon, LEGACY_NEON, 'on');
    applyNeon(v !== 'off');
  }

  function syncThemeButton() {
    var btn = document.getElementById('btnTheme');
    if (!btn) return;
    var light = document.documentElement.getAttribute('data-theme') === 'light';
    btn.textContent = light ? 'Dark mode' : 'Light mode';
  }

  function buildSchemeGrid() {
    var grid = document.getElementById('hudSchemeGrid');
    if (!grid) return;
    grid.innerHTML = '';
    for (var i = 0; i < SCHEME_ORDER.length; i++) {
      var key = SCHEME_ORDER[i];
      var scheme = COLOR_SCHEMES[key];
      if (!scheme) continue;
      var dots = '';
      for (var j = 0; j < DOT_KEYS.length; j++) {
        var c = scheme.vars[DOT_KEYS[j]] || '#888';
        dots += '<span class="scheme-dot" style="background:' + c + '"></span>';
      }
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'scheme-btn';
      btn.setAttribute('data-hud-scheme', key);
      btn.title = 'Apply ' + scheme.label;
      btn.innerHTML =
        '<div class="scheme-btn-name">' + escapeHtml(scheme.label) + '</div>' +
        '<div class="scheme-btn-desc">' + escapeHtml(scheme.desc) + '</div>' +
        '<div class="scheme-btn-preview">' + dots + '</div>';
      btn.addEventListener('click', function (ev) {
        var k = ev.currentTarget.getAttribute('data-hud-scheme');
        applyColorScheme(k);
      });
      grid.appendChild(btn);
    }
  }

  function applyStaticBuildMeta() {
    var b = typeof window !== 'undefined' ? window.__AUDIO_HAXOR_BUILD__ : null;
    if (!b || !b.version) return;
    var fullLine = formatBuildMetaLine(b);
    var line = document.getElementById('hudBuildMetaLine');
    if (line) {
      line.textContent = fullLine;
      line.style.wordBreak = 'break-word';
    }
    var t = document.querySelector('title');
    if (t && fullLine) {
      var raw = t.textContent;
      var cut = raw.indexOf(' · Version:');
      var base = (cut >= 0 ? raw.slice(0, cut) : raw).trim();
      t.textContent = base + ' · ' + fullLine;
    }
    var meta = document.querySelector('meta[name="description"]');
    if (meta && fullLine) {
      meta.setAttribute(
        'content',
        'AUDIO_HAXOR — ' + fullLine + '. Developer docs hub / i18n audit: feature map, rustdoc, IPC, palette, shortcuts.'
      );
    }
  }

  document.addEventListener('DOMContentLoaded', function () {
    applyStaticBuildMeta();
    initTheme();
    initCrt();
    initNeon();
    syncThemeButton();
    buildSchemeGrid();
    reapplyCurrentScheme();

    var btnTheme = document.getElementById('btnTheme');
    if (btnTheme) {
      btnTheme.addEventListener('click', function () {
        var light = document.documentElement.getAttribute('data-theme') === 'light';
        var next = light ? 'dark' : 'light';
        applyTheme(next === 'light' ? 'light' : 'dark');
        writeStored(STORAGE.theme, next);
        syncThemeButton();
        reapplyCurrentScheme();
      });
    }

    var btnCrt = document.getElementById('btnCrt');
    if (btnCrt) {
      btnCrt.addEventListener('click', function () {
        var el = document.getElementById('crtH');
        var on = el && !el.hidden;
        applyCrt(!on);
        writeStored(STORAGE.crt, !on ? 'on' : 'off');
      });
    }

    var btnNeon = document.getElementById('btnNeon');
    if (btnNeon) {
      btnNeon.addEventListener('click', function () {
        var on = !document.body.classList.contains('no-neon-glow');
        applyNeon(!on);
        writeStored(STORAGE.neon, !on ? 'on' : 'off');
      });
    }
  });
})();

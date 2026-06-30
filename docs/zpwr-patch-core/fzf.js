/* fzf-style fuzzy search — vendored verbatim from audio_haxor/frontend/js/utils.js
 * (scoring + extended-query syntax: 'exact, ^prefix, suffix$, !negate, a | b).
 * Settings/prefs machinery dropped; weights are the project defaults. */
(function (global) {
  'use strict';

  var SCORE_MATCH = 16, SCORE_GAP_START = -3, SCORE_GAP_EXTENSION = -1;
  var BONUS_BOUNDARY = 9, BONUS_NON_WORD = 8, BONUS_CAMEL = 7, BONUS_CONSECUTIVE = 4, BONUS_FIRST_CHAR_MULT = 2;
  var SCORE_SUBSTRING_BONUS = 1000, SCORE_EXACT_BONUS = 2000, SCORE_PREFIX_BONUS = 1500;

  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function charClass(c) {
    if (c >= 'a' && c <= 'z') return 1;
    if (c >= 'A' && c <= 'Z') return 2;
    if (c >= '0' && c <= '9') return 3;
    return 0;
  }
  function positionBonus(prev, curr) {
    var pc = charClass(prev), cc = charClass(curr);
    if (pc === 0 && cc !== 0) return BONUS_BOUNDARY;
    if (pc === 1 && cc === 2) return BONUS_CAMEL;
    if (cc !== 0 && pc !== 0 && pc !== cc) return BONUS_NON_WORD;
    return 0;
  }

  function fzfMatch(needle, haystack) {
    var nLen = needle.length, hLen = haystack.length;
    if (nLen === 0) return { score: 0, indices: [] };
    if (nLen > hLen) return null;
    var nLower = needle.toLowerCase(), hLower = haystack.toLowerCase();
    var ni = 0;
    for (var hi = 0; hi < hLen && ni < nLen; hi++) if (hLower[hi] === nLower[ni]) ni++;
    if (ni < nLen) return null;
    var bestScore = -Infinity, bestIndices = null, starts = [];
    for (var i = 0; i <= hLen - nLen; i++) if (hLower[i] === nLower[0]) starts.push(i);
    for (var s = 0; s < starts.length; s++) {
      var start = starts[s], indices = [start], si = start, valid = true;
      for (var n = 1; n < nLen; n++) {
        var found = false;
        for (var h = si + 1; h < hLen; h++) {
          if (hLower[h] === nLower[n]) { indices.push(h); si = h; found = true; break; }
        }
        if (!found) { valid = false; break; }
      }
      if (!valid) continue;
      var score = 0, prevIdx = -2;
      for (var k = 0; k < indices.length; k++) {
        var idx = indices[k];
        score += SCORE_MATCH;
        var prev = idx > 0 ? haystack[idx - 1] : ' ';
        var bonus = positionBonus(prev, haystack[idx]);
        if (k === 0) bonus *= BONUS_FIRST_CHAR_MULT;
        score += bonus;
        if (prevIdx === idx - 1) score += BONUS_CONSECUTIVE;
        else if (k > 0) { var gap = idx - prevIdx - 1; score += SCORE_GAP_START + SCORE_GAP_EXTENSION * (gap - 1); }
        prevIdx = idx;
      }
      if (score > bestScore) { bestScore = score; bestIndices = indices; }
    }
    if (!bestIndices) return null;
    return { score: bestScore, indices: bestIndices };
  }

  function parseToken(token) {
    var negate = false, type = 'fuzzy', text = token;
    if (text.startsWith('!')) { negate = true; text = text.slice(1); }
    if (text.startsWith("'") && text.endsWith("'") && text.length > 2) { type = 'exact'; text = text.slice(1, -1); }
    else if (text.startsWith("'")) { type = 'exact'; text = text.slice(1); }
    else if (text.startsWith('^')) { type = 'prefix'; text = text.slice(1); }
    else if (text.endsWith('$')) { type = 'suffix'; text = text.slice(0, -1); }
    return { type: type, text: text, negate: negate };
  }

  function parseFzfQuery(query) {
    var tokens = query.split(/\s+/).filter(Boolean), groups = [], currentGroup = [];
    for (var i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token === '|') continue;
      if (token.startsWith('|')) currentGroup.push(parseToken(token.slice(1)));
      else if (token.endsWith('|')) { currentGroup.push(parseToken(token.slice(0, -1))); groups.push(currentGroup); currentGroup = []; }
      else { if (currentGroup.length > 0) { groups.push(currentGroup); currentGroup = []; } currentGroup = [parseToken(token)]; }
    }
    if (currentGroup.length > 0) groups.push(currentGroup);
    return groups;
  }

  function scoreToken(token, value) {
    var v = value.toLowerCase(), t = token.text.toLowerCase();
    switch (token.type) {
      case 'exact':  return v.includes(t) ? SCORE_SUBSTRING_BONUS + t.length * SCORE_MATCH : 0;
      case 'prefix': return v.startsWith(t) ? SCORE_PREFIX_BONUS + t.length * SCORE_MATCH : 0;
      case 'suffix': return v.endsWith(t) ? SCORE_SUBSTRING_BONUS + t.length * SCORE_MATCH : 0;
      case 'fuzzy': {
        if (v === t) return SCORE_EXACT_BONUS + t.length * SCORE_MATCH;
        if (v.includes(t)) return SCORE_SUBSTRING_BONUS + t.length * SCORE_MATCH;
        var m = fzfMatch(token.text, value);
        return m ? m.score : 0;
      }
    }
    return 0;
  }

  function searchScore(query, fields, mode) {
    if (!query) return 1;
    if (mode === 'regex') {
      try { var re = new RegExp(query, 'i'); return fields.some(function (f) { return re.test(f); }) ? 1 : 0; }
      catch (e) { return fields.some(function (f) { return f.toLowerCase().includes(query.toLowerCase()); }) ? 1 : 0; }
    }
    var groups = parseFzfQuery(query), totalScore = 0;
    for (var g = 0; g < groups.length; g++) {
      var orGroup = groups[g], bestGroupScore = 0;
      for (var ti = 0; ti < orGroup.length; ti++) {
        var token = orGroup[ti], tokenBest = 0;
        for (var fi = 0; fi < fields.length; fi++) {
          var fieldBonus = fi === 0 ? 500 : 0;
          var sc = scoreToken(token, fields[fi]);
          if (sc > 0 && sc + fieldBonus > tokenBest) tokenBest = sc + fieldBonus;
        }
        if (token.negate) { if (tokenBest > 0) return 0; bestGroupScore = 1; }
        else if (tokenBest > bestGroupScore) bestGroupScore = tokenBest;
      }
      if (bestGroupScore === 0) return 0;
      totalScore += bestGroupScore;
    }
    return totalScore;
  }

  function searchMatch(query, fields, mode) { return searchScore(query, fields, mode) > 0; }

  function getMatchIndices(query, text, mode) {
    if (!query || !text || mode === 'regex') return [];
    var groups = parseFzfQuery(query), allIndices = new Set();
    for (var g = 0; g < groups.length; g++) {
      for (var ti = 0; ti < groups[g].length; ti++) {
        var token = groups[g][ti];
        if (token.negate) continue;
        if (token.type === 'fuzzy') { var m = fzfMatch(token.text, text); if (m) m.indices.forEach(function (i) { allIndices.add(i); }); }
        else { var t = token.text.toLowerCase(), idx = text.toLowerCase().indexOf(t); if (idx >= 0) for (var i = idx; i < idx + t.length; i++) allIndices.add(i); }
      }
    }
    return [...allIndices].sort(function (a, b) { return a - b; });
  }

  function highlightWithIndices(text, indices) {
    if (!text) return '';
    if (!indices || indices.length === 0) return escapeHtml(text);
    var idxSet = new Set(indices), result = '', inMark = false;
    for (var i = 0; i < text.length; i++) {
      var ch = escapeHtml(text[i]);
      if (idxSet.has(i)) { if (!inMark) { result += '<mark class="fzf-hl">'; inMark = true; } result += ch; }
      else { if (inMark) { result += '</mark>'; inMark = false; } result += ch; }
    }
    if (inMark) result += '</mark>';
    return result;
  }

  global.FZF = {
    fzfMatch: fzfMatch, searchScore: searchScore, searchMatch: searchMatch,
    getMatchIndices: getMatchIndices, highlightWithIndices: highlightWithIndices, escapeHtml: escapeHtml,
  };
})(window);

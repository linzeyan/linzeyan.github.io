// Run via `make test`, which builds the site into a temp dir and passes it as SITE_OUT.
// Runs in headless Chrome (tests/browser.mjs): colours come from two
// stylesheets (toha's Sass palette on notes/search/404, its Tailwind tokens on
// the home page and posts) plus inline styles on code, so only the cascade a
// browser resolves says what the reader actually sees.
import { test, before, after } from 'node:test'
import assert from 'node:assert/strict'
import { readdirSync } from 'node:fs'
import { join } from 'node:path'
import { SITE_OUT, startBrowser } from './browser.mjs'

// One page per template, found in the build so that renaming a post or a note
// does not break the test.
function leaf(section, depth) {
  const pages = readdirSync(join(SITE_OUT, section), { recursive: true })
    .filter((p) => p.endsWith('/index.html') && p.split('/').length === depth + 1 && !p.split('/').includes('page'))
    .sort()
  assert.ok(pages.length, `no page ${depth} levels under ${section}/ in the build`)
  return `/${section}/${pages.at(-1).slice(0, -'index.html'.length)}`
}
const PAGES = ['/', '/posts/', leaf('posts', 2), '/notes/', leaf('notes', 2), '/tags/', '/search/', '/404.html']

// Run in the page. Any CSS colour syntax (rgb, oklch, color-mix results) is
// read back through a canvas pixel, so the check does not depend on how a
// stylesheet happens to write its colours.
const AUDIT = `(() => {
  const ctx = document.createElement('canvas').getContext('2d', { willReadFrequently: true });
  const seen = new Map();
  const rgba = (css) => {
    if (!seen.has(css)) { ctx.clearRect(0, 0, 1, 1); ctx.fillStyle = css; ctx.fillRect(0, 0, 1, 1); seen.set(css, [...ctx.getImageData(0, 0, 1, 1).data]); }
    return seen.get(css);
  };
  const name = (e) => e.tagName.toLowerCase() + (e.id ? '#' + e.id : '') + (typeof e.className === 'string' && e.className.trim() ? '.' + e.className.trim().split(/\\s+/).slice(0, 2).join('.') : '');
  const canvasOf = [document.body, document.documentElement].map((e) => rgba(getComputedStyle(e).backgroundColor)).find((c) => c[3] > 0);
  const blue = [];
  for (const e of document.querySelectorAll('*')) {
    const cs = getComputedStyle(e);
    if (cs.display === 'none' || cs.visibility === 'hidden') continue;
    const [r, g, b, a] = rgba(cs.backgroundColor);
    // Translucent accent washes (hover, active nav item) are not surfaces.
    if (a < 128) continue;
    const box = e.getBoundingClientRect();
    if (box.width * box.height < 400) continue;
    // A dark surface whose blue channel leads red is what reads as "blue-ish
    // black": slate-800 is 30,41,59 where a neutral grey would be 41,41,41.
    if (Math.max(r, g, b) <= 110 && b - r >= 6) blue.push(name(e) + ' rgb(' + [r, g, b].join(', ') + ')');
  }
  return { canvas: canvasOf ? 'rgb(' + canvasOf.slice(0, 3).join(', ') + ')' : 'none', blue: [...new Set(blue)] };
})()`

let browser
before(async () => { browser = await startBrowser() })
after(() => browser?.stop())

async function auditInDarkMode(path) {
  const reader = await browser.visitor('dark')
  await reader.goto(path)
  const found = await reader.run(AUDIT)
  await reader.leave()
  return found
}

// fb20261125a: 「暗背景色 要純黑 現在好像偏藍」. toha's dark palette is Tailwind
// slate (#1f2937 page, #1e293b cards, #0f172a footer), which reads as navy next
// to a black bezel or an OLED-black system UI. The dark scheme must be black,
// with neutral greys for raised surfaces, on every page: a theme upgrade or a
// newly enabled layout brings its own palette and would put the blue back on
// just the pages it owns.
for (const path of PAGES) {
  test(`regression fb20261125a: dark mode paints ${path} on pure black, with no blue-tinted surface`, { timeout: 60_000 }, async () => {
    // One comparison, so a failure lists the page background and every tinted surface together.
    assert.deepEqual(await auditInDarkMode(path), { canvas: 'rgb(0, 0, 0)', blue: [] }, `${path} in dark mode`)
  })
}

// Run via `make test`, which builds the site into a temp dir and passes it as SITE_OUT.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'
import vm from 'node:vm'

const SITE_OUT = process.env.SITE_OUT
if (!SITE_OUT) throw new Error('SITE_OUT is not set; run `make test`')

// The inline script in <head> is the only code that runs before first paint.
function headThemeScript(page) {
  const html = readFileSync(join(SITE_OUT, page), 'utf8')
  const head = html.slice(0, html.indexOf('</head>'))
  const scripts = [...head.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map((m) => m[1])
  const found = scripts.find((s) => s.includes('data-theme'))
  assert.ok(found, `${page}: no inline theme script in <head>`)
  return found
}

function firstPaintTheme(script, { stored = {}, osDark }) {
  let theme = null
  const sandbox = {
    localStorage: { getItem: (k) => (k in stored ? stored[k] : null) },
    window: { matchMedia: (q) => ({ matches: q.includes('dark') && osDark }) },
    document: { documentElement: { setAttribute: (k, v) => k === 'data-theme' && (theme = v) } },
  }
  vm.runInNewContext(script, sandbox)
  return theme
}

// `expected` is what the darkMode feature (hugo.yaml features.darkMode) sets on
// window load: localStorage 'darkmode:color-scheme', else 'system' resolved
// against the OS. If the site moves to the `theme` feature, its key changes to
// 'theme-scheme' and these cases must change with it.
const cases = [
  { name: 'first visit, OS dark', stored: {}, osDark: true, expected: 'dark' },
  { name: 'first visit, OS light', stored: {}, osDark: false, expected: 'light' },
  { name: 'stale theme-scheme=light from another site on the same origin, OS dark', stored: { 'theme-scheme': 'light' }, osDark: true, expected: 'dark' },
  { name: 'chose system, OS dark', stored: { 'darkmode:color-scheme': 'system' }, osDark: true, expected: 'dark' },
  { name: 'chose dark, OS light', stored: { 'darkmode:color-scheme': 'dark' }, osDark: false, expected: 'dark' },
  { name: 'chose light, stale theme-scheme=dark, OS dark', stored: { 'darkmode:color-scheme': 'light', 'theme-scheme': 'dark' }, osDark: true, expected: 'light' },
]

// fb20261112a: opening /notes/ showed the wrong colours, then switched to the
// right ones. A page that repaints itself after load looks broken, so what is
// painted first must already be final. Two causes, one test each:
//
// 1. Code blocks were coloured twice: Hugo's Chroma (monokai) at build time,
//    then highlight.js in deferred JS, which on /notes/ waits seconds behind
//    gist embeds. Code must be coloured once, at build time.
test('regression fb20261112a: code blocks are coloured at build time only', () => {
  const html = readFileSync(join(SITE_OUT, 'notes/index.html'), 'utf8')
  assert.match(html, /class="highlight"><pre[^>]*style="[^"]*background-color:#282c34/, 'notes/index.html: code blocks lack the build-time One Dark colours')
  const repainters = readdirSync(SITE_OUT, { recursive: true, withFileTypes: true })
    .filter((d) => d.isFile() && d.name.endsWith('.js'))
    .map((d) => join(d.parentPath, d.name))
    .filter((f) => readFileSync(f, 'utf8').includes('highlightAll'))
  assert.deepEqual(repainters, [], 'shipped JS re-colours code blocks in the browser after load')
})

// 2. The <head> script and the darkMode feature disagreed on the storage key and
//    the default, so a dark-mode reader got a light first paint until load.
for (const page of ['notes/index.html', 'index.html']) {
  test(`regression fb20261112a: first paint matches the settled theme on ${page}`, () => {
    const script = headThemeScript(page)
    for (const c of cases) {
      assert.equal(firstPaintTheme(script, c), c.expected, `${page}: ${c.name}`)
    }
  })
}

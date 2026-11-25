// Run via `make test`, which builds the site into a temp dir and passes it as SITE_OUT.
// The controls a reader clicks, driven in headless Chrome (tests/browser.mjs):
// all are built or wired by toha's scripts at runtime, so the HTML alone does
// not say whether they work.
import { test, before, after } from 'node:test'
import assert from 'node:assert/strict'
import { startBrowser } from './browser.mjs'

let browser
before(async () => { browser = await startBrowser() })
after(() => browser?.stop())

// Read from the painted page background, not from an attribute: it is the
// answer to "which scheme does the reader see", whatever each stylesheet keys on.
const SHOWN = `(() => {
  const ctx = document.createElement('canvas').getContext('2d');
  ctx.fillStyle = getComputedStyle(document.body).backgroundColor;
  ctx.fillRect(0, 0, 1, 1);
  const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data;
  return r + g + b < 384 ? 'dark' : 'light';
})()`

// The home page and posts are toha's Tailwind pages, notes its Bootstrap ones.
// Each family has its own theme switch and its own localStorage key, and
// neither reads the other's, so a reader who switched to light on the home page
// got dark again on Notes. The menu links the two families on every page; the
// choice has to follow the reader across it, in both directions
// (assets/scripts/core/theme-scheme.js).
test('a theme chosen on the home page holds on Notes, and the other way round', { timeout: 60_000 }, async () => {
  const reader = await browser.visitor('dark')
  await reader.goto('/')
  assert.equal(await reader.run(SHOWN), 'dark', 'first visit follows the OS')

  await reader.click('.components-theme-toggle')
  assert.equal(await reader.run(SHOWN), 'light', 'the home page toggle')
  await reader.goto('/notes/')
  assert.equal(await reader.run(SHOWN), 'light', 'Notes after choosing light on the home page')

  await reader.click('#themeMenu a[data-scheme="dark"]')
  assert.equal(await reader.run(SHOWN), 'dark', 'the Notes menu')
  await reader.goto('/posts/')
  assert.equal(await reader.run(SHOWN), 'dark', 'Posts after choosing dark on Notes')

  await reader.click('.components-theme-toggle')
  await reader.goto('/notes/')
  assert.equal(await reader.run(SHOWN), 'light', 'Notes after switching back on Posts')
  await reader.click('#themeMenu a[data-scheme="system"]')
  await reader.goto('/')
  assert.equal(await reader.run(SHOWN), 'dark', 'the home page follows the OS again once Notes is set to system')
  await reader.leave()
})

// Notes are mostly commands to paste into a terminal, so each code block gets a
// Copy button (hugo.yaml features.codeBlock.copyButton). The button must put
// the code as written on the clipboard, not the highlighter's markup.
test('every code block in Notes has a Copy button that copies its code', { timeout: 60_000 }, async () => {
  const reader = await browser.visitor('dark')
  await reader.goto('/notes/')
  const blocks = await reader.run(`({
    code: document.querySelectorAll('.note-card .highlight').length,
    withButton: [...document.querySelectorAll('.note-card .highlight')].filter((h) => h.closest('.code-block')?.querySelector('.code-block-copy')).length,
    first: document.querySelector('.code-block pre').textContent,
  })`)
  assert.ok(blocks.code > 0, 'no code blocks on /notes/')
  assert.equal(blocks.withButton, blocks.code, 'code blocks without a Copy button')

  await reader.click('.code-block .code-block-copy')
  assert.equal((await reader.run('navigator.clipboard.readText()')).trimEnd(), blocks.first.trimEnd())
  await reader.leave()
})

// The project cards are grouped the way the profile README groups them
// (data/*/sections/projects.yaml: a button filters on a tag, and a project's
// first tag is its category). The pills are how a reader gets from 35 cards to
// "the iOS apps": a project with no category could only be found under All,
// and a pill that shows nothing is a dead end. So every card has to sit under
// exactly one pill, and its first chip has to say which.
test('Projects open on All, and every project is under exactly one category pill', { timeout: 60_000 }, async () => {
  for (const home of ['/', '/zh-tw/']) {
    const reader = await browser.visitor('dark')
    await reader.goto(home)
    const seen = await reader.run(`(() => {
      const pills = [...document.querySelectorAll('[data-filter-group="projects"] .filter-pill')]
      const cards = [...document.querySelectorAll('#projects article')]
      const label = (e) => e?.textContent.trim()
      const pressed = () => pills.filter((p) => p.getAttribute('aria-pressed') === 'true').map(label)
      // What is laid out, not the hidden attribute: a display rule on the card would override that.
      const shown = () => cards.filter((c) => c.getClientRects().length > 0)
      const open = { pressed: pressed(), shown: shown().length }
      const categories = pills.slice(1).map((pill) => {
        pill.click()
        return {
          pill: label(pill),
          pressed: pressed(),
          projects: shown().map((c) => label(c.querySelector('.project-title'))),
          firstChips: [...new Set(shown().map((c) => label(c.querySelector('.modern-tag'))))],
        }
      })
      pills[0]?.click()
      return {
        first: { pill: label(pills[0]), filter: pills[0]?.dataset.filter },
        projects: cards.map((c) => label(c.querySelector('.project-title'))),
        open,
        categories,
        backOnAll: shown().length,
      }
    })()`)

    assert.ok(seen.projects.length > 0, `${home}: no project cards`)
    assert.equal(seen.first.filter, 'all', `${home}: the first pill should be All`)
    assert.deepEqual(seen.open, { pressed: [seen.first.pill], shown: seen.projects.length }, `${home}: the section should open on All with every project shown`)
    assert.ok(seen.categories.length > 0, `${home}: no category pills`)
    for (const category of seen.categories) {
      assert.deepEqual(category.pressed, [category.pill], `${home}: clicking ${category.pill} should press it alone`)
      assert.ok(category.projects.length > 0, `${home}: ${category.pill} shows no project`)
      assert.deepEqual(category.firstChips, [category.pill], `${home}: the first chip of every card under ${category.pill}`)
    }
    assert.deepEqual(seen.categories.flatMap((c) => c.projects).sort(), [...seen.projects].sort(), `${home}: every project under exactly one category`)
    assert.equal(seen.backOnAll, seen.projects.length, `${home}: All should bring every project back`)
    await reader.leave()
  }
})

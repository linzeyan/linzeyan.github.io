// Run via `make test`, which builds the site into a temp dir and passes it as SITE_OUT.
// The social links in the hero are icons with no text, and the footer's carry
// only a name, so the icon is what says where a link goes. toha has an icon for
// a few networks and draws every other link as a globe: Hugging Face, Telegram
// and Facebook were three identical globes in the hero, Strava and Telegram two
// more in the footer. assets/styles/modern/site.css lays a brand glyph over
// those. Whether it shows is decided by the cascade, so this asks a browser
// (tests/browser.mjs).
import { test, before, after } from 'node:test'
import assert from 'node:assert/strict'
import { startBrowser } from './browser.mjs'

let browser
before(async () => { browser = await startBrowser() })
after(() => browser?.stop())

// The networks we link to that toha has no icon for.
const BRAND_HOSTS = ['huggingface.co', 't.me', 'fb.me', 'www.strava.com']

const SOCIAL_LINKS = `Promise.all([...document.querySelectorAll('.hero-social-link, .footer-contact-list a')].map(async (a) => {
  const svg = a.querySelector('svg')
  const style = getComputedStyle(svg)
  const glyph = style.maskImage === 'none' ? null : style.maskImage
  let decodes = null
  if (glyph) {
    const image = new Image()
    image.src = glyph.slice('url("'.length, -'")'.length)
    decodes = await image.decode().then(() => true, () => false)
  }
  return {
    group: a.matches('.hero-social-link') ? 'hero' : 'footer',
    to: a.href,
    host: new URL(a.href).host,
    glyph,
    decodes,
    inked: style.backgroundColor === style.color,
    strokes: getComputedStyle(svg.firstElementChild).stroke !== 'none',
    // What tells this icon from the next one: the glyph laid over it, else the shape the theme drew.
    looks: glyph ?? svg.firstElementChild.getAttribute('d'),
  }
}))`

test('each social link has an icon of its own, and the brands toha does not know show their glyph', { timeout: 60_000 }, async () => {
  for (const home of ['/', '/zh-tw/']) {
    const reader = await browser.visitor('dark')
    await reader.goto(home)
    const links = await reader.run(SOCIAL_LINKS)
    await reader.leave()

    const brands = links.filter((l) => BRAND_HOSTS.includes(l.host))
    assert.deepEqual([...new Set(brands.map((l) => l.host))].sort(), [...BRAND_HOSTS].sort(), `${home}: the brand links on the page`)
    for (const link of links) {
      if (link.glyph) {
        assert.deepEqual({ decodes: link.decodes, inked: link.inked, strokes: link.strokes }, { decodes: true, inked: true, strokes: false },
          `${home}: ${link.to} should show a glyph that loads, in the link colour, with the theme's own icon switched off`)
      } else {
        assert.ok(!BRAND_HOSTS.includes(link.host), `${home}: ${link.to} (${link.group}) still shows the theme's fallback icon`)
        assert.ok(link.strokes, `${home}: ${link.to} lost the icon the theme drew for it`)
      }
    }

    for (const group of ['hero', 'footer']) {
      const inGroup = links.filter((l) => l.group === group)
      assert.ok(inGroup.length > 0, `${home}: no social links in the ${group}`)
      const twins = inGroup.filter((l) => inGroup.some((other) => other !== l && other.looks === l.looks)).map((l) => l.to)
      assert.deepEqual(twins, [], `${home}: links in the ${group} that share one icon`)
    }
    const byDestination = Map.groupBy(links, (l) => l.to)
    for (const [to, same] of byDestination) {
      assert.equal(new Set(same.map((l) => l.looks)).size, 1, `${home}: ${to} has a different icon in the hero and in the footer`)
    }
  }
})

// Headless Chrome for the tests that need what only a browser knows: the colour
// the cascade resolves to, and what the theme's own scripts do when the reader
// clicks a control. Serves SITE_OUT on a local port and drives Chrome over the
// DevTools protocol with Node's built-in WebSocket (Node 22+), so there is no
// test dependency to install. Nothing opens on screen.
// Chrome is looked up at its macOS path; set CHROME to any Chromium binary.
import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import { createServer } from 'node:http'
import { existsSync, mkdtempSync, readFileSync, rmSync, statSync } from 'node:fs'
import { extname, join } from 'node:path'
import { tmpdir } from 'node:os'

export const SITE_OUT = process.env.SITE_OUT
if (!SITE_OUT) throw new Error('SITE_OUT is not set; run `make test`')
const CHROME = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.json': 'application/json', '.woff2': 'font/woff2' }

const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

export async function startBrowser() {
  assert.ok(existsSync(CHROME), `Google Chrome not found at ${CHROME}; set CHROME=<path to a Chromium binary>`)
  const server = createServer((req, res) => {
    let f = join(SITE_OUT, decodeURIComponent(new URL(req.url, 'http://x').pathname))
    if (existsSync(f) && statSync(f).isDirectory()) f = join(f, 'index.html')
    if (!existsSync(f)) return res.writeHead(404).end()
    res.writeHead(200, { 'content-type': MIME[extname(f)] || 'application/octet-stream' }).end(readFileSync(f))
  })
  await new Promise((r) => server.listen(0, '127.0.0.1', r))
  const base = `http://127.0.0.1:${server.address().port}`

  const profile = mkdtempSync(join(tmpdir(), 'site-test-chrome-'))
  // Embeds and analytics are not ours to test; failing their DNS keeps the
  // load event from waiting on the network.
  const chrome = spawn(CHROME, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`, '--no-first-run',
    '--host-resolver-rules=MAP * ~NOTFOUND, EXCLUDE 127.0.0.1', 'about:blank'], { stdio: ['ignore', 'ignore', 'pipe'] })
  const wsUrl = await new Promise((ok, fail) => {
    let buf = ''
    chrome.stderr.on('data', (d) => { buf += d; const m = buf.match(/DevTools listening on (ws:\/\/\S+)/); if (m) ok(m[1]) })
    chrome.on('exit', (code) => fail(new Error(`Chrome exited with ${code} before DevTools came up`)))
  })
  const ws = new WebSocket(wsUrl)
  await new Promise((r) => ws.addEventListener('open', r, { once: true }))
  let id = 0
  const pending = new Map()
  const listeners = new Set()
  ws.addEventListener('message', (e) => {
    const m = JSON.parse(e.data)
    if (m.id) { pending.get(m.id)(m); pending.delete(m.id) } else listeners.forEach((l) => l(m))
  })
  const send = (method, params = {}, sessionId) => new Promise((ok) => { pending.set(++id, ok); ws.send(JSON.stringify({ id, method, params, sessionId })) })

  return {
    // One reader: a fresh browser profile (nothing in localStorage, so both of
    // toha's theme switches follow the OS) on a machine whose OS asks for `osScheme`.
    async visitor(osScheme) {
      const { result: { browserContextId } } = await send('Target.createBrowserContext')
      await send('Browser.grantPermissions', { browserContextId, origin: base, permissions: ['clipboardReadWrite', 'clipboardSanitizedWrite'] })
      const { result: { targetId } } = await send('Target.createTarget', { url: 'about:blank', browserContextId })
      const { result: { sessionId } } = await send('Target.attachToTarget', { targetId, flatten: true })
      const s = (m, p) => send(m, p, sessionId)
      await s('Page.enable')
      await s('Emulation.setDeviceMetricsOverride', { width: 1280, height: 800, deviceScaleFactor: 1, mobile: false })
      await s('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: osScheme }] })
      // The clipboard refuses a document that is not focused, which a headless tab never is.
      await s('Emulation.setFocusEmulationEnabled', { enabled: true })

      const run = async (expression) => {
        const res = await s('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true, userGesture: true })
        const failure = res.error ?? res.result?.exceptionDetails
        assert.ok(!failure, `in-page script failed: ${JSON.stringify(failure)}\n${expression}`)
        return res.result.result.value
      }
      return {
        run,
        async goto(path) {
          let loaded = false
          const onEvent = (m) => { if (m.sessionId === sessionId && m.method === 'Page.loadEventFired') loaded = true }
          listeners.add(onEvent)
          await s('Page.navigate', { url: base + path })
          for (let i = 0; i < 200 && !loaded; i++) await sleep(50)
          listeners.delete(onEvent)
          assert.ok(loaded, `${path}: no load event within 10 s`)
          // The Bootstrap pages apply the scheme and build their controls in window load handlers.
          await sleep(300)
        },
        async click(selector) {
          const found = await run(`(() => { const e = document.querySelector(${JSON.stringify(selector)}); if (e) e.click(); return !!e })()`)
          assert.ok(found, `nothing matches ${selector}`)
          // The theme fades colours over 0.3 s; a reading taken sooner is mid-transition.
          await sleep(500)
        },
        leave: () => send('Target.disposeBrowserContext', { browserContextId }),
      }
    },
    async stop() {
      ws.close()
      chrome.kill()
      server.close()
      await sleep(300)
      rmSync(profile, { recursive: true, force: true })
    },
  }
}

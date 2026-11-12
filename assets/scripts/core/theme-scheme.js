// Overrides toha v4.16.0's scripts/core/theme-scheme.js, the only theme code
// that runs in <head> before first paint. Upstream prefers the 'theme-scheme'
// key and falls back to 'light', while the darkMode feature we enable
// (hugo.yaml) runs on window load, reads only 'darkmode:color-scheme' and falls
// back to 'system'. When the two disagree the page paints one scheme and flips
// at load, which /notes/ (gist embeds delay load) makes visible. Mirroring the
// feature makes its later write a no-op. Pinned by tests/regression-theme.test.mjs.
let theme = localStorage.getItem('darkmode:color-scheme') || 'system'
if (theme === 'system') {
  theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}
document.documentElement.setAttribute('data-theme', theme)

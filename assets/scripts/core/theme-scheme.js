// The only theme code that runs in <head> before first paint, on every page.
// toha loads it under this name on its Bootstrap pages (notes, search, 404)
// and, through a mount in hugo.yaml, as scripts/modern/theme-init.js on its
// Tailwind pages (home, posts, tags).
//
// One script for both because the two page families keep the reader's choice
// in different keys and never read each other's: the Bootstrap menu writes
// 'darkmode:color-scheme' (system | dark | light), the Tailwind toggle writes
// 'toha-modern-theme' (dark | light; absent means system). Left alone,
// switching to light on the home page and then opening Notes shows dark again.
// Neither toggle is ours to change, so the keys are reconciled here: the one
// that moved away from the value both agreed on at the previous page load is
// the one the reader just used, and its value is copied to the other.
//
// What is painted here must also be what the page's own code settles on after
// load; when the two differ the page flips, which /notes/ makes visible because
// gist embeds delay load. The Bootstrap darkMode feature (hugo.yaml) re-applies
// 'darkmode:color-scheme' on window load and falls back to 'system'; the
// Tailwind shell keeps whatever class it finds. Pinned by
// tests/regression-theme.test.mjs.
{
  const known = (value) => (value === 'dark' || value === 'light' ? value : 'system')
  let choice = 'system'
  try {
    const agreed = localStorage.getItem('site:color-scheme')
    const bootstrap = known(localStorage.getItem('darkmode:color-scheme'))
    const tailwind = known(localStorage.getItem('toha-modern-theme'))
    // No agreed value yet (first visit since this script shipped): the
    // Bootstrap key is the only one a returning reader can have.
    choice = bootstrap !== agreed ? bootstrap : tailwind
    localStorage.setItem('site:color-scheme', choice)
    localStorage.setItem('darkmode:color-scheme', choice)
    if (choice === 'system') localStorage.removeItem('toha-modern-theme')
    else localStorage.setItem('toha-modern-theme', choice)
  } catch {
    // Storage is blocked: follow the OS, as both toggles do.
  }
  const dark = choice === 'dark' || (choice === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)
  document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light')
  document.documentElement.classList.toggle('dark', dark)
}

---
title: "Shell Script Best Practices"
date: 2022-11-03T16:51:11+08:00
menu:
  sidebar:
    name: "Shell Script Best Practices"
    identifier: linux-shell-script-best-practices
    weight: 10
tags: ["URL", "SHELL", "Linux"]
categories: ["URL", "SHELL", "Linux"]
hero: images/hero/linux.png
---

- [Shell Script Best Practices](https://sharats.me/posts/shell-script-best-practices/)

#### Things

1. Just make the first line be `#!/usr/bin/env bash`.
2. Use the `.sh` (or `.bash`) extension for your file.
3. Use `set -o errexit` at the start of your script.
4. Prefer to use `set -o nounset`.
   1. use `"${VARNAME-}"` instead of `"$VARNAME"`
5. Use `set -o pipefail`.
6. Use `set -o xtrace`, with a check on `$TRACE` env variable.
   1. `if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi`
   2. People can now enable debug mode, by running your script as `TRACE=1 ./script.sh` instead of `./script.sh`.
7. Use `[[ ]]` for conditions in `if` / `while` statements, instead of `[ ]` or `test`.
8. Always quote variable accesses with double-quotes.
9. Use `local` variables in functions.
10. When printing error messages, please redirect to stderr.
    1. Use `echo 'Something unexpected happened' >&2` for this.
11. Use long options, where possible (like `--silent` instead of `-s`).
12. If appropriate, change to the script's directory close to the start of the script.
    1. Use cd "$(dirname "$0")", which works in most cases.
13. Use `shellcheck`. Heed its warnings.

#### Template

```bash
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh arg-one arg-two

This is an awesome bash script to make your life better.

'
    exit
fi

cd "$(dirname "$0")"

main() {
    echo do awesome stuff
}

main "$@"
```

---
title: "Shell Script 最佳實務"
date: 2022-11-03T16:51:11+08:00
menu:
  sidebar:
    name: "Shell Script 最佳實務"
    identifier: linux-shell-script-best-practices
    weight: 10
tags: ["Links", "SHELL", "Linux"]
categories: ["Links", "SHELL", "Linux"]
hero: images/hero/linux.png
---

- [Shell Script 最佳實務](https://sharats.me/posts/shell-script-best-practices/)

#### 重點

1. 第一行就用 `#!/usr/bin/env bash`。
2. 檔案使用 `.sh`（或 `.bash`）副檔名。
3. 在腳本開頭使用 `set -o errexit`。
4. 也建議使用 `set -o nounset`。
   1. 用 `"${VARNAME-}"` 取代 `"$VARNAME"`
5. 使用 `set -o pipefail`。
6. 使用 `set -o xtrace`，並檢查 `$TRACE` 環境變數。
   1. `if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi`
   2. 使用者可以透過 `TRACE=1 ./script.sh` 啟用除錯模式，而不是 `./script.sh`。
7. `if` / `while` 條件使用 `[[ ]]`，而不是 `[ ]` 或 `test`。
8. 變數存取一律用雙引號包住。
9. 在函式中使用 `local` 變數。
10. 輸出錯誤訊息時請導向 stderr。
    1. 例如 `echo 'Something unexpected happened' >&2`。
11. 能用長選項就用長選項（例如 `--silent` 取代 `-s`）。
12. 適合的話，腳本開頭就切換到腳本所在目錄。
    1. 可用 `cd "$(dirname "$0")"`，多數情況可用。
13. 使用 `shellcheck` 並留意其警告。

#### 範本

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

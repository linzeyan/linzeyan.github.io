#!/usr/bin/env bash
# 關閉常見開發工具的 telemetry(Linux / macOS)
#
# 用法:
#   bash disable-telemetry.sh            套用
#   bash disable-telemetry.sh --dry-run  只顯示會做什麼，不實際變更
#   bash disable-telemetry.sh --undo     移除本腳本加入的環境變數設定
#
# 做兩件事:
#   1. 把環境變數寫進 ~/.config/telemetry-optout/env.sh(fish 另寫一份),
#      並在 shell 啟動檔加一行 source。重複執行不會重複加入。
#   2. 對「已安裝」的工具執行它們自己的關閉指令(沒裝的會跳過)。
#
# 相容 macOS 內建的 bash 3.2。

set -u

MODE="apply"
case "${1:-}" in
  --dry-run) MODE="dry" ;;
  --undo)    MODE="undo" ;;
  "")        ;;
  -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
  *) echo "未知參數: $1(可用 --dry-run / --undo)" >&2; exit 1 ;;
esac

ENV_VARS=(
  "DO_NOT_TRACK=1"
  "DOTNET_CLI_TELEMETRY_OPTOUT=1"
  "HOMEBREW_NO_ANALYTICS=1"
  "POWERSHELL_TELEMETRY_OPTOUT=1"
  "NEXT_TELEMETRY_DISABLED=1"
  "NUXT_TELEMETRY_DISABLED=1"
  "ASTRO_TELEMETRY_DISABLED=1"
  "GATSBY_TELEMETRY_DISABLED=1"
  "TURBO_TELEMETRY_DISABLED=1"
  "STORYBOOK_DISABLE_TELEMETRY=1"
  "EXPO_NO_TELEMETRY=1"
  "NG_CLI_ANALYTICS=false"
  "YARN_ENABLE_TELEMETRY=0"
  "PRISMA_DISABLE_TELEMETRY=1"
  "CHECKPOINT_DISABLE=1"
  "AZURE_CORE_COLLECT_TELEMETRY=0"
  "SAM_CLI_TELEMETRY=0"
  "CDK_DISABLE_CLI_TELEMETRY=true"
  "VERCEL_TELEMETRY_DISABLED=1"
  "NETLIFY_TELEMETRY_DISABLED=1"
  "WRANGLER_SEND_METRICS=false"
  "STRIPE_CLI_TELEMETRY_OPTOUT=1"
  "SF_DISABLE_TELEMETRY=true"
  "HF_HUB_DISABLE_TELEMETRY=1"
  "CONDA_ANACONDA_ANON_USAGE=no"
  "TILT_DISABLE_ANALYTICS=true"
  "DISABLE_TELEMETRY=1"
)

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/telemetry-optout"
ENV_FILE="$CONF_DIR/env.sh"
FISH_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/telemetry-optout.fish"
MARK_BEGIN="# >>> telemetry-optout >>>"
MARK_END="# <<< telemetry-optout <<<"

OS="$(uname -s)"
say()  { printf '%s\n' "$*"; }
run()  { if [ "$MODE" = "dry" ]; then say "  [dry-run] $*"; else "$@"; fi; }
has()  { command -v "$1" >/dev/null 2>&1; }

# 要掛 source 的啟動檔:已存在的都掛;再依系統補上預設 shell 的檔案
rc_files() {
  local f list=""
  for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$f" ] && list="$list $f"
  done
  if [ "$OS" = "Darwin" ]; then
    case "$list" in *".zshrc"*) ;; *) list="$list $HOME/.zshrc" ;; esac
  else
    case "$list" in *".bashrc"*) ;; *) list="$list $HOME/.bashrc" ;; esac
  fi
  echo "$list"
}

# 從檔案移除標記區塊(用 awk,避開 macOS / GNU sed -i 的差異)
strip_block() {
  local f="$1" tmp
  [ -f "$f" ] || return 0
  grep -qF "$MARK_BEGIN" "$f" || return 0
  tmp="$(mktemp)"
  # 連同區塊前面那一行空白一起移除，重複執行才不會累積空行
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0==b  {skip=1; blank=0; next}
    $0==e  {skip=0; next}
    skip   {next}
    $0=="" {blank++; next}
           {while (blank>0) {print ""; blank--} print}
    END    {while (blank>0) {print ""; blank--}}
  ' "$f" > "$tmp" && cat "$tmp" > "$f"   # cat 覆寫，保留原檔權限與 symlink
  rm -f "$tmp"
}

# ---------- 復原 ----------
if [ "$MODE" = "undo" ]; then
  for f in $(rc_files); do
    if [ -f "$f" ] && grep -qF "$MARK_BEGIN" "$f"; then strip_block "$f"; say "已清除: $f"; fi
  done
  rm -f "$ENV_FILE" "$FISH_FILE"
  rmdir "$CONF_DIR" 2>/dev/null
  say "環境變數設定已移除，重開終端機後生效。"
  say "(各工具指令關閉的設定不會自動改回，需要的話請用各工具的 enable 指令)"
  exit 0
fi

# ---------- 1. 環境變數 ----------
say "== 寫入環境變數 =="
if [ "$MODE" = "dry" ]; then
  say "  [dry-run] 寫入 $ENV_FILE(${#ENV_VARS[@]} 個變數)"
else
  mkdir -p "$CONF_DIR"
  {
    echo "# 由 disable-telemetry.sh 產生，重新執行腳本會覆寫"
    for kv in "${ENV_VARS[@]}"; do echo "export $kv"; done
  } > "$ENV_FILE"
  say "  $ENV_FILE"
fi

for f in $(rc_files); do
  if [ "$MODE" = "dry" ]; then
    say "  [dry-run] 在 $f 加入 source"
    continue
  fi
  strip_block "$f"
  printf '\n%s\n[ -f "%s" ] && . "%s"\n%s\n' \
    "$MARK_BEGIN" "$ENV_FILE" "$ENV_FILE" "$MARK_END" >> "$f"
  say "  $f"
done

if [ -d "$(dirname "$(dirname "$FISH_FILE")")" ] || has fish; then
  if [ "$MODE" = "dry" ]; then
    say "  [dry-run] 寫入 $FISH_FILE"
  else
    mkdir -p "$(dirname "$FISH_FILE")"
    {
      echo "# 由 disable-telemetry.sh 產生"
      for kv in "${ENV_VARS[@]}"; do echo "set -gx ${kv%%=*} ${kv#*=}"; done
    } > "$FISH_FILE"
    say "  $FISH_FILE"
  fi
fi

# 讓本次執行的工具指令也套用到這些變數
# shellcheck disable=SC2163  # 刻意用 export "NAME=VALUE"
for kv in "${ENV_VARS[@]}"; do export "$kv"; done

# ---------- 2. 各工具的關閉指令 ----------
say ""
say "== 執行已安裝工具的關閉指令 =="
did=0
tool() {  # tool <執行檔> <顯示名稱> <指令...>
  local bin="$1" name="$2"; shift 2
  has "$bin" || return 0
  did=1
  say "  $name"
  if [ "$MODE" = "dry" ]; then say "    [dry-run] $*"; return 0; fi
  "$@" >/dev/null 2>&1 || say "    (指令失敗，可能是版本不支援，可略過)"
}

tool brew    "Homebrew"       brew analytics off
tool go      "Go"             go telemetry off
tool flutter "Flutter"        flutter --disable-analytics
tool dart    "Dart"           dart --disable-analytics
tool az      "Azure CLI"      az config set core.collect_telemetry=no
tool gcloud  "gcloud"         gcloud config set disable_usage_reporting true
tool conda   "Conda"          conda config --set anaconda_anon_usage off
tool sf      "Salesforce CLI" sf config set disable-telemetry=true --global
tool ng      "Angular CLI"    ng analytics disable --global
tool turbo   "Turborepo"      turbo telemetry disable
tool vercel  "Vercel CLI"     vercel telemetry disable
tool netlify "Netlify CLI"    netlify --telemetry-disable
tool wrangler "Wrangler"      wrangler telemetry disable
tool tilt    "Tilt"           tilt analytics opt out
# Yarn:只有 Berry(v2+)有 telemetry,v1 沒有這個設定
if has yarn; then
  case "$(yarn --version 2>/dev/null)" in
    1.*|"") ;;
    *) tool yarn "Yarn Berry" yarn config set --home enableTelemetry 0 ;;
  esac
fi
[ "$did" = 0 ] && say "  (沒有偵測到需要額外指令的工具)"

# ---------- 3. 需要手動處理的 ----------
say ""
say "== 需要手動處理 =="
say "  VS Code: settings.json 加上 \"telemetry.telemetryLevel\": \"off\""
if [ "$OS" = "Darwin" ]; then
  say "  macOS: 從 Dock / Finder 開的 GUI App 不會讀 shell 啟動檔，"
  say "         VS Code 等請用上面的應用程式內設定關閉。"
fi
say ""
say "完成。請重開終端機(或執行 . \"$ENV_FILE\")讓環境變數生效。"

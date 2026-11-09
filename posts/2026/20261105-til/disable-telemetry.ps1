<#
.SYNOPSIS
  關閉常見開發工具的 telemetry(Windows)。

.DESCRIPTION
  1. 把環境變數寫成「使用者層級」的環境變數，所有終端機與 GUI 程式都讀得到。
  2. 對已安裝的工具執行它們自己的關閉指令(沒裝的會跳過)。
  3. 修改 winget 的 settings.json(需要 PowerShell 7 才能解析含註解的 JSON)。

  Windows PowerShell 5.1 與 PowerShell 7 都能執行，不需要系統管理員權限。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\disable-telemetry.ps1
  powershell -ExecutionPolicy Bypass -File .\disable-telemetry.ps1 -DryRun
  powershell -ExecutionPolicy Bypass -File .\disable-telemetry.ps1 -Undo
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$Undo
)

$EnvVars = [ordered]@{
  DO_NOT_TRACK                 = '1'
  DOTNET_CLI_TELEMETRY_OPTOUT  = '1'
  POWERSHELL_TELEMETRY_OPTOUT  = '1'
  NEXT_TELEMETRY_DISABLED      = '1'
  NUXT_TELEMETRY_DISABLED      = '1'
  ASTRO_TELEMETRY_DISABLED     = '1'
  GATSBY_TELEMETRY_DISABLED    = '1'
  TURBO_TELEMETRY_DISABLED     = '1'
  STORYBOOK_DISABLE_TELEMETRY  = '1'
  EXPO_NO_TELEMETRY            = '1'
  NG_CLI_ANALYTICS             = 'false'
  YARN_ENABLE_TELEMETRY        = '0'
  PRISMA_DISABLE_TELEMETRY     = '1'
  CHECKPOINT_DISABLE           = '1'
  AZURE_CORE_COLLECT_TELEMETRY = '0'
  SAM_CLI_TELEMETRY            = '0'
  CDK_DISABLE_CLI_TELEMETRY    = 'true'
  VERCEL_TELEMETRY_DISABLED    = '1'
  NETLIFY_TELEMETRY_DISABLED   = '1'
  WRANGLER_SEND_METRICS        = 'false'
  STRIPE_CLI_TELEMETRY_OPTOUT  = '1'
  SF_DISABLE_TELEMETRY         = 'true'
  HF_HUB_DISABLE_TELEMETRY     = '1'
  CONDA_ANACONDA_ANON_USAGE    = 'no'
  TILT_DISABLE_ANALYTICS       = 'true'
  DISABLE_TELEMETRY            = '1'
}

if ($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) {
  Write-Host "這支腳本是給 Windows 用的;Linux / macOS 請執行 disable-telemetry.sh"
  exit 1
}

# 只認真正的執行檔 / 腳本(.exe .cmd .bat .ps1),避免同名的 alias 或 function 被誤判為已安裝
function Has($cmd) {
  [bool](Get-Command $cmd -CommandType Application, ExternalScript -ErrorAction SilentlyContinue)
}

# ---------- 復原 ----------
if ($Undo) {
  foreach ($name in $EnvVars.Keys) {
    if ($DryRun) { Write-Host "  [dry-run] 移除 $name"; continue }
    [Environment]::SetEnvironmentVariable($name, $null, 'User')
    Remove-Item "Env:\$name" -ErrorAction SilentlyContinue
  }
  Write-Host "使用者環境變數已移除，重開終端機後生效。"
  Write-Host "(各工具指令關閉的設定不會自動改回，需要的話請用各工具的 enable 指令)"
  return
}

# ---------- 1. 環境變數 ----------
Write-Host "== 寫入使用者環境變數 =="
foreach ($name in $EnvVars.Keys) {
  $value = $EnvVars[$name]
  if ($DryRun) { Write-Host "  [dry-run] $name=$value"; continue }
  [Environment]::SetEnvironmentVariable($name, $value, 'User')
  Set-Item "Env:\$name" $value     # 本次執行的工具指令也套用
}
if (-not $DryRun) { Write-Host "  已寫入 $($EnvVars.Count) 個變數" }

# ---------- 2. 各工具的關閉指令 ----------
Write-Host ""
Write-Host "== 執行已安裝工具的關閉指令 =="
$script:ran = @()
$script:skipped = @()
function Tool($bin, $label, [string[]]$cmdArgs) {
  if (-not (Has $bin)) { $script:skipped += $label; return }
  $script:ran += $label
  Write-Host "  $label"
  if ($DryRun) { Write-Host "    [dry-run] $bin $($cmdArgs -join ' ')"; return }
  try {
    $global:LASTEXITCODE = 0
    & $bin @cmdArgs *> $null
    if ($LASTEXITCODE -ne 0) { Write-Host "    (指令失敗，可能是版本不支援，可略過)" }
  } catch { Write-Host "    (指令失敗:$($_.Exception.Message))" }
}

Tool go       'Go'             @('telemetry','off')
Tool flutter  'Flutter'        @('--disable-analytics')
Tool dart     'Dart'           @('--disable-analytics')
Tool az       'Azure CLI'      @('config','set','core.collect_telemetry=no')
Tool gcloud   'gcloud'         @('config','set','disable_usage_reporting','true')
Tool conda    'Conda'          @('config','--set','anaconda_anon_usage','off')
Tool sf       'Salesforce CLI' @('config','set','disable-telemetry=true','--global')
Tool ng       'Angular CLI'    @('analytics','disable','--global')
Tool turbo    'Turborepo'      @('telemetry','disable')
Tool vercel   'Vercel CLI'     @('telemetry','disable')
Tool netlify  'Netlify CLI'    @('--telemetry-disable')
Tool wrangler 'Wrangler'       @('telemetry','disable')
Tool tilt     'Tilt'           @('analytics','opt','out')
if (Has yarn) {
  $yv = [string](& yarn --version 2>$null | Select-Object -First 1)
  if ($yv -and -not $yv.StartsWith('1.')) {
    Tool yarn 'Yarn Berry' @('config','set','--home','enableTelemetry','0')
  }
  # Yarn 1.x 沒有 telemetry,不需處理
} else {
  $script:skipped += 'Yarn Berry'
}
if ($script:ran.Count -eq 0) { Write-Host "  (沒有偵測到已安裝的工具)" }
if ($script:skipped.Count -gt 0) {
  Write-Host ""
  Write-Host "  未安裝，已略過:$($script:skipped -join ', ')"
  Write-Host "  (這些工具之後安裝了，靠上面的環境變數多半已經關閉;要補跑指令就再執行一次本腳本)"
}

# ---------- 3. winget ----------
Write-Host ""
Write-Host "== winget =="
$wingetPaths = @(
  "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json",
  "$env:LOCALAPPDATA\Microsoft\WinGet\Settings\settings.json"
)
$wingetFile = $wingetPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not (Has winget)) {
  Write-Host "  未安裝，略過"
} elseif (-not $wingetFile) {
  # 還沒有設定檔：直接建立一個
  $wingetFile = $wingetPaths[0]
  if ($DryRun) { Write-Host "  [dry-run] 建立 $wingetFile" }
  elseif (Test-Path (Split-Path $wingetFile)) {
    '{ "telemetry": { "disable": true } }' | Set-Content -Path $wingetFile -Encoding UTF8
    Write-Host "  已建立 $wingetFile"
  } else {
    Write-Host "  找不到設定檔位置，請執行 winget settings 手動加入:"
    Write-Host '    "telemetry": { "disable": true }'
  }
} elseif ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "  需要 PowerShell 7 才能安全修改(設定檔可能含註解)。請執行 winget settings 手動加入:"
  Write-Host '    "telemetry": { "disable": true }'
} else {
  try {
    $json = Get-Content $wingetFile -Raw | ConvertFrom-Json -AsHashtable
    if ($null -eq $json) { $json = @{} }
    if (-not $json.ContainsKey('telemetry') -or $json.telemetry -isnot [hashtable]) { $json.telemetry = @{} }
    if ($json.telemetry.disable -eq $true) {
      Write-Host "  已經是關閉狀態"
    } elseif ($DryRun) {
      Write-Host "  [dry-run] 在 $wingetFile 設定 telemetry.disable = true"
    } else {
      Copy-Item $wingetFile "$wingetFile.bak" -Force
      $json.telemetry.disable = $true
      $json | ConvertTo-Json -Depth 20 | Set-Content -Path $wingetFile -Encoding UTF8
      Write-Host "  已修改(原檔備份為 settings.json.bak,註解不會保留)"
    }
  } catch {
    Write-Host "  無法解析設定檔，請執行 winget settings 手動加入:"
    Write-Host '    "telemetry": { "disable": true }'
  }
}

# ---------- 4. 需要手動處理的 ----------
Write-Host ""
Write-Host "== 需要手動處理 =="
Write-Host '  VS Code: settings.json 加上 "telemetry.telemetryLevel": "off"'
Write-Host ""
Write-Host "完成。請重開終端機(以及 VS Code 等已開啟的程式)讓環境變數生效。"

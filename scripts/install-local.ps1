# Local install of Golang Lifecycle Toolkit (Cursor)
#
# Requires: Windows PowerShell 5+ or PowerShell 7+
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-local.ps1
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-local.ps1 -Link

param(
  [switch]$Link,
  [string]$DestRoot = $(Join-Path $HOME ".cursor\plugins\local")
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$PluginSrc = Join-Path $Root "plugins\golang-lifecycle"
$Dest = Join-Path $DestRoot "golang-lifecycle"

if (-not (Test-Path (Join-Path $PluginSrc ".cursor-plugin\plugin.json"))) {
  throw "plugin manifest missing: $PluginSrc\.cursor-plugin\plugin.json"
}
if (-not (Test-Path (Join-Path $PluginSrc "assets\logo.svg"))) {
  throw "logo.svg missing"
}
if (-not (Test-Path (Join-Path $PluginSrc "assets\logo.png"))) {
  throw "logo.png missing"
}

New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null
if (Test-Path $Dest) {
  Remove-Item -Recurse -Force $Dest
}

if ($Link) {
  try {
    New-Item -ItemType SymbolicLink -Path $Dest -Target $PluginSrc | Out-Null
    Write-Host "symlinked $PluginSrc -> $Dest"
  } catch {
    Write-Warning "symlink failed ($($_.Exception.Message)); copying instead"
    Copy-Item -Recurse -Force $PluginSrc $Dest
  }
} else {
  Copy-Item -Recurse -Force $PluginSrc $Dest
  Write-Host "copied plugin to $Dest"
}

    if ($Link -and ((Get-Item $Dest).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      Write-Host "note: symlink install keeps relative logo; use copy mode for a local file:// logo"
    } else {
      $Manifest = Join-Path $Dest ".cursor-plugin\plugin.json"
      $LogoPng = (Resolve-Path (Join-Path $Dest "assets\logo.png")).Path
      $FileUrl = ([Uri]$LogoPng).AbsoluteUri

      $json = Get-Content -Raw -Path $Manifest | ConvertFrom-Json
      $json.logo = $FileUrl
      if (-not $json.author) {
        $json | Add-Member -NotePropertyName author -NotePropertyValue (@{ name = "muskmr"; email = "muskmr@gmail.com" })
      } else {
        $json.author = @{ name = "muskmr"; email = "muskmr@gmail.com" }
      }
      $json | ConvertTo-Json -Depth 8 | Set-Content -Path $Manifest -Encoding UTF8
      Write-Host "logo -> $FileUrl"
    }

Write-Host ""
Write-Host "Installed: $Dest"
Write-Host "Next: Cursor -> Developer: Reload Window, then check Plugins for Golang Lifecycle Toolkit."

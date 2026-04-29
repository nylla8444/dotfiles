param(
  [Parameter(Mandatory = $true)]
  [string]$SoundPath
)

$ErrorActionPreference = "Stop"

try {
  if (-not (Test-Path -LiteralPath $SoundPath)) {
    throw "Notification sound not found: $SoundPath"
  }

  $player = New-Object System.Media.SoundPlayer $SoundPath
  $player.PlaySync()
} catch {
  $logPath = Join-Path $PSScriptRoot "notify-hook.log"
  "$(Get-Date -Format o) $($_.Exception.Message)" | Add-Content -LiteralPath $logPath
}

# C:\Users\YOUR_USERNAME\.codex\notify.ps1

$ErrorActionPreference = "Stop"

try {
  [Console]::In.ReadToEnd() | Out-Null

  $sound = Join-Path $PSScriptRoot "audio\pokeding.wav"
  $playerScript = Join-Path $PSScriptRoot "play-notify-sound.ps1"

  if (Test-Path -LiteralPath $sound) {
    Start-Process -FilePath "powershell.exe" -ArgumentList @(
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      $playerScript,
      "-SoundPath",
      $sound
    ) -WindowStyle Hidden
  } else {
    throw "Notification sound not found: $sound"
  }
} catch {
  $logPath = Join-Path $PSScriptRoot "notify-hook.log"
  "$(Get-Date -Format o) $($_.Exception.Message)" | Add-Content -LiteralPath $logPath
}

exit 0

# Windows Terminal copy + GlazeWM startup. Called by install.ps1 (links live there now).
$repo = $PSScriptRoot

# Windows Terminal replaces a symlinked settings.json, so copy it instead.
$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-Item -ItemType Directory -Force (Split-Path $wt) | Out-Null
if (Test-Path $wt) { Copy-Item $wt "$wt.bak" -Force }
Copy-Item "$repo\windows-terminal\settings.json" $wt -Force
Write-Host "copied $wt"

# Optionally start GlazeWM on login via a Startup folder shortcut.
if ((Read-Host "Run GlazeWM on startup? (y/n)") -match '^[yY]') {
  $exe = @(
    (Get-Command glazewm.exe -ErrorAction SilentlyContinue).Source,
    "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe",
    "${env:ProgramFiles(x86)}\glzr.io\GlazeWM\glazewm.exe",
    "$env:LOCALAPPDATA\Programs\glzr.io\GlazeWM\glazewm.exe"
  ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
  if (-not $exe) { Write-Warning "glazewm.exe not found; skipping startup." }
  else {
    $lnk = Join-Path ([Environment]::GetFolderPath('Startup')) "GlazeWM.lnk"
    $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
    $sc.TargetPath = $exe
    $sc.WorkingDirectory = Split-Path $exe
    $sc.Save()
    Write-Host "added startup $lnk"
  }
}

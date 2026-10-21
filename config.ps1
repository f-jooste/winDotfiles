# Links configs into place. Apps must already be installed (see install.ps1).
# Run in PowerShell as Administrator (or enable Developer Mode) so symlinks work.
$repo = $PSScriptRoot

# Abort before touching anything if symlinks can't be created (not admin / no Developer Mode).
$probe = Join-Path $env:TEMP "dotfiles-link-probe"
Remove-Item $probe -Force -ErrorAction SilentlyContinue
try { New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop | Out-Null; Remove-Item $probe -Force }
catch { Write-Error "Cannot create symlinks. Run as Administrator or enable Developer Mode."; exit 1 }
$links = @{
  "$env:USERPROFILE\.config\yasb\config.yaml"        = "$repo\yasb\config.yaml"
  "$env:USERPROFILE\.config\yasb\styles.css"         = "$repo\yasb\styles.css"
  "$env:USERPROFILE\.glzr\glazewm\config.yaml"       = "$repo\glazewm\config.yaml"
  "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" = "$repo\powershell\marcduiker.omp.json"
  "$env:LOCALAPPDATA\nvim"                           = "$repo\nvim"
  "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.PowerShell_profile.ps1" = "$repo\powershell\Microsoft.PowerShell_profile.ps1"
  "$([Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" = "$repo\powershell\Microsoft.PowerShell_profile.ps1"
}
foreach ($l in $links.GetEnumerator()) {
  New-Item -ItemType Directory -Force (Split-Path $l.Key) | Out-Null
  if (Test-Path $l.Key) {
    $item = Get-Item $l.Key -Force
    if (-not $item.LinkType) { Move-Item $l.Key "$($l.Key).bak" -Force }
    else { $item.Delete() }
  }
  New-Item -ItemType SymbolicLink -Path $l.Key -Target $l.Value | Out-Null
  Write-Host "linked $($l.Key)"
}

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

# Links configs into place. Apps must already be installed (see install.ps1).
# Run in PowerShell as Administrator (or enable Developer Mode) so symlinks work.
$repo = $PSScriptRoot
$links = @{
  "$env:USERPROFILE\.config\yasb\config.yaml"        = "$repo\yasb\config.yaml"
  "$env:USERPROFILE\.config\yasb\styles.css"         = "$repo\yasb\styles.css"
  "$env:USERPROFILE\.glzr\glazewm\config.yaml"       = "$repo\glazewm\config.yaml"
  "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" = "$repo\powershell\marcduiker.omp.json"
  "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = "$repo\windows-terminal\settings.json"
  "$env:LOCALAPPDATA\nvim"                           = "$repo\nvim"
  "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.PowerShell_profile.ps1" = "$repo\powershell\Microsoft.PowerShell_profile.ps1"
}
foreach ($l in $links.GetEnumerator()) {
  New-Item -ItemType Directory -Force (Split-Path $l.Key) | Out-Null
  if (Test-Path $l.Key) {
    $item = Get-Item $l.Key -Force
    if (-not $item.LinkType) { Move-Item $l.Key "$($l.Key).bak" -Force }
    else { Remove-Item $l.Key -Force -Recurse }
  }
  New-Item -ItemType SymbolicLink -Path $l.Key -Target $l.Value | Out-Null
  Write-Host "linked $($l.Key)"
}

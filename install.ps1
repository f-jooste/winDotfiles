# Installs missing apps with winget and links each app's configs from this repo.
# Run in PowerShell as Administrator (or enable Developer Mode) so symlinks work.
$repo = $PSScriptRoot
$docs = [Environment]::GetFolderPath('MyDocuments')

# Abort before touching anything if symlinks can't be created (not admin / no Developer Mode).
$probe = Join-Path $env:TEMP "dotfiles-link-probe"
Remove-Item $probe -Force -ErrorAction SilentlyContinue
try { New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop | Out-Null; Remove-Item $probe -Force }
catch { Write-Error "Cannot create symlinks. Run as Administrator or enable Developer Mode."; exit 1 }

# Each app: winget Id + Links (link path = repo target). Install-only apps have no Links.
$apps = @(
  @{ Id = "AmN.yasb"; Links = @{
      "$env:USERPROFILE\.config\yasb\config.yaml" = "$repo\yasb\config.yaml"
      "$env:USERPROFILE\.config\yasb\styles.css"  = "$repo\yasb\styles.css"
  } },
  @{ Id = "glzr-io.glazewm"; Links = @{
      "$env:USERPROFILE\.glzr\glazewm\config.yaml" = "$repo\glazewm\config.yaml"
  } },
  @{ Id = "Microsoft.WindowsTerminal" },
  @{ Id = "Microsoft.PowerShell"; Links = @{
      "$docs\PowerShell\Microsoft.PowerShell_profile.ps1"        = "$repo\powershell\Microsoft.PowerShell_profile.ps1"
      "$docs\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" = "$repo\powershell\Microsoft.PowerShell_profile.ps1"
  } },
  @{ Id = "JanDeDobbeleer.OhMyPosh"; Links = @{
      "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" = "$repo\powershell\marcduiker.omp.json"
  } },
  @{ Id = "Neovim.Neovim"; Links = @{
      "$env:LOCALAPPDATA\nvim" = "$repo\nvim"
  } },
  @{ Id = "DEVCOM.JetBrainsMonoNerdFont" },
  # LazyVim dependencies
  @{ Id = "Git.Git" },
  @{ Id = "BurntSushi.ripgrep.MSVC" },
  @{ Id = "sharkdp.fd" }
)

function Test-Installed($id) {
  winget list --id $id --exact --source winget --accept-source-agreements 2>&1 | Out-Null
  $LASTEXITCODE -eq 0
}

# One timestamped folder per run; repeat runs never overwrite older backups.
$backupRoot = Join-Path $env:USERPROFILE "dotfiles-backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Backup-Config($path) {
  $rel = ($path -replace '^([A-Za-z]):', '$1') -replace '^[\\/]+', ''
  $dest = Join-Path $backupRoot $rel
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  Copy-Item $path $dest -Recurse -Force
  Write-Host "backed up $path -> $dest"
}

function Link-Config($path, $target, $backup) {
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  if (Test-Path $path) {
    $item = Get-Item $path -Force
    if ($item.LinkType) { $item.Delete() }
    else {
      if ($backup) { Backup-Config $path }
      Remove-Item $path -Recurse -Force
    }
  }
  New-Item -ItemType SymbolicLink -Path $path -Target $target | Out-Null
  Write-Host "linked $path"
}

foreach ($app in $apps) {
  $wasInstalled = Test-Installed $app.Id
  if ($wasInstalled) { Write-Host "$($app.Id) already installed" }
  else {
    Write-Host "Installing $($app.Id)..."
    winget install --id $app.Id --exact --source winget --accept-package-agreements --accept-source-agreements
  }
  if (-not $app.Links) { continue }
  foreach ($l in $app.Links.GetEnumerator()) { Link-Config $l.Key $l.Value $wasInstalled }
}

# Windows Terminal copy and GlazeWM startup (moving into the app flow in a later step).
& "$repo\config.ps1"

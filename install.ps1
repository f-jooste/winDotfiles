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
  }; Post = { Add-GlazeStartup } },
  # WT replaces a symlinked settings.json, so it is copied instead.
  @{ Id = "Microsoft.WindowsTerminal"; Copies = @{
      "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = "$repo\windows-terminal\settings.json"
  } },
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
  @{ Id = "Fastfetch-cli.Fastfetch"; Links = @{
      "$env:USERPROFILE\.config\fastfetch\config.jsonc" = "$repo\fastfetch\config.jsonc"
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

# Optionally start GlazeWM on login via a Startup folder shortcut.
function Add-GlazeStartup {
  if ((Read-Host "Run GlazeWM on startup? (y/n)") -notmatch '^[yY]') { return }
  $exe = @(
    (Get-Command glazewm.exe -ErrorAction SilentlyContinue).Source,
    "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe",
    "${env:ProgramFiles(x86)}\glzr.io\GlazeWM\glazewm.exe",
    "$env:LOCALAPPDATA\Programs\glzr.io\GlazeWM\glazewm.exe"
  ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
  if (-not $exe) { Write-Warning "glazewm.exe not found; skipping startup."; return }
  $lnk = Join-Path ([Environment]::GetFolderPath('Startup')) "GlazeWM.lnk"
  $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
  $sc.TargetPath = $exe
  $sc.WorkingDirectory = Split-Path $exe
  $sc.Save()
  Write-Host "added startup $lnk"
}

function Copy-Config($path, $source, $backup) {
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  if ($backup -and (Test-Path $path)) { Backup-Config $path }
  Copy-Item $source $path -Force
  Write-Host "copied $path"
}

foreach ($app in $apps) {
  $wasInstalled = Test-Installed $app.Id
  if ($wasInstalled) { Write-Host "$($app.Id) already installed" }
  else {
    Write-Host "Installing $($app.Id)..."
    winget install --id $app.Id --exact --source winget --accept-package-agreements --accept-source-agreements
  }
  if ($app.Links) { foreach ($l in $app.Links.GetEnumerator()) { Link-Config $l.Key $l.Value $wasInstalled } }
  if ($app.Copies) { foreach ($c in $app.Copies.GetEnumerator()) { Copy-Config $c.Key $c.Value $wasInstalled } }
  if ($app.Post) { & $app.Post }
}

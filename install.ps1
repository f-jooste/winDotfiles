# Installs all apps with winget, then runs config.ps1 to link the configs.
# Run in PowerShell as Administrator.
$apps = @(
  "AmN.yasb",
  "glzr-io.glazewm",
  "Neovim.Neovim",
  "DEVCOM.JetBrainsMonoNerdFont",
  # LazyVim dependencies
  "Git.Git",
  "BurntSushi.ripgrep.MSVC",
  "sharkdp.fd"
)

foreach ($app in $apps) {
  Write-Host "Installing $app..."
  winget install --id $app --exact --source winget --accept-package-agreements --accept-source-agreements
}

Write-Host "Linking configs..."
& "$PSScriptRoot\config.ps1"

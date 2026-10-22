# New tabs inherit Windows Terminal's stale environment; reload PATH so freshly installed apps resolve.
$env:Path = (@('User', 'Machine') | ForEach-Object { [Environment]::GetEnvironmentVariable('Path', $_) }) -join ';'

oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" | Invoke-Expression

# Directories in ls: blue text, no background highlight
if ($PSStyle) { $PSStyle.FileInfo.Directory = "$([char]27)[38;2;139;164;176m" }

# Aliases
# Functions, since aliases can't pass -Force. AllScope aliases (dir, del) must be removed first.
foreach ($a in 'ls', 'dir', 'rm', 'del') { Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue }
function ls { Get-ChildItem -Force @args }
function dir { Get-ChildItem -Force @args }
function rm { Remove-Item -Force @args }
function del { Remove-Item -Force @args }

# Optional fastfetch on launch; marker is created by install.ps1 (outside the repo). Interactive sessions only.
$ffArgs = [Environment]::GetCommandLineArgs() | Select-Object -Skip 1
$ffInteractive = -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected -and -not ($ffArgs -match '^-(c|command|f|file|noni\w*|e\w*)$')
if ($ffInteractive -and (Test-Path "$env:USERPROFILE\.config\fastfetch\run-on-launch") -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) { fastfetch }
Remove-Variable ffArgs, ffInteractive

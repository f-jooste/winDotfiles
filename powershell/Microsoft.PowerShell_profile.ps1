oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" | Invoke-Expression

# Directories in ls: blue text, no background highlight
if ($PSStyle) { $PSStyle.FileInfo.Directory = "$([char]27)[38;2;139;164;176m" }

# Aliases
Set-Alias -Name ls -Value Get-ChildItem -Force
Set-Alias -Name dir -Value Get-ChildItem -Force
Set-Alias -Name rm -Value Remove-Item -Force
Set-Alias -Name del -Value Remove-Item -Force

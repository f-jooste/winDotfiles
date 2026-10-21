oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" | Invoke-Expression

# Directories in ls: blue text, no background highlight
if ($PSStyle) { $PSStyle.FileInfo.Directory = "$([char]27)[38;2;139;164;176m" }

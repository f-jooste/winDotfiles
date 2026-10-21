oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\marcduiker.omp.json" | Invoke-Expression

# Directories in ls: blue text, no background highlight
$PSStyle.FileInfo.Directory = "`e[38;2;139;164;176m"

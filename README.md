# dotfiles
Windows configs: YASB, GlazeWM, Neovim (LazyVim), PowerShell 7 + Oh My Posh, Windows Terminal.

- `install.ps1`: per app, installs via winget if missing, then links its configs. Aborts if symlinks unavailable.
- `config.ps1`: Windows Terminal copy + GlazeWM startup prompt (called by install.ps1; to be folded in).

Run either in PowerShell as Administrator. If scripts are blocked:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## Layout
- `yasb/`: YASB bar config and styles (symlinked).
- `glazewm/`: GlazeWM config (symlinked).
- `nvim/`: LazyVim config with kanagawa (symlinked).
- `powershell/`: PowerShell 7 profile and Oh My Posh theme `marcduiker` (symlinked).
- `windows-terminal/`: Windows Terminal settings with Kanagawa Dragon scheme and JetBrainsMono Nerd Font. Copied, not linked, since Windows Terminal replaces a symlinked `settings.json`.

## Notes
- Existing non-link files are moved to `<name>.bak` before linking.
- Windows Terminal edits made in its UI are not synced back. Copy the live `settings.json` into `windows-terminal/` by hand.
- PRs merged into `dev` auto-close issues named in the description (`Closes`/`Fixes`/`Resolves #N`), since GitHub only does this natively for the default branch (`main`). See `.github/workflows/close-issues-on-merge.yml`.
- Open a new terminal tab after install so the prompt and font load.

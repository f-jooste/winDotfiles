# dotfiles
Windows configs: YASB, GlazeWM, Neovim (LazyVim), PowerShell 7 + Oh My Posh, Windows Terminal.

`install.ps1` is the single entry point. Per app: installs via winget if missing, links its configs (Windows Terminal is copied), and asks whether GlazeWM should run on startup. Aborts if symlinks unavailable.

Run it in PowerShell as Administrator. If scripts are blocked:

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
- For apps already installed, existing real configs are copied to `~\dotfiles-backup\<timestamp>\` before being replaced. Fresh installs and existing symlinks are not backed up.
- Windows Terminal edits made in its UI are not synced back. Copy the live `settings.json` into `windows-terminal/` by hand.
- Open a new terminal tab after install so the prompt and font load.

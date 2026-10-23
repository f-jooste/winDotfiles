# dotfiles
Windows configs: YASB, GlazeWM, Neovim (LazyVim), PowerShell 7 + Oh My Posh, Windows Terminal, fastfetch, Claude Code. Also installs the Claude desktop app and Claude Code CLI via winget (install-only, nothing linked for the desktop app).

`install.ps1` is the single entry point. Per app: installs via winget if missing, links its configs (Windows Terminal is copied), and asks whether GlazeWM should run on startup and whether fastfetch should run on each terminal launch (stored in `~\.config\fastfetch\run-on-launch`, not in the repo; re-run to change). Aborts if symlinks unavailable.

Run it in PowerShell as Administrator. If scripts are blocked:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## Layout
- `yasb/`: YASB bar config and styles (symlinked).
- `glazewm/`: GlazeWM config (symlinked).
- `nvim/`: LazyVim config with kanagawa (symlinked).
- `powershell/`: PowerShell 7 profile and Oh My Posh theme `marcduiker` (symlinked).
- `fastfetch/`: fastfetch starter config (symlinked to `~\.config\fastfetch\config.jsonc`).
- `claude/`: Claude Code user `CLAUDE.md` (symlinked to `~\.claude\CLAUDE.md`) and `skills/`, the mattpocock skills copied flat from the plugin; each skill dir is symlinked into `~\.claude\skills\`, leaving `synced` alone. `~\.claude\settings.json` is intentionally unmanaged: not in the repo, never linked or touched (machine paths).
- `windows-terminal/`: Windows Terminal settings with Kanagawa Dragon scheme and JetBrainsMono Nerd Font. Copied, not linked, since Windows Terminal replaces a symlinked `settings.json`.

## Notes
- For apps already installed, existing real configs are copied to `~\dotfiles-backup\<timestamp>\` before being replaced. Fresh installs and existing symlinks are not backed up. Claude Code is always backed up, since it may predate winget.
- Windows Terminal edits made in its UI are not synced back. Copy the live `settings.json` into `windows-terminal/` by hand.
- Disable the `mattpocock-skills` plugin in Claude Code (`/plugin`), or its skills appear twice alongside the linked personal ones.
- Open a new terminal tab after install so the prompt and font load.

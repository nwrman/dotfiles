# Windows install path

Native Windows 10/11 using `cmd.exe` in Windows Terminal — no WSL. The shell layer is Clink (so cmd gets persistent history, line editing, and completions), and the install is driven by `windows/install.ps1` → `windows/bootstrap.ps1`. **Fully separate from the Mac/Linux flow** in `install.sh` / `scripts/bootstrap.sh`.

## Quick start

From cmd or PowerShell (run from the repo root, after cloning):

```powershell
powershell -ExecutionPolicy Bypass -File windows\install.ps1
```

Or curl-pipe in PowerShell (no local clone yet):

```powershell
iwr -useb https://raw.githubusercontent.com/nwrman/dotfiles/master/windows/install.ps1 | iex
```

PowerShell 7 (`pwsh.exe`) is recommended but not required for the bootstrap itself — Windows PowerShell 5.1 (preinstalled) is enough to run `install.ps1`. PS 7 is installed by the bootstrap and used as the recommended daily-driver shell afterwards.

## What it does

Mirrors `scripts/bootstrap-linux.sh` in spirit:

1. Ensures git via winget if missing; clones the repo to `%USERPROFILE%\projects\dotfiles`
2. Prompts for `personal` / `work` role (or pass `-Role personal`)
3. Installs CLI tools from `windows/packages.ps1` (winget primary, scoop fallback)
4. Installs and configures Clink: `clink-fzf` (Ctrl-T / Ctrl-R / Alt-C), `clink-zoxide` (`cd <fragment>` jumps), `clink-gizmos`, carapace cmd bridge
5. Chains fnm into cmd's AutoRun so `node -v` auto-switches on `.nvmrc`
6. Copies cmd shims to `%USERPROFILE%\.bin` and adds it to user PATH: `open`, `pbcopy`, `pbpaste`, `which`
7. Symlinks (Developer Mode required) or copies selected dotfiles: `home/.gitconfig`, `home/.config/secrets.example`, `home/.config/lazygit`, `home/.config/gh-dash`, `home/.config/carapace`, and `windows/powershell/profile.ps1` to `$PROFILE.CurrentUserAllHosts`

## Folder layout

```
windows/
├── install.ps1            # entry point (curl-pipe or local file)
├── bootstrap.ps1          # main bootstrap (analog of bootstrap-linux.sh)
├── packages.ps1           # winget + scoop + npm + uv inventory (analog of Brewfile.linux)
├── packages.work.ps1      # work-only packages (analog of Brewfile.work.linux)
├── _winget-install.ps1    # internal helper -- elevated winget loop (single UAC prompt)
├── clink/
│   └── _dotfiles.lua      # Clink settings (history, fzf bindings, zoxide, carapace)
├── shims/
│   ├── open.cmd           # Unix-style `open` -- handles ~/, URLs, /mnt/c paths
│   ├── pbcopy.cmd         # stdin -> Windows clipboard
│   ├── pbpaste.cmd        # Windows clipboard -> stdout
│   └── which.cmd          # wraps `where` so muscle memory works
└── powershell/
    └── profile.ps1        # PS 7 daily-driver profile (mirrors home/.zshrc)
```

## Caveats — intentional gaps vs the Mac/Linux setup

- **atuin in cmd** is dropped — no cmd.exe integration upstream. Clink's persistent history + clink-fzf's `Ctrl-R` substitute for the search UI. **Use PowerShell instead** if you want the full atuin TUI and cross-machine history sync with the Mac.
- **zoxide in cmd** uses the third-party [`shunsambongi/clink-zoxide`](https://github.com/shunsambongi/clink-zoxide) Lua shim — upstream `zoxide init cmd` is unimplemented.
- **carapace** cmd support is upstream-experimental (works fine in pwsh).
- **fnm** wires through cmd `AutoRun` chained after Clink (no `fnm env --shell cmd`).
- **television** Windows binary works but has no cmd shell integration; usable only as a manual launcher (`tv`).
- **Symlinks** require [Developer Mode](ms-settings:developers) — without it, the bootstrap falls back to copying files and your edits won't roundtrip back into the repo.
- **Skipped on Windows:** zsh, powerlevel10k, tmux, sesh, terminal-notifier, mas (no native version or pointless in cmd), plus ffmpegthumbnailer / poppler / fselect / mariadb-client / googleworkspace-cli (niche).
- **Re-running** `install.ps1` is idempotent. Use `-SkipPackages` to skip the package install loop when iterating on shim / Clink / dotfiles changes.

## PowerShell 7 (recommended daily-driver shell)

The installer drops a PS 7 profile at `$PROFILE.CurrentUserAllHosts` (= `Documents\PowerShell\profile.ps1`) so you can use `pwsh.exe` side-by-side with cmd. Open Windows Terminal and pick whichever shell you want per tab.

Why `pwsh` over cmd for daily use:

- **atuin** works natively — the full Ctrl-R TUI with command metadata (exit code, duration, cwd) and cross-machine sync to your Mac. The one thing cmd genuinely can't match.
- **PSReadLine** is built-in (no Clink needed) — line editing, persistent history, syntax highlighting, ListView prediction.
- **carapace** is officially supported (not "experimental" like in cmd).
- **oh-my-posh** Pure theme — visually similar to the p10k prompt on the Mac.
- **zsh-equivalent functions** are defined in the profile: `g`, `gp`, `gst`, `gd`, `nah`, `lg`, `ll`, `la`, `cat` (→ bat), `ls` (→ eza), `dcu`, `dcs`, `pn`, `pd`, etc. See `windows/powershell/profile.ps1`.

Tradeoffs:

- PS 7 startup is ~500ms vs cmd's near-instant.
- Built-in PS aliases that shadow unix tools (`wget`, `curl`, `ls`, `rm`, `cp`, `mv`, `cat`) are removed by the profile so the real binaries win.
- PowerShell syntax differs from bash (`$env:VAR` not `$VAR`, `;` for command sequencing on PS 5.1; PS 7 has `&&`/`||`).

Trigger atuin sync after first install:

```powershell
atuin login   # follow prompts; matches the credentials from your Mac
atuin sync
```

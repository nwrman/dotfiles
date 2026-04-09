# dotfiles

Portable macOS configuration managed with [Homeshick](https://github.com/andsens/homeshick), [Homebrew](https://brew.sh), and shell scripts. Works across Intel and Apple Silicon Macs with support for machine-specific configuration (work vs. personal).

## Quick start

### New machine (from scratch)

```bash
curl -o- https://raw.githubusercontent.com/nwrman/dotfiles/master/install.sh | zsh
```

Or manually:

```bash
# Install Homeshick
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
source $HOME/.homesick/repos/homeshick/homeshick.sh

# Clone and link dotfiles
homeshick clone nwrman/dotfiles
homeshick link dotfiles

# Run bootstrap (installs everything)
bash ~/.homesick/repos/dotfiles/scripts/bootstrap.sh
```

The bootstrap script will prompt you to select a machine role (`personal` or `work`). You can also pass it as an argument:

```bash
bash scripts/bootstrap.sh work
bash scripts/bootstrap.sh personal
```

### Existing machine (update)

```bash
homeshick pull dotfiles
homeshick link dotfiles
brew bundle --file=~/.homesick/repos/dotfiles/Brewfile
```

## What bootstrap does

The `scripts/bootstrap.sh` script is idempotent (safe to re-run) and performs these steps:

1. **Machine role** -- prompts for `personal` or `work`, saved to `~/.machine-role`
2. **Homebrew** -- installs Homebrew if missing, runs `brew update`
3. **Packages** -- installs everything from `Brewfile` (and `Brewfile.work` if work machine)
4. **Dotfiles** -- installs Homeshick if missing, runs `homeshick link`
5. **macOS defaults** -- applies Dock, Finder, trackpad, keyboard, and other system preferences
6. **Extras** -- enables Touch ID for sudo, configures Spicetify (Spotify theming)
7. **App preferences** -- imports saved preferences for AltTab, Bartender, Shottr, KeyClu, Homerow, and configures iTerm2
8. **Reminders** -- prompts to create `~/.secrets` if missing

## Repository structure

```
dotfiles/
├── Brewfile                    # Shared Homebrew packages, casks, fonts, MAS apps
├── Brewfile.work               # Work-only packages (installed when role=work)
├── home/                       # Symlinked to $HOME by Homeshick
│   ├── .config/
│   │   ├── atuin/config.toml    # Atuin shell history config
│   │   ├── ghostty/config      # Ghostty terminal config
│   │   ├── iterm2-prefs/       # iTerm2 prefs (iTerm2 reads directly from here)
│   │   ├── nix/                # Legacy nix-darwin config (untouched)
│   │   ├── sublime-text-3/     # Sublime Text settings
│   │   └── zed/settings.json   # Zed editor settings
│   ├── .gitconfig
│   ├── .my.cnf
│   ├── .p10k.zsh              # Powerlevel10k prompt theme
│   ├── .secrets.example        # Template for machine-local secrets
│   ├── .tmux.conf
│   ├── .zsh/
│   │   ├── common.zsh         # Shared aliases, exports, PATH
│   │   └── work.zsh           # Work-only config (sourced conditionally)
│   ├── .zshrc                 # Main shell config (Zinit, plugins, keybindings)
│   └── ...
├── prefs/                      # Exported app preferences (not symlinked)
│   ├── alttab.plist
│   ├── bartender.plist
│   ├── homerow.plist
│   ├── keyclu.plist
│   ├── raycast.rayconfig
│   └── shottr.plist
├── scripts/
│   ├── bootstrap.sh            # Full machine setup (idempotent)
│   ├── export-prefs.sh         # Export current app prefs to prefs/
│   ├── import-prefs.sh         # Import saved app prefs on new machine
│   ├── macos-defaults.sh       # macOS system preferences
│   └── setup-extras.sh         # Touch ID, Spicetify, etc.
└── install.sh                  # Bootstrap entry point (Homeshick + bootstrap)
```

## Machine roles

A file at `~/.machine-role` contains either `personal` or `work`. This controls:

- **Brewfile.work** -- only installed on work machines
- **work.zsh** -- work-specific shell config, only sourced on work machines

The file is gitignored and created during bootstrap.

## Secrets

Secrets (API keys, tokens, PATs) are **not** stored in the repo. Instead:

1. A template exists at `home/.secrets.example`
2. Copy it to `~/.secrets` and fill in your values
3. `.zshrc` sources `~/.secrets` automatically if it exists

```bash
cp ~/.homesick/repos/dotfiles/home/.secrets.example ~/.secrets
# Edit ~/.secrets with your actual values
```

## Managing packages

### Shared packages (both machines)

Edit `Brewfile` and run:

```bash
brew bundle --file=Brewfile
```

### Work-only packages

Edit `Brewfile.work` and run:

```bash
brew bundle --file=Brewfile.work
```

## Managing app preferences

### Config-file apps (automatic via Homeshick)

These apps store config as plain files in `~/.config/`. Homeshick symlinks them, so any edits are automatically tracked in the repo:

| App | Config path |
|-----|-------------|
| Ghostty | `home/.config/ghostty/config` |
| Zed | `home/.config/zed/settings.json` |
| Sublime Text | `home/.config/sublime-text-3/Packages/User/` |
| iTerm2 | `home/.config/iterm2-prefs/` (reads directly from this folder) |

### Plist-based apps (export/import scripts)

These apps store preferences in macOS `defaults` domains. They are exported to `prefs/` and imported via script.

| App | Domain | File |
|-----|--------|------|
| AltTab | `com.lwouis.alt-tab-macos` | `prefs/alttab.plist` |
| Bartender | `com.surteesstudios.Bartender` | `prefs/bartender.plist` |
| Shottr | `cc.ffitch.shottr` | `prefs/shottr.plist` |
| KeyClu | `com.0804Team.KeyClu` | `prefs/keyclu.plist` |
| Homerow | `com.superultra.Homerow` | `prefs/homerow.plist` |

**After changing app settings**, export them:

```bash
bash scripts/export-prefs.sh
# Then commit the updated files in prefs/
```

**On a new machine**, preferences are imported automatically by `bootstrap.sh`, or manually:

```bash
bash scripts/import-prefs.sh
```

### Raycast (manual)

Raycast settings are exported/imported via the app itself:

- **Export:** Raycast > Settings > Advanced > Export Settings (save to `prefs/raycast.rayconfig`)
- **Import:** Raycast > Settings > Advanced > Import Settings (select `prefs/raycast.rayconfig`)

## macOS defaults

System preferences (Dock, Finder, trackpad, keyboard, locale, etc.) are managed declaratively in `scripts/macos-defaults.sh`. To re-apply:

```bash
bash scripts/macos-defaults.sh
```

## Shell setup

### Plugin stack

- **[Zinit](https://github.com/zdharma-continuum/zinit)** -- plugin manager with turbo mode (plugins load *after* the prompt renders, so startup feels instant)
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** -- prompt theme in Pure style with Snazzy colors. Uses instant prompt for near-zero latency and transient prompt (previous commands shrink to a minimal `>`)
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** -- colors commands as you type (green = valid, red = error)
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** -- suggests commands from history as you type (accept with right arrow)
- **[fzf-tab](https://github.com/Aloxaf/fzf-tab)** -- replaces the default tab completion menu with fzf fuzzy matching and directory previews

### Navigation

- **AUTO_CD** -- type a directory name to `cd` into it (e.g., `projects` instead of `cd projects`)
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** replaces `cd` -- learns your frequently visited directories. `cd foo` jumps to the best match, `zi` opens an interactive picker
- **[bd](https://github.com/Tarrasch/zsh-bd)** -- jump back to a parent directory by name (e.g., `bd src` from `~/projects/app/src/lib/utils` jumps to `~/projects/app/src`)
- **`..`**, **`...`**, **`....`** -- quick upward navigation (`..` = `cd ..`, `...` = `cd ../..`, etc.)

### Node version management

- **[fnm](https://github.com/Schniz/fnm)** automatically switches Node versions when you enter a directory containing `.nvmrc` or `.node-version`
- Smart caching optimization: only calls `fnm use` when the version file *actually changes*, not on every `cd`

### Completions & fuzzy finding

- **[Carapace](https://carapace.sh)** -- multi-shell completion engine providing 669 completers from a single binary, replacing `zsh-completions`, Docker fpath, and Bun lazy-load hacks. Falls back to native zsh/fish/bash completions via `CARAPACE_BRIDGES` for uncovered tools
- **Laravel Artisan** -- dynamic completions via Symfony Console's native zsh completion (`artisan _complete`). Discovers all project commands at runtime, including app-specific ones (e.g., `boost:update`, `deploy:*`). Works with the `a` alias
- **fzf-tab** -- tab completion uses fzf with eza directory previews for `cd` and `zoxide`
- **[Television](https://github.com/alexpasmantier/television)** -- context-aware smart autocomplete via `Ctrl+T`. Understands the current prompt: `git checkout` + Ctrl+T shows branches, `cd` + Ctrl+T shows directories, `cat` + Ctrl+T shows files
- **[fzf](https://github.com/junegunn/fzf)** -- fuzzy matching backend for fzf-tab (no shell keybindings -- television and atuin handle those)
- **Case-insensitive completion** -- `doc<tab>` matches `Documents`
- **compinit caching** -- completion dump only rebuilds every 24 hours

### Keybindings

Emacs mode (`bindkey -e`) with bindings for multiple terminal emulators:

| Key | Action |
|-----|--------|
| `Home` / `End` | Beginning / end of line |
| `Ctrl+Right` / `Ctrl+Left` | Jump forward / back one word |
| `Alt+Right` / `Alt+Left` | Jump forward / back one word (alternative) |
| `Ctrl+K` | Kill from cursor to end of line |
| `Ctrl+U` | Kill from cursor to beginning of line |
| `Ctrl+W` | Kill previous word |
| `Page Up` / `Page Down` | Search history backward / forward |

### History

- **[Atuin](https://atuin.sh)** -- replaces zsh's built-in history with a SQLite database. Stores command context (directory, exit code, duration, timestamp) and provides fuzzy search
- **`Ctrl+R`** -- opens atuin's compact search UI with fuzzy filtering across all history
- **Up arrow** -- prefix search (type `git` then Up = only git commands)
- **`Tab`** in atuin search -- paste command to prompt for editing instead of executing
- Zsh's built-in history is kept as fallback (10,000 entries in `~/.zsh_history`)

### Key aliases

Not exhaustive -- see `home/.zsh/common.zsh` for the full list.

**Git:**

| Alias | Command | Note |
|-------|---------|------|
| `g` | `git` | |
| `gp` | `git pull --rebase --autostash` | Keeps history clean |
| `nah` | `git reset --hard && git clean -df` | Discard everything |
| `gu` | `git reset --soft HEAD~1` | Undo last commit (keep changes) |
| `gst` | `git status` | |
| `gc` | `git commit --verbose` | |
| `gpu` | `git push` | |
| `gsw` | `git switch -` | Switch to previous branch |
| `gd` | `git diff \| diffnav` | Interactive diff with file tree |
| `gds` | `git diff --staged \| diffnav` | Staged changes in diffnav |
| `gdiff` | `git diff --no-ext-diff` | Plain diff (no pager) |
| `pr-diff` | `gh pr diff \| diffnav` | Review PR diff in diffnav |
| `ghd` | `gh dash` | GitHub dashboard (PRs, issues, notifications) |
| `gl` / `glo` / `glg` | Log (medium / oneline / graph) | |

**PHP / Laravel:**

| Alias | Command |
|-------|---------|
| `a` | `./artisan` |
| `t` | `./vendor/bin/pest` |
| `c` | `composer` |
| `cl` | `composer lint` |

**Node / pnpm:**

| Alias | Command |
|-------|---------|
| `d` | `npm run dev` |
| `nr` | `npm run` |
| `pn` | `pnpm` |
| `pd` | `pnpm run dev` |

**Docker:**

| Alias | Command |
|-------|---------|
| `dcu` | `docker-compose up -d` |
| `dcs` | `docker-compose stop` |
| `dcr` | Stop + up (restart) |

**Files & directories:**

| Alias | Command |
|-------|---------|
| `y` | `yazi` (terminal file manager) |
| `ls` | `eza --group-directories-first` |
| `l` | `eza -1a` |
| `ll` | `eza -lh` |
| `la` | `eza -la` |
| `lt` | `eza -l --sort=modified` |
| `tree` | `eza --tree` |
| `cat` | `bat --paging=never` |

**Safety defaults:**

`cp`, `mv`, and `rm` are aliased with `-i` (interactive confirmation). `mkdir` always uses `-p`.

### Other integrations

- **Sudo plugin** -- double-tap `ESC` to prefix the current or previous command with `sudo`
- **command-not-found** -- suggests which package to install when a command isn't found

See `home/.zsh/common.zsh` for the full alias list and `home/.zshrc` for all shell configuration.

## Tmux

Managed with [TPM](https://github.com/tmux-plugins/tpm) (auto-installs on fresh machines). Theme is [Catppuccin Mocha](https://github.com/catppuccin/tmux) with rounded window tabs.

### Plugins

| Plugin | Purpose |
|--------|---------|
| `tmux-sensible` | Universal sane defaults |
| `tmux-yank` | System clipboard integration in copy mode |
| `tmux-resurrect` | Save/restore sessions across reboots |
| `tmux-continuum` | Auto-save sessions every 15 min + auto-restore on start |
| `catppuccin/tmux` | Catppuccin Mocha theme with status modules |

### Status bar (top)

- **Left:** window tabs (rounded style, numbered from 1)
- **Right:** current application, directory, session name
- **SSH only:** user and hostname appear when connected remotely

### Session management

- **[sesh](https://github.com/joshmedeski/sesh)** -- smart tmux session manager, integrates with zoxide for directory discovery
- **[television](https://github.com/alexpasmantier/television)** -- fuzzy finder used as the session picker UI (via custom `sesh` cable channel)
- `prefix + T` opens a popup with television showing all sessions, zoxide directories, and config paths. `Ctrl+S` cycles sources, `Ctrl+D` kills a session, `Enter` connects
- `prefix + L` switches to the last session (like `cd -` for tmux)
- Closing a session auto-switches to the next one (`detach-on-destroy off`)

### Key bindings

Prefix is `Ctrl+B` (default). Keybindings below are pressed **after** the prefix. Capital letters mean `Shift` is held (e.g., `prefix + T` = `Ctrl+B` then `Shift+T`).

| Key | Action |
|-----|--------|
| `prefix + T` | Session picker (sesh + television) |
| `prefix + L` | Switch to last session |
| `prefix + \|` | Split pane horizontally (in current path) |
| `prefix + -` | Split pane vertically (in current path) |
| `prefix + I` | Install new TPM plugins |
| `prefix + U` | Update plugins |

#### Window switching (no prefix needed)

These bindings work instantly without pressing the prefix key first:

| Key | Action |
|-----|--------|
| `Alt+1` - `Alt+9` | Jump directly to window N |
| `Alt+h` | Previous window |
| `Alt+l` | Next window |
| `Alt+Tab` | Toggle between last two windows |

> **Note:** On macOS, your terminal must send Option as Meta/Esc+. In iTerm2: Preferences > Profiles > Keys > Left Option = `Esc+`. In Ghostty this is the default behavior.

### Settings

- Mouse enabled, true-color support, no ESC delay
- 10,000 line scrollback, auto-renumber windows on close

See `home/.tmux.conf` for the full configuration.

## GitHub Dashboard (gh-dash)

[gh-dash](https://github.com/dlvhdr/gh-dash) provides a terminal UI for managing PRs, issues, and notifications across all your GitHub repos. Launch with `ghd`.

### Diff pager

PR diffs open in [diffnav](https://github.com/dlvhdr/diffnav) -- a file-tree diff viewer (press `d` on any PR).

### Custom keybindings

| Key | Context | Action |
|-----|---------|--------|
| `g` | Any view | Open lazygit in the repo |
| `e` | PRs | Open repo in Zed |
| `d` | PRs | View PR diff in diffnav |
| `O` | PRs | Checkout PR branch locally |

See `home/.config/gh-dash/config.yml` for the full configuration.

## License

MIT

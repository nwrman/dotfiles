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
└── install.sh                  # Bootstrap entry point (Prezto + Homeshick + bootstrap)
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

- **Framework:** [Zinit](https://github.com/zdharma-continuum/zinit) (plugin manager)
- **Prompt:** [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (Pure style)
- **Plugins:** syntax-highlighting, completions, autosuggestions, fzf-tab
- **Integrations:** fzf, zoxide, Docker completions

## License

MIT

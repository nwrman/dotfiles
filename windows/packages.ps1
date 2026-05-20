# packages.ps1 — CLI tool inventory for native Windows + cmd.exe.
# Analog of Brewfile.linux. Sourced by windows/bootstrap.ps1.
#
# Strategy: winget primary (faster, fewer dependencies), scoop fallback for
# tools winget doesn't carry cleanly or where scoop's autopath is preferable.
# Anything that doesn't fit either (npm packages, vendored Clink Lua scripts)
# is handled directly in windows/bootstrap.ps1.

$WingetPackages = @(
  # Version control + GitHub
  @{ Id = 'Git.Git';                          Name = 'git' },
  @{ Id = 'GitHub.cli';                       Name = 'gh' },
  @{ Id = 'dandavison.delta';                 Name = 'git-delta' },
  @{ Id = 'JesseDuffield.lazygit';            Name = 'lazygit' },

  # Modern file/text CLI
  @{ Id = 'BurntSushi.ripgrep.MSVC';          Name = 'ripgrep' },
  @{ Id = 'sharkdp.fd';                       Name = 'fd' },
  @{ Id = 'sharkdp.bat';                      Name = 'bat' },
  @{ Id = 'eza-community.eza';                Name = 'eza' },
  @{ Id = 'junegunn.fzf';                     Name = 'fzf' },
  @{ Id = 'jqlang.jq';                        Name = 'jq' },
  @{ Id = 'sxyazi.yazi';                      Name = 'yazi' },

  # Editors
  @{ Id = 'Neovim.Neovim';                    Name = 'neovim' },
  @{ Id = 'vim.vim';                          Name = 'vim' },

  # Languages / package managers
  @{ Id = 'astral-sh.uv';                     Name = 'uv' },
  @{ Id = 'Schniz.fnm';                       Name = 'fnm' },

  # Media / archives
  @{ Id = 'Gyan.FFmpeg';                      Name = 'ffmpeg' },
  @{ Id = 'ImageMagick.ImageMagick';          Name = 'imagemagick' },
  @{ Id = '7zip.7zip';                        Name = '7zip' },

  # Network / HTTP
  # wget moved to scoop -- JernejSimoncic.Wget ships an empty package dir via winget
  @{ Id = 'axllent.mailpit';                  Name = 'mailpit' },

  # Service / vendor CLIs
  @{ Id = 'Stripe.StripeCli';                 Name = 'stripe' },
  @{ Id = 'Microsoft.MsOdbcSql.18';           Name = 'msodbcsql18' },

  # cmd + completion stack
  @{ Id = 'chrisant996.Clink';                Name = 'clink' },
  @{ Id = 'rsteube.Carapace';                 Name = 'carapace' },

  # PowerShell side-by-side (pwsh.exe as an alternative daily shell -- see home/.config/powershell/profile.ps1)
  @{ Id = 'Microsoft.PowerShell';             Name = 'powershell-7' }
  # oh-my-posh -> moved to scoop (winget needs UAC, scoop is user-scope)
)

# Tools where scoop has cleaner packaging or winget lacks coverage.
# scoop autopaths into ~/scoop/shims, which is on PATH after `scoop install`.
$ScoopPackages = @(
  # scoop bucket -> package
  @{ Bucket = 'main';   Name = 'zoxide' },
  @{ Bucket = 'main';   Name = 'dust' },
  @{ Bucket = 'main';   Name = 'dua' },
  @{ Bucket = 'main';   Name = 'mprocs' },
  @{ Bucket = 'main';   Name = 'kondo' },
  @{ Bucket = 'main';   Name = 'wget' },
  @{ Bucket = 'main';   Name = 'atuin' },           # works in PowerShell, not cmd
  @{ Bucket = 'main';   Name = 'oh-my-posh' },      # PowerShell prompt theme
  @{ Bucket = 'extras'; Name = 'television' }       # binary is `tv`
  # spicetify-cli -> not in main/extras at the time of writing; install manually
  # httpie        -> installed via `uv tool install httpie` (no scoop manifest)
  # ncdu          -> not packaged on Windows; skip
)

# Installed after fnm is on PATH and a Node version exists.
# Mirrors `brew "gemini-cli"` from Brewfile.linux.
$NpmGlobalPackages = @(
  '@google/gemini-cli'
)

# Python CLI tools delivered via `uv tool install` (uv installed via winget above).
# Covers tools that scoop doesn't carry on Windows (e.g. httpie).
$UvToolPackages = @(
  'httpie'
)

# Clink Lua scripts (vendored at install time, not packages).
# Deployed to %LOCALAPPDATA%\clink\ by windows/bootstrap.ps1.
$ClinkLuaSources = @(
  @{ Name = 'clink-fzf';     Repo = 'chrisant996/clink-fzf';     File = 'fzf.lua' },
  @{ Name = 'clink-zoxide';  Repo = 'shunsambongi/clink-zoxide'; File = 'zoxide.lua' },
  @{ Name = 'clink-gizmos';  Repo = 'chrisant996/clink-gizmos';  File = $null }   # full repo clone
)

# Tools intentionally skipped on Windows. Kept here as documentation so future
# maintainers don't re-add them by mistake.
#
# No native Windows version / no value in cmd:
#   zsh, powerlevel10k, tmux, sesh, terminal-notifier, mas, atuin, diffnav
# Niche (user chose to skip):
#   ffmpegthumbnailer, poppler, fselect, mariadb (client), googleworkspace-cli

# Export for the bootstrap script (dot-source consumer pattern).
$global:WindowsWingetPackages = $WingetPackages
$global:WindowsScoopPackages  = $ScoopPackages
$global:WindowsNpmPackages    = $NpmGlobalPackages
$global:WindowsUvTools        = $UvToolPackages
$global:WindowsClinkLua       = $ClinkLuaSources

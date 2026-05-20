# profile.ps1 -- PowerShell 7 daily-driver profile for the dotfiles repo.
# Deployed by windows/bootstrap.ps1 to $PROFILE.CurrentUserAllHosts.
# Mirrors home/.zshrc as closely as PowerShell allows. Side-by-side with cmd.exe + Clink.

# ---------------------------------------------------------------------------
# 1. Remove conflicting PowerShell built-in aliases so the real unix-ish
#    binaries (wget.exe, curl.exe, eza, rm via real rm, etc.) take precedence.
# ---------------------------------------------------------------------------
$conflicting = @('wget','curl','ls','rm','cp','mv','cat','rmdir','where','ps','sleep','clear','tee','sort','diff','kill','man','tree','sc','set','type','cd')
foreach ($a in $conflicting) {
  if (Test-Path "Alias:$a") {
    Remove-Item -Path "Alias:$a" -Force -ErrorAction SilentlyContinue
  }
}

# ---------------------------------------------------------------------------
# 2. PSReadLine -- line editor, history search, prediction
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
  Set-PSReadLineOption -EditMode Emacs
  Set-PSReadLineOption -BellStyle None
  Set-PSReadLineOption -HistoryNoDuplicates
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  # PredictionSource / ViewStyle require a real virtual-terminal stdout. They
  # error out in redirected contexts (e.g. some CI shells). Swallow so the rest
  # of the profile keeps running.
  try { Set-PSReadLineOption -PredictionSource History -ErrorAction Stop }     catch { }
  try { Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop } catch { }
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  # Ctrl+U: clear the whole input line (matches bash/zsh unix-line-discard).
  Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteInput
  # Ctrl+K: kill from cursor to end of line (emacs default; already on by default but explicit).
  Set-PSReadLineKeyHandler -Key Ctrl+k -Function ForwardDeleteInput
}

# ---------------------------------------------------------------------------
# 3. Tool integrations -- each gated on the binary actually being present
# ---------------------------------------------------------------------------
function Test-Command([string]$Name) { $null -ne (Get-Command $Name -ErrorAction SilentlyContinue) }

# zoxide: `cd <fragment>` jumps to a known frequent dir (mirrors zsh `zoxide init --cmd cd`).
# Also expose `z` / `zi` as aliases to the underlying functions so muscle memory
# from the Mac (`alias z=__zoxide_z` in .zshrc) keeps working.
if (Test-Command zoxide) {
  Invoke-Expression (& zoxide init powershell --cmd cd | Out-String)
  if (Get-Command __zoxide_z  -EA Silent) { Set-Alias -Name z  -Value __zoxide_z  -Option AllScope -Force }
  if (Get-Command __zoxide_zi -EA Silent) { Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Force }
}

# atuin: Ctrl+R opens the rich history TUI (the thing cmd cannot match)
if (Test-Command atuin) {
  Invoke-Expression (& atuin init powershell --disable-up-arrow | Out-String)
}

# fnm: auto-switch Node version when cd'ing into a dir with .nvmrc / .node-version.
# `fnm env --use-on-cd` also redefines `cd` to its own wrapper, clobbering zoxide.
# We undo that below and compose both behaviors into a single cd function.
if (Test-Command fnm) {
  fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

# Compose cd: zoxide jump + fnm per-directory node switch.
# Both zoxide and fnm install their own `cd` alias; whichever runs last wins.
# We override with a function (functions win over aliases at lookup time).
if (Get-Command __zoxide_z -EA SilentlyContinue) {
  Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
  function global:cd {
    __zoxide_z @args
    if (Get-Command Set-FnmOnLoad -EA SilentlyContinue) { Set-FnmOnLoad }
  }
}

# carapace: multi-shell completions for 400+ commands
if (Test-Command carapace) {
  Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
  carapace _carapace powershell | Out-String | Invoke-Expression
}

# oh-my-posh: Pure-style prompt (closest match to your Mac p10k Snazzy/Pure setup).
# Scoop ships themes under apps\oh-my-posh\current\themes\ but doesn't set
# $env:POSH_THEMES_PATH, so we look in a few canonical locations.
if (Test-Command oh-my-posh) {
  $themesPath = $env:POSH_THEMES_PATH
  if (-not ($themesPath -and (Test-Path $themesPath))) {
    foreach ($p in @(
      "$env:USERPROFILE\scoop\apps\oh-my-posh\current\themes",
      "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
      "$env:POSH_PATH\themes"
    )) {
      if ($p -and (Test-Path $p)) { $themesPath = $p; break }
    }
  }
  $theme = if ($env:POSH_THEME -and (Test-Path $env:POSH_THEME)) {
    $env:POSH_THEME
  } elseif ($themesPath -and (Test-Path (Join-Path $themesPath 'pure.omp.json'))) {
    Join-Path $themesPath 'pure.omp.json'
  } else { $null }

  if ($theme) {
    oh-my-posh init pwsh --config $theme | Invoke-Expression
  } else {
    # Fallback: OMP's built-in default theme (no --config). Still nicer than the bare PS prompt.
    oh-my-posh init pwsh | Invoke-Expression
  }
}

# ---------------------------------------------------------------------------
# 4. zsh-equivalent functions (PowerShell aliases don't take arguments cleanly,
#    so we use functions with @args splatting)
# ---------------------------------------------------------------------------

# Git
function g          { git @args }
function gst        { git status --ignore-submodules=dirty @args }
function gp         { git pull --rebase --autostash @args }
function gpu        { git push @args }
function gpuF       { git push --force @args }
function gc         { git commit --verbose @args }
function gco        { git checkout @args }
function gsw        { git switch - @args }
function gd         { git diff @args }
function gds        { git diff --staged @args }
function gdiff      { git diff --no-ext-diff @args }
function gf         { git fetch @args }
function gfa        { git fetch --all @args }
function gfc        { git clone @args }
function gr         { git rebase @args }
function gra        { git rebase --abort @args }
function grc        { git rebase --continue @args }
function gu         { git reset --soft HEAD~1 @args }
function grs        { git reset --soft @args }
function grh        { git reset --hard @args }
function gl         { git log --topo-order --pretty=oneline @args }
function glo        { git log --topo-order --pretty=oneline @args }
function glg        { git log --topo-order --graph --pretty=oneline @args }
function nah        { git reset --hard }
function lg         { lazygit @args }
function ghd        { gh dash @args }

# Files / listing
function ls         { eza --group-directories-first @args }
function l          { eza -1a @args }
function ll         { eza -lh @args }
function la         { eza -la @args }
function lt         { eza -l --sort=modified @args }
function tree       { eza --tree @args }
function y          { yazi @args }
function yz         { yazi @args }
function cat        { bat --paging=never @args }

# Docker
function dcu        { docker compose up -d @args }
function dcs        { docker compose stop @args }
function dcr        { docker compose stop; docker compose up -d }

# PHP / Laravel
function a          { ./artisan @args }
function tb         { ./vendor/bin/pest --bail @args }
function ct         { composer test @args }
function c          { composer @args }

# Node / pnpm
function d          { npm run dev @args }
function nr         { npm run @args }
function pn         { pnpm @args }
function pnx        { pnpm --dlx @args }
function pd         { pnpm run dev @args }

# Quick edit
function v          { nvim @args }
function vim        { nvim @args }   # if you only have nvim

# GUI app launchers (mirrors macOS pstorm/subl/sg shell scripts/aliases)
function pstorm {
  $bin = (Get-ChildItem 'C:\Program Files\JetBrains\PhpStorm*\bin\phpstorm64.exe' -EA SilentlyContinue |
          Sort-Object FullName -Descending | Select-Object -First 1).FullName
  if (-not $bin) { Write-Error "PhpStorm not found under C:\Program Files\JetBrains\"; return }
  if ($args.Count -eq 0) { & $bin (Get-Location).Path } else { & $bin @args }
}
function subl {
  $bin = 'C:\Program Files\Sublime Text\subl.exe'
  if (-not (Test-Path $bin)) { Write-Error "Sublime Text not installed at $bin"; return }
  & $bin @args
}
function sg {
  $bin = 'C:\Program Files\SmartGit\bin\smartgit.exe'
  if (-not (Test-Path $bin)) { Write-Error "SmartGit not installed at $bin"; return }
  & $bin --open . @args
}

# Claude CLI shortcuts (mirrors `cl` / `cc` / `cr` on Mac)
function cl  { claude @args }
function cc  { claude -c @args }   # continue most recent conversation in cwd
function cr  { claude -r @args }   # resume a previous conversation

# More git aliases from common.zsh
function gcp  { git cherry-pick --ff @args }
function gls  { git log --topo-order --stat @args }
function gld  { git log --topo-order --stat --patch --full-diff @args }
function glb  { git log --topo-order --pretty=format:'%h %ad | %s' --date=short @args }
function glc  { git shortlog --summary --numbered @args }
function gR   { git remote --verbose @args }
function gRa  { git remote add @args }
function gRx  { git remote rm @args }
function gRm  { git remote rename @args }
function gRu  { git remote update @args }

# Composer / PHP extras
function cut  { composer test:unit @args }
function ctt  { composer test:types @args }
function magento { php -d memory_limit=2048M ./bin/magento @args }

# `get` -- resumable, progress-bar download (mirrors zsh alias)
function get { curl --continue-at - --location --progress-bar --remote-name --remote-time @args }

# ---------------------------------------------------------------------------
# 5. Source ~/.config/secrets if present. Parses KEY=value lines (ignores
#    comments and `export` prefixes), sets them as session env vars.
# ---------------------------------------------------------------------------
$secrets = "$env:USERPROFILE\.config\secrets"
if (Test-Path $secrets) {
  Get-Content $secrets | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    $line = $line -replace '^export\s+', ''
    if ($line -match '^([A-Z_][A-Z0-9_]*)\s*=\s*(.*)$') {
      $name  = $matches[1]
      $value = $matches[2].Trim().Trim('"').Trim("'")
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

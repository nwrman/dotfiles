#Requires -Version 5.1
<#
.SYNOPSIS
  Windows bootstrap for the dotfiles repo. Native cmd.exe daily-driver, no WSL.
.DESCRIPTION
  Analog of scripts/bootstrap-linux.sh. Installs CLI tools via winget + scoop,
  wires Clink + clink-fzf + clink-zoxide + carapace + fnm into cmd.exe, places
  selected dotfiles into Windows-native config paths, and copies cmd shims
  (open, pbcopy, pbpaste, which) into ~/.bin.
.PARAMETER Role
  'personal' or 'work'. If omitted, read from ~/.machine-role or prompt.
.PARAMETER SkipPackages
  Skip the winget/scoop install loop. Useful for iterating on shim/Clink/dotfiles steps.
#>
[CmdletBinding()]
param(
  [ValidateSet('personal', 'work')]
  [string]$Role,
  [switch]$SkipPackages
)

# Continue (not Stop) -- this script orchestrates many native commands whose
# stderr writes PowerShell would otherwise raise as NativeCommandError, halting
# the whole bootstrap on benign progress messages (e.g. `git clone`'s
# "Cloning into..." line). Failures we care about are checked explicitly.
$ErrorActionPreference = 'Continue'
Set-StrictMode -Version Latest

$DotfilesDir = Split-Path -Parent $PSScriptRoot
$ScriptsDir  = $PSScriptRoot

Write-Host "========================================"
Write-Host "  Dotfiles Bootstrap (Windows)"
Write-Host "  Repo: $DotfilesDir"
Write-Host "========================================"
Write-Host ""

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ';' +
              [Environment]::GetEnvironmentVariable("Path", "User")
}

function Ensure-Dir {
  param([Parameter(Mandatory)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Has-Command {
  param([Parameter(Mandatory)][string]$Name)
  $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-Dotfile {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Destination
  )
  if (-not (Test-Path -LiteralPath $Source)) {
    Write-Warning "  source missing: $Source"
    return
  }
  $destDir = Split-Path -Parent $Destination
  if ($destDir) { Ensure-Dir $destDir }

  if (Test-Path -LiteralPath $Destination) {
    $item = Get-Item -LiteralPath $Destination -Force
    if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -and $item.Target[0] -eq $Source) {
      Write-Host "  already linked: $(Split-Path -Leaf $Destination)"
      return
    }
    $backup = "$Destination.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $Destination -Destination $backup -Force
    Write-Host "  backed up existing: $(Split-Path -Leaf $Destination) -> $(Split-Path -Leaf $backup)"
  }

  try {
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
    Write-Host "  linked:  $(Split-Path -Leaf $Destination)"
  } catch {
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    Write-Warning "  copied (no symlink): $Destination -- enable Developer Mode to allow symlinks"
  }
}

# ----------------------------------------------------------------------------
# 1. Machine role
# ----------------------------------------------------------------------------
$RoleFile = "$env:USERPROFILE\.machine-role"
if (-not $Role) {
  if (Test-Path -LiteralPath $RoleFile) {
    $Role = (Get-Content $RoleFile).Trim()
    Write-Host "==> Machine role: $Role (from $RoleFile)"
  } else {
    Write-Host "==> No machine role found."
    Write-Host "    1) personal"
    Write-Host "    2) work"
    $choice = Read-Host "    Enter 1 or 2"
    $Role = switch ($choice) {
      '1' { 'personal' }
      '2' { 'work' }
      default { Write-Warning "Invalid choice. Defaulting to 'personal'."; 'personal' }
    }
    Set-Content -Path $RoleFile -Value $Role -Encoding ASCII
    Write-Host "    Saved '$Role' to $RoleFile"
  }
} else {
  Set-Content -Path $RoleFile -Value $Role -Encoding ASCII
  Write-Host "==> Machine role: $Role (set via -Role)"
}
Write-Host ""

# ----------------------------------------------------------------------------
# 2. Package managers
# ----------------------------------------------------------------------------
if (-not (Has-Command winget)) {
  throw "winget not found. Update 'App Installer' from the Microsoft Store, then re-run."
}

if (-not (Has-Command scoop)) {
  Write-Host "==> Installing scoop..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
  Refresh-Path
}

# Source package manifests
. "$ScriptsDir\packages.ps1"
if ($Role -eq 'work') {
  . "$ScriptsDir\packages.work.ps1"
}

# ----------------------------------------------------------------------------
# 3. winget packages
# ----------------------------------------------------------------------------
if (-not $SkipPackages) {
  Write-Host ""
  Write-Host "==> Installing winget packages (elevated child)..."
  Write-Host "    A UAC prompt will appear -- accept it to proceed."

  $wingetHelper = Join-Path $ScriptsDir '_winget-install.ps1'
  $proc = Start-Process powershell `
    -Verb RunAs `
    -ArgumentList @(
      '-NoProfile',
      '-ExecutionPolicy', 'Bypass',
      '-File', $wingetHelper,
      '-DotfilesDir', $DotfilesDir,
      '-Role', $Role
    ) `
    -Wait `
    -PassThru
  if ($proc.ExitCode -ne 0) {
    Write-Warning "Elevated winget loop exited with code $($proc.ExitCode); continuing with remaining steps."
  }

  Refresh-Path

  # --------------------------------------------------------------------------
  # 4. scoop packages
  # --------------------------------------------------------------------------
  Write-Host ""
  Write-Host "==> Installing scoop packages..."
  & scoop bucket add main   2>&1 | Out-Null
  & scoop bucket add extras 2>&1 | Out-Null
  foreach ($pkg in $WindowsScoopPackages) {
    $listed = & scoop list $pkg.Name 2>$null | Select-String -Pattern "^\s*$([regex]::Escape($pkg.Name))\s"
    if ($listed) {
      Write-Host "  -- $($pkg.Name) (already installed)"
    } else {
      Write-Host "  -> $($pkg.Name)"
      & scoop install "$($pkg.Bucket)/$($pkg.Name)"
    }
  }
  Refresh-Path
} else {
  Write-Host "==> -SkipPackages set; not running winget/scoop installs."
}

# ----------------------------------------------------------------------------
# 5. cmd shims into ~/.bin (+ PATH)
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Deploying cmd shims to ~/.bin..."
$BinDir = "$env:USERPROFILE\.bin"
Ensure-Dir $BinDir
foreach ($shim in Get-ChildItem "$PSScriptRoot\shims\*.cmd") {
  Copy-Item -Path $shim.FullName -Destination "$BinDir\$($shim.Name)" -Force
  Write-Host "  installed: $($shim.Name)"
}
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$BinDir*") {
  [Environment]::SetEnvironmentVariable("Path", "$BinDir;$userPath", "User")
  Write-Host "==> Added $BinDir to user PATH (new cmd windows only)"
}

# ----------------------------------------------------------------------------
# 5b. PATH augmentation for winget-installed tools that don't auto-PATH
#     (7-Zip, Clink). winget covers most; these are the holdouts.
# ----------------------------------------------------------------------------
function Add-To-User-Path {
  param([Parameter(Mandatory)][string]$Dir)
  if (-not (Test-Path -LiteralPath $Dir)) { return }
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($userPath -notlike "*$Dir*") {
    [Environment]::SetEnvironmentVariable("Path", "$Dir;$userPath", "User")
    Write-Host "  added to user PATH: $Dir"
  }
}

Write-Host ""
Write-Host "==> PATH augmentation..."
Add-To-User-Path 'C:\Program Files\7-Zip'

# Find Clink (winget upgrades the existing Inno Setup install in place)
$ClinkCandidates = @(
  'C:\Program Files (x86)\clink',
  'C:\Program Files\clink',
  "$env:LOCALAPPDATA\Programs\clink"
)
$ClinkDir = $null
foreach ($d in $ClinkCandidates) {
  if (Test-Path -LiteralPath (Join-Path $d 'clink.bat')) {
    $ClinkDir = $d
    Add-To-User-Path $d
    break
  }
}
Refresh-Path

# ----------------------------------------------------------------------------
# 6. Clink + Lua scripts (uses absolute path; doesn't depend on PATH refresh)
# ----------------------------------------------------------------------------
Write-Host ""
if ($ClinkDir) {
  $ClinkBat = Join-Path $ClinkDir 'clink.bat'
  Write-Host "==> Configuring Clink ($ClinkBat)..."
  & $ClinkBat autorun install 2>&1 | Out-Null

  # Clink loads Lua scripts from two locations by default:
  #   1. its install dir (read-only)
  #   2. its state dir = %LOCALAPPDATA%\clink (user-writable)
  # We always target #2. `clink info` reports them under "scripts: ...".
  # Earlier versions of this script used `~\clink`; that only worked if an old
  # AutoRun was using `--profile ~\clink`, which `clink autorun install` resets.
  $ProfileDir = "$env:LOCALAPPDATA\clink"
  Ensure-Dir $ProfileDir
  Write-Host "  scripts dir: $ProfileDir"

  Copy-Item -Path "$ScriptsDir\clink\_dotfiles.lua" `
            -Destination "$ProfileDir\_dotfiles.lua" -Force
  Write-Host "  installed: _dotfiles.lua"

  try {
    Invoke-WebRequest `
      -Uri 'https://raw.githubusercontent.com/chrisant996/clink-fzf/main/fzf.lua' `
      -OutFile "$ProfileDir\fzf.lua" -UseBasicParsing
    Write-Host "  installed: clink-fzf/fzf.lua"
  } catch { Write-Warning "  clink-fzf download failed: $($_.Exception.Message)" }

  try {
    Invoke-WebRequest `
      -Uri 'https://raw.githubusercontent.com/shunsambongi/clink-zoxide/master/zoxide.lua' `
      -OutFile "$ProfileDir\zoxide.lua" -UseBasicParsing
    Write-Host "  installed: clink-zoxide/zoxide.lua"
  } catch { Write-Warning "  clink-zoxide download failed: $($_.Exception.Message)" }

  if (Has-Command git) {
    $GizmosDir = Join-Path $ProfileDir 'clink-gizmos'
    if (-not (Test-Path -LiteralPath $GizmosDir)) {
      & git clone --depth 1 https://github.com/chrisant996/clink-gizmos.git $GizmosDir 2>&1 | Out-Null
      Write-Host "  installed: clink-gizmos (cloned)"
    } else {
      & git -C $GizmosDir pull --ff-only 2>&1 | Out-Null
      Write-Host "  updated:   clink-gizmos"
    }
  }

  # carapace cmd bridge -- try Get-Command first, then fall back to common paths
  $carapaceExe = (Get-Command carapace -ErrorAction SilentlyContinue).Source
  if (-not $carapaceExe) {
    $carapaceCandidates = Get-ChildItem `
      "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\rsteube.Carapace_*" `
      -Filter 'carapace.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($carapaceCandidates) { $carapaceExe = $carapaceCandidates.FullName }
  }
  if ($carapaceExe) {
    try {
      & $carapaceExe _carapace cmd-clink | Set-Content -Path "$ProfileDir\_carapace.lua" -Encoding ASCII
      Write-Host "  installed: _carapace.lua  (from $carapaceExe)"
    } catch { Write-Warning "  carapace clink bridge failed: $($_.Exception.Message)" }
  } else {
    Write-Warning "  carapace not found; skipping bridge generation"
  }

  # Persist Clink settings that the third-party Lua scripts expose. We CAN'T do
  # this via settings.set() inside _dotfiles.lua because the underscore-prefixed
  # file loads BEFORE fzf.lua / zoxide.lua register those settings -- the value
  # would be discarded. Writing via `clink set` puts it in clink_settings (disk),
  # which is applied AFTER all Lua scripts register defaults each session.
  Write-Host "  persisting Clink settings..."
  $clinkSettings = @(
    @{ Key = 'fzf.default_bindings'; Value = 'true' },
    @{ Key = 'fzf.height';           Value = '60%' },
    @{ Key = 'zoxide.cmd';           Value = 'cd' },
    @{ Key = 'zoxide.hook';          Value = 'pwd' }
  )
  foreach ($s in $clinkSettings) {
    & $ClinkBat set $s.Key $s.Value 2>&1 | Out-Null
  }
} else {
  Write-Warning "clink not found on disk; skipping Clink config (re-run install.ps1 after a new cmd window picks up PATH)."
}

# ----------------------------------------------------------------------------
# 7. fnm AutoRun chain (must run AFTER `clink autorun install`)
# ----------------------------------------------------------------------------
Write-Host ""
if (Has-Command fnm) {
  Write-Host "==> Wiring fnm into cmd AutoRun..."
  $FnmHookDir = "$env:USERPROFILE\.fnm"
  Ensure-Dir $FnmHookDir
  $FnmInit = "$FnmHookDir\fnm_init.cmd"

  $fnmInitContent = @'
@echo off
:: fnm cmd init -- auto-switches Node version on cd into a dir with .nvmrc / .node-version.
:: Chained into HKCU\Software\Microsoft\Command Processor\AutoRun after Clink.
:: stderr is redirected to nul so that, if fnm.exe isn't on PATH yet
:: (e.g. embedded shells launched before the post-install PATH refresh),
:: the AutoRun line stays silent.
if defined FNM_AUTORUN_GUARD goto :EOF
set "FNM_AUTORUN_GUARD=1"
where fnm >nul 2>&1 || goto :EOF
for /f "tokens=*" %%i in ('fnm env --use-on-cd 2^>nul') do call %%i 2>nul
'@
  Set-Content -Path $FnmInit -Value $fnmInitContent -Encoding ASCII

  $AutoRunKey = 'HKCU:\Software\Microsoft\Command Processor'
  if (-not (Test-Path -LiteralPath $AutoRunKey)) {
    New-Item -Path $AutoRunKey -Force | Out-Null
  }
  $current = (Get-ItemProperty -Path $AutoRunKey -Name AutoRun -ErrorAction SilentlyContinue).AutoRun
  if (-not $current) { $current = '' }
  if ($current -notlike "*fnm_init.cmd*") {
    $new = if ($current) { "$current & `"$FnmInit`"" } else { "`"$FnmInit`"" }
    Set-ItemProperty -Path $AutoRunKey -Name AutoRun -Value $new
    Write-Host "  chained: fnm_init.cmd into AutoRun"
  } else {
    Write-Host "  fnm already in AutoRun"
  }

  Write-Host "  current AutoRun: $((Get-ItemProperty -Path $AutoRunKey -Name AutoRun -ErrorAction SilentlyContinue).AutoRun)"
}

# ----------------------------------------------------------------------------
# 8. Dotfiles placement (symlink-first, copy-fallback)
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Placing dotfiles..."

Install-Dotfile -Source "$DotfilesDir\home\.gitconfig"        -Destination "$env:USERPROFILE\.gitconfig"
Install-Dotfile -Source "$DotfilesDir\home\.secrets.example"  -Destination "$env:USERPROFILE\.secrets.example"

# XDG-style configs live under %APPDATA% on Windows (Go's os.UserConfigDir convention).
$xdgMaps = @(
  @{ Src = "$DotfilesDir\home\.config\lazygit";  Dst = "$env:APPDATA\lazygit" },
  @{ Src = "$DotfilesDir\home\.config\gh-dash";  Dst = "$env:APPDATA\gh-dash" },
  @{ Src = "$DotfilesDir\home\.config\carapace"; Dst = "$env:APPDATA\carapace" },
  @{ Src = "$DotfilesDir\home\.config\nvim";     Dst = "$env:LOCALAPPDATA\nvim" }
)
foreach ($m in $xdgMaps) {
  if (Test-Path -LiteralPath $m.Src) {
    Install-Dotfile -Source $m.Src -Destination $m.Dst
  }
}

# PowerShell 7 profile -- placed at $PROFILE.CurrentUserAllHosts so it loads
# in every PS 7 host (terminal console, VS Code PS, etc.). The user can opt
# into pwsh as their daily shell via Windows Terminal; cmd + Clink stays as
# the other supported path.
#
# We ASK pwsh where the profile goes rather than hardcoding -- OneDrive's
# Known Folder Move redirects Documents to %USERPROFILE%\OneDrive\Documents,
# and other setups can have other redirects.
$PSProfileSrc = "$PSScriptRoot\powershell\profile.ps1"
if (Test-Path -LiteralPath $PSProfileSrc) {
  $PSProfileDst = $null
  if (Has-Command pwsh) {
    $PSProfileDst = (& pwsh -NoProfile -Command '$PROFILE.CurrentUserAllHosts' 2>$null | Out-String).Trim()
  }
  if (-not $PSProfileDst) {
    $PSProfileDst = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"
  }
  Install-Dotfile -Source $PSProfileSrc -Destination $PSProfileDst
}

# ----------------------------------------------------------------------------
# 9. npm globals (after fnm wires PATH on next shell — current session may not see them)
# ----------------------------------------------------------------------------
if (-not $SkipPackages -and $WindowsNpmPackages.Count -gt 0) {
  Write-Host ""
  if (Has-Command npm) {
    Write-Host "==> Installing global npm packages..."
    foreach ($p in $WindowsNpmPackages) {
      Write-Host "  -> $p"
      & npm install -g $p 2>&1 | Out-Null
    }
  } else {
    Write-Warning "npm not on PATH yet. After opening a new cmd window (so fnm's AutoRun loads a Node version), run: npm install -g $($WindowsNpmPackages -join ' ')"
  }
}

# ----------------------------------------------------------------------------
# 9b. uv-managed Python CLIs (httpie, etc. -- not packaged in scoop on Windows)
# ----------------------------------------------------------------------------
if (-not $SkipPackages -and $WindowsUvTools -and $WindowsUvTools.Count -gt 0) {
  Write-Host ""
  if (Has-Command uv) {
    Write-Host "==> Installing uv tools..."
    foreach ($p in $WindowsUvTools) {
      Write-Host "  -> $p"
      & uv tool install $p 2>&1 | Out-Null
    }
  } else {
    Write-Warning "uv not on PATH; skipping uv tools ($($WindowsUvTools -join ', '))"
  }
}

# ----------------------------------------------------------------------------
# 10. Reminders
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "========================================"
Write-Host "  Bootstrap complete."
Write-Host "========================================"
Write-Host ""
if (-not (Test-Path -LiteralPath "$env:USERPROFILE\.secrets")) {
  Write-Host "  REMINDER: Create $env:USERPROFILE\.secrets from the example:"
  Write-Host "    copy `"$DotfilesDir\home\.secrets.example`" `"$env:USERPROFILE\.secrets`""
  Write-Host ""
}
Write-Host "  Open a NEW cmd window to pick up:"
Write-Host "    - updated user PATH (Clink, scoop shims, ~/.bin)"
Write-Host "    - AutoRun (Clink + fnm)"
Write-Host ""
Write-Host "  Or open PowerShell 7 (pwsh.exe) for the side-by-side shell with"
Write-Host "  atuin / oh-my-posh / PSReadLine. Profile installed at:"
Write-Host "    $env:USERPROFILE\Documents\PowerShell\profile.ps1"
Write-Host ""
Write-Host "  If symlinks fell back to copies, enable Developer Mode and re-run:"
Write-Host "    Settings > Privacy & security > For developers > Developer Mode"
Write-Host ""

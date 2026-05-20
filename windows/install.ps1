#Requires -Version 5.1
<#
.SYNOPSIS
  One-shot entry point for the dotfiles repo on native Windows.
.DESCRIPTION
  Analog of install.sh. Bootstraps git if needed, clones (or refreshes) the
  dotfiles repo under %USERPROFILE%\projects\dotfiles, then hands off to
  windows\bootstrap.ps1.

  Usage from cmd or PowerShell:
    powershell -ExecutionPolicy Bypass -File windows\install.ps1
    powershell -ExecutionPolicy Bypass -File windows\install.ps1 -Role personal

  Curl-pipe (PowerShell):
    iwr -useb https://raw.githubusercontent.com/nwrman/dotfiles/master/windows/install.ps1 | iex
#>
[CmdletBinding()]
param(
  [ValidateSet('personal', 'work')]
  [string]$Role,
  [switch]$SkipPackages,
  [string]$RepoUrl = 'https://github.com/nwrman/dotfiles.git',
  [string]$RepoDir = "$env:USERPROFILE\projects\dotfiles"
)

$ErrorActionPreference = 'Stop'

# Windows 10/11 check
$os = [Environment]::OSVersion.Version
if ($os.Major -lt 10) {
  throw "Windows 10 or later required (detected $os)."
}

# ----------------------------------------------------------------------------
# Ensure git
# ----------------------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Neither git nor winget is available. Install App Installer from the Microsoft Store, then re-run."
  }
  Write-Host "==> Installing git via winget..."
  & winget install --id Git.Git --exact --silent `
    --accept-source-agreements --accept-package-agreements
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ';' +
              [Environment]::GetEnvironmentVariable("Path", "User")
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git install via winget appeared to succeed but git is still not on PATH. Open a new shell and re-run."
  }
}

# ----------------------------------------------------------------------------
# Determine local repo location
# ----------------------------------------------------------------------------
# If running from a checked-out clone, prefer that location. Otherwise clone.
# This script lives in <repo>\windows\, so the repo root is $PSScriptRoot's parent.
$LocalRepo = $null
$ScriptParent = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { $null }
if ($ScriptParent -and (Test-Path -LiteralPath (Join-Path $ScriptParent '.git'))) {
  $LocalRepo = $ScriptParent
  Write-Host "==> Using checked-out repo: $LocalRepo"
} elseif (Test-Path -LiteralPath (Join-Path $RepoDir '.git')) {
  $LocalRepo = $RepoDir
  Write-Host "==> Updating existing repo: $LocalRepo"
  & git -C $LocalRepo pull --ff-only
} else {
  Write-Host "==> Cloning $RepoUrl -> $RepoDir"
  $parent = Split-Path -Parent $RepoDir
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  & git clone $RepoUrl $RepoDir
  $LocalRepo = $RepoDir
}

# ----------------------------------------------------------------------------
# Hand off to bootstrap.ps1
# ----------------------------------------------------------------------------
$Bootstrap = Join-Path $LocalRepo 'windows\bootstrap.ps1'
if (-not (Test-Path -LiteralPath $Bootstrap)) {
  throw "Bootstrap script not found: $Bootstrap"
}

Write-Host ""
Write-Host "==> Running bootstrap..."
$bootstrapArgs = @{}
if ($Role)          { $bootstrapArgs.Role = $Role }
if ($SkipPackages)  { $bootstrapArgs.SkipPackages = $true }
& $Bootstrap @bootstrapArgs

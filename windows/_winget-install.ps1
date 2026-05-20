#Requires -Version 5.1
<#
.SYNOPSIS
  Internal helper -- runs the winget install loop in an elevated child process.
.DESCRIPTION
  Spawned by windows/bootstrap.ps1 via `Start-Process -Verb RunAs` so the user
  only sees ONE UAC prompt instead of one per package. winget MSI installs
  silently UAC-hang in non-elevated background contexts, so we batch them here.

  Exit code is always 0 -- winget's own output is the source of truth for which
  packages succeeded. The parent script verifies installation status via `where`
  / `Get-Command` after PATH refresh, not via this helper's exit code.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$DotfilesDir,
  [string]$Role = 'personal'
)

$ErrorActionPreference = 'Continue'  # individual winget failures must not halt the loop

Write-Host "========================================"
Write-Host "  Elevated winget install"
Write-Host "  Role: $Role"
Write-Host "========================================"
Write-Host ""

. "$DotfilesDir\windows\packages.ps1"

foreach ($pkg in $WindowsWingetPackages) {
  Write-Host ""
  Write-Host "==> $($pkg.Name)  [$($pkg.Id)]"
  & winget install --id $pkg.Id --exact --silent --disable-interactivity `
    --accept-source-agreements --accept-package-agreements
}

if ($Role -eq 'work') {
  . "$DotfilesDir\windows\packages.work.ps1"
  Write-Host ""
  Write-Host "==> Work-only winget packages..."
  foreach ($pkg in $WindowsWingetWorkPackages) {
    Write-Host ""
    Write-Host "==> $($pkg.Name)  [$($pkg.Id)]"
    & winget install --id $pkg.Id --exact --silent --disable-interactivity `
      --accept-source-agreements --accept-package-agreements
  }
}

Write-Host ""
Write-Host "Elevated winget loop complete. Window will close in 3s."
Start-Sleep -Seconds 3
exit 0

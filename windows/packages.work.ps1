# packages.work.ps1 — work-only CLI tools.
# Mirrors Brewfile.work.linux. Sourced by windows/bootstrap.ps1 only when
# ~/.machine-role contains "work".

$WingetWorkPackages = @(
  @{ Id = 'Amazon.AWSCLI';        Name = 'awscli' },
  @{ Id = 'Microsoft.AzureCLI';   Name = 'azure-cli' },
  @{ Id = 'CaddyServer.Caddy';    Name = 'caddy' },
  @{ Id = 'GoLang.Go';            Name = 'go' }
)

$ScoopWorkPackages = @()
$NpmWorkPackages   = @()

$global:WindowsWingetWorkPackages = $WingetWorkPackages
$global:WindowsScoopWorkPackages  = $ScoopWorkPackages
$global:WindowsNpmWorkPackages    = $NpmWorkPackages

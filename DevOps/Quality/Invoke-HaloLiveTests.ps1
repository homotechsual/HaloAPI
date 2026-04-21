<#
    .SYNOPSIS
        Local wrapper that loads Halo test credentials from Azure Key Vault and
        runs the specified test suites.
    .DESCRIPTION
        Retrieves the four Halo testing secrets from the 'MSPsUK' Key Vault,
        sets them as process-scoped environment variables, then delegates to
        DevOps\Quality\test.ps1 with whatever parameters are passed through.

        This script is intended for local developer use only. It requires an
        active Az PowerShell session (Connect-AzAccount) before running.

        Example usage:
            pwsh -File .\DevOps\Quality\Invoke-HaloLiveTests.ps1 -Suite Live
            pwsh -File .\DevOps\Quality\Invoke-HaloLiveTests.ps1 -Suite Live,E2E -Verbosity Normal
            pwsh -File .\DevOps\Quality\Invoke-HaloLiveTests.ps1 -Suite Live -IncludeVSCodeMarker
    .NOTES
        Secrets loaded from Key Vault 'MSPsUK':
            HaloTestingURL, HaloTestingClientID, HaloTestingClientSecret, HaloTestingTenant
#>
#requires -Version 7
#requires -Module @{ ModuleName = 'Az.KeyVault'; ModuleVersion = '5.0.0' }
#requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.5.0'; MaximumVersion = '5.999' }
param(
    # Enables VS Code Pester markers when running the test script interactively.
    [switch]$IncludeVSCodeMarker,
    # The test suites to execute. Defaults to Live.
    [ValidateSet('E2E', 'Live', 'Meta', 'Unit')]
    [string[]]$Suite = @('Live'),
    # The Pester output verbosity level.
    [ValidateSet('Detailed', 'Normal', 'Minimal', 'None')]
    [string]$Verbosity = 'Detailed',
    # Enables Pester code coverage output for the selected suites.
    [switch]$CodeCoverage,
    # The Azure Key Vault name to retrieve secrets from.
    [string]$VaultName = 'MSPsUK'
)

$ErrorActionPreference = 'Stop'

Write-Host "Loading Halo test credentials from Key Vault '$VaultName'..." -ForegroundColor Cyan

$secretNames = @(
    'HaloTestingURL',
    'HaloTestingClientID',
    'HaloTestingClientSecret',
    'HaloTestingTenant'
)

foreach ($secretName in $secretNames) {
    $secretValue = Get-AzKeyVaultSecret -VaultName $VaultName -Name $secretName -AsPlainText
    if ([string]::IsNullOrEmpty($secretValue)) {
        throw "Key Vault secret '$secretName' returned empty or null from vault '$VaultName'."
    }
    [System.Environment]::SetEnvironmentVariable($secretName, $secretValue, 'Process')
    Write-Verbose "Set `$env:$secretName from Key Vault."
}

Write-Host 'Credentials loaded. Invoking test runner...' -ForegroundColor Cyan

$testScript = Join-Path -Path $PSScriptRoot -ChildPath 'test.ps1'

$testParams = @{
    Suite = $Suite
    Verbosity = $Verbosity
}

if ($IncludeVSCodeMarker) {
    $testParams['IncludeVSCodeMarker'] = $true
}

if ($CodeCoverage) {
    $testParams['CodeCoverage'] = $true
}

& $testScript @testParams

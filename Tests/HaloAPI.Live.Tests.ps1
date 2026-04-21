<#
    .SYNOPSIS
        Live test suite for the HaloAPI module.
    .NOTES
        Requires environment variables: HaloTestingURL, HaloTestingClientID,
        HaloTestingClientSecret, HaloTestingTenant. These tests make real HTTP
        calls against a Halo instance and should not run in standard CI.
        Run via: pwsh -File .\DevOps\Quality\test.ps1 -Suite Live
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Test file - parameters are used in separate scopes.')]
param()

BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'HaloAPI'
    $ManifestPath = "$($ModulePath)\$($ModuleName).psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$False
}

Describe 'Connect' {
    BeforeAll {
        $TestingURL = ([System.UriBuilder]$env:HaloTestingURL).ToString()
        $HaloCorrectConnectionParameters = @{
            URL = $TestingURL
            ClientID = $env:HaloTestingClientID
            ClientSecret = $env:HaloTestingClientSecret
            Scopes = 'all'
            Tenant = $env:HaloTestingTenant
        }
        $HaloIncorrectURLConnectionParameters = @{
            URL = 'https://nx.halopsa.com:443/'
            ClientID = $env:HaloTestingClientID
            ClientSecret = $env:HaloTestingClientSecret
            Scopes = 'all'
            Tenant = $env:HaloTestingTenant
        }
        $HaloIncorrectSecretConnectionParameters = @{
            URL = $TestingURL
            ClientID = $env:HaloTestingClientID
            ClientSecret = 'clearlyincorrect'
            Scopes = 'all'
            Tenant = $env:HaloTestingTenant
        }
    }
    Context 'with correct parameters' {
        It 'connects successfully' {
            Connect-HaloAPI @HaloCorrectConnectionParameters 6>&1 | Should -Be "Connected to the Halo API with tenant URL $($HaloCorrectConnectionParameters.URL)"
        }
    }
    Context 'with incorrect URL parameter' {
        It 'fails with a HTTP 500 status code.' {
            { Connect-HaloAPI @HaloIncorrectURLConnectionParameters } | Should -Throw -ExceptionType 'System.Net.Http.HttpRequestException' -ExpectedMessage 'Response status code does not indicate success: 500 (Internal Server Error).'
        }
    }
    Context 'with incorrect Client Secret parameter' {
        It 'fails with a HTTP 401 status code.' {
            { Connect-HaloAPI @HaloIncorrectSecretConnectionParameters } | Should -Throw -ExceptionType 'System.Net.Http.HttpRequestException' -ExpectedMessage 'Response status code does not indicate success: 401 (Unauthorized).'
        }
    }
}

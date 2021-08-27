<#
    .SYNOPSIS
        Core test suite for the HaloAPI module.
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

# Test that we can login to Halo, and that it does indeed fail as expected if the login information is incorrect.
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
            Tenant = $env:HaloTestingTenan
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
            Connect-HaloAPI @HaloCorrectConnectionParameters 6>&1 | Should -Be "Connected to the Halo API with tenant URL $($HaloCorrectConnectionParameters.URL)/"
        }
    }
    Context 'with incorrect URL parameter' {
        It 'fails with a HTTP 500 status code.' {
            { Connect-HaloAPI @HaloIncorrectURLConnectionParameters } | Should -Throw -ExceptionType 'System.Net.Http.HttpRequestException' -ExpectedMessage 'Connect-HaloAPI failed. Halo''s API provided the status code 500: Internal Server Error. You can use "Get-Error" for detailed error information.'
        }
    }
    Context 'with incorrect Client Secret parameter' {
        It 'fails with a HTTP 401 status code.' {
            { Connect-HaloAPI @HaloIncorrectSecretConnectionParameters } | Should -Throw -ExceptionType 'System.Net.Http.HttpRequestException' -ExpectedMessage 'Connect-HaloAPI failed. Halo''s API provided the status code 401: Unauthorized. You can use "Get-Error" for detailed error information.'
        }
    }
}
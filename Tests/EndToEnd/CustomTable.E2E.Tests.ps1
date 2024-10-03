<#
    .SYNOPSIS
        E2E custom table entity test suite for the HaloAPI module.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Test file - parameters are used in separate scopes.')]
param()

BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath))
    $ModuleName = 'HaloAPI'
    $ManifestPath = "$($ModulePath)\$($ModuleName).psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$False
    $HaloConnectionParameters = @{
        URL = $env:HaloTestingURL
        ClientID = $env:HaloTestingClientID
        ClientSecret = $env:HaloTestingClientSecret
        Scopes = 'all'
        Tenant = $env:HaloTestingTenant
    }
    Connect-HaloAPI @HaloConnectionParameters *> $null
}

#TODO: This will also need tests for create.
# Test that we can fetch a custom table.
Describe 'CustomTable' {
    BeforeEach {
        $CurrentCustomTableId = (Get-HaloCustomTable | Select-Object -First 1 | Select-Object -ExpandProperty ID)
    }
    Context 'Get All' {
        It 'succeeds to get multiple custom tables.' {
            $CustomTableResult = Get-HaloCustomTable
            $CustomTableResult.Count | Should -BeGreaterThan 1
        }
    }
    Context 'Get Single' {
        It 'succeeds to get a specific custom table.' {
            $CustomTableResult = Get-HaloCustomTable -CustomTableId $CurrentCustomTableId
            $CustomTableResult.Count | Should -Be 1
            $CustomTableResult.id | Should -Be $CurrentCustomTableId
        }
        It 'fails to get a non existent custom table' {
            $CustomTableId = 50
            { Get-HaloCustomTable -CustomTableId $CustomTableId } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 404 (Not Found).'
        }
    }
}
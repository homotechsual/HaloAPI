<#
    .SYNOPSIS
        E2E agent entity test suite for the HaloAPI module.
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

# Test that we can create an action, fetch it, update it and then delete it.
Describe 'Agent' {
    BeforeEach {
        $CurrentAgentId = (Get-HaloAgent -ShowAll | Sort-Object -Property ID | Select-Object -Last 1 | Select-Object -ExpandProperty ID)
        $ValidAgent = @{
            name = 'Automated Testing'
            isdisabled = $False
            email = 'testing@homotechsual.dev'
        }
        $AgentsArray = @(
            @{
                name = 'Automated Testing Array 1'
                isdisabled = $False
                email = 'testing-a1@homotechsual.dev'
            },
            @{
                name = 'Automated Testing Array 2'
                isdisabled = $False
                email = 'testing-a2@homotechsual.dev'
            }
        )
        $InvalidAgentMissingName = @{
            isdisabled = $False
            email = 'testing@homotechsual.dev'
        }
        $AgentAfterCreate = @{
            name = 'Automated Testing'
            isdisabled = $False
            email = 'testing@homotechsual.dev'
        }
        $ArrayOfAgentsAfterCreate = @(
            @{
                name = 'Automated Testing'
                isdisabled = $False
                email = 'testing@homotechsual.dev'
            },
            @{
                name = 'Automated Testing'
                isdisabled = $False
                email = 'testing@homotechsual.dev'
            }
        )
    }
    Context 'Create' {
        It 'succeeds with a valid agent object.' {
            $AgentResult = New-HaloAgent -Agent $ValidAgent
            $AgentResult.colour | Should -Not -BeNullOrEmpty
            $AgentResult.name | Should -Be 'Automated Testing'
            $AgentResult.id | Should -Be ($CurrentAgentId + 1)
        }
        It 'fails with a missing name property' {
            { New-HaloAgent -Agent $InvalidAgentMissingName } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 400 (Bad Request).'
        }
    }
    Context 'CreateArray' {
        It 'succeeds with an array of valid agent objects.' {
            $AgentsResult = New-HaloAgent -Agent $AgentsArray
            $AgentsResult | ForEach-Object {
                $_.colour | Should -Not -BeNullOrEmpty
                $_.name | Should -BeLike 'Automated Testing Array*'
                $_.id | Should -Be (($CurrentAgentId + 1) -or ($CurrentAgentId + 2))
            }
        }
    }
    Context 'Get' {
        It 'succeeds to get the created agent.' {
            $AgentResult = Get-HaloAgent -AgentId ($CurrentAgentId - 2)
            $AgentResult.name | Should -Be 'Automated Testing'
            $AgentResult.id | Should -Be ($CurrentAgentId - 2)
        }
        It 'succeeds to get the agent who created the token.' {
            $AgentResult = Get-HaloAgent -Me
            $AgentResult.name | Should -Be 'Admin'
            $AgentResult.id | Should -Be 3
        }
        It 'fails to get a non existent agent.' {
            $AgentId = 9999
            { Get-HaloAgent -AgentId $AgentId } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 404 (Not Found).'
        }
    }
 
    Context 'Update' {
        It 'succeeds with a valid update.' {
            $AgentAfterCreate.id = ($CurrentAgentId)
            $AgentAfterCreate.name = 'Automated Testing Updated'
            $AgentAfterCreate.team = 'Sales'
            $AgentResult = Set-HaloAgent -Agent $AgentAfterCreate
            $AgentResult.team | Should -Be 'Sales'
        }
        It 'succeeds with a valid array of updates.' {
            $ArrayOfAgentsAfterCreate[0].id = ($CurrentAgentId - 1)
            $ArrayOfAgentsAfterCreate[0].name = 'Automated Testing Array 1 Updated'
            $ArrayOfAgentsAfterCreate[0].team = 'Infrastructure'
            $ArrayOfAgentsAfterCreate[1].id = ($CurrentAgentId)
            $ArrayOfAgentsAfterCreate[1].name = 'Automated Testing Array 2 Updated'
            $ArrayOfAgentsAfterCreate[1].team = 'Infrastructure'
            $ArrayOfAgentsResult = Set-HaloAgent -Agent $ArrayOfAgentsAfterCreate
            $ArrayOfAgentsResult | ForEach-Object {
                $ArrayOfAgentsResult.name | Should -BeLike '*Updated'
                $ArrayOfAgentsResult.team | Should -Be 'Infrastructure'
            }
        }
        It 'fails with an invalid agent ID.' {
            $AgentAfterCreate.id = 9999
            { Set-HaloAgent -Agent $AgentAfterCreate } | Should -Throw -ExceptionType 'System.Exception'
        }
        It 'fails with an invalid agent ID in an array.' {
            $ArrayOfAgentsAfterCreate[1].id = 9999
            { Set-HaloAgent -Agent $ArrayOfAgentsAfterCreate } | Should -Throw -ExceptionType 'System.Exception'
        }
    }
    Context 'Delete' {
        It 'succeeds with a valid ticket and agent id.' {
            $AgentResult = Remove-HaloAgent -AgentId ($CurrentAgentId) -Confirm:$False
            $AgentResult.id | Should -Be ($CurrentAgentId)
        }
        It 'can no longer get deleted agent.' {
            { Get-HaloAgent -AgentId ($CurrentAgentId + 1) } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 404 (Not Found).'
        }
    }
}

AfterAll {
    Get-HaloAgent -ShowAll | Where-Object { $_.name -like 'Automated Testing*' } | ForEach-Object { Remove-HaloAgent -AgentId $_.id -Confirm:$False }
}
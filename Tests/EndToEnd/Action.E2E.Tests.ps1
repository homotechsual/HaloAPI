<#
    .SYNOPSIS
        E2E action entity test suite for the HaloAPI module.
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

    $TicketID = 2200
    $ActionID = (Get-HaloAction -TicketID $TicketID -Count 1 | Select-Object -First 1 | Select-Object -ExpandProperty ID)
}

# Test that we can create an action, fetch it, update it and then delete it.
Describe 'Action' {
    BeforeEach {
        $ValidAction = @{
            ticket_id = $TicketID
            who = 'Admin'
            who_type = 1
            who_agentid = 3
            note = 'This is an action created by a Pester automated test.'
            note_html = '<p>This is an action created by a Pester automated test.</p>'
            outcome = 'New'
        }
        $InvalidActionMissingTicketID = @{
            who = 'Admin'
            who_type = 1
            note = 'This is an action created by a Pester automated test.'
            note_html = '<p>This is an action created by a Pester automated test.</p>'
            outcome = 'New'
        }
        $InvalidActionMissingOutcome = @{
            ticket_id = $TicketID
            who = 'Admin'
            who_type = 1
            note = 'This is an action created by a Pester automated test.'
            note_html = '<p>This is an action created by a Pester automated test.</p>'
        }
        $ActionAfterCreate = @{
            id = $ActionID
            ticket_id = $TicketID
            who = 'Admin'
            who_type = 1
            note = 'This is an action created by a Pester automated test.'
            note_html = '<p>This is an action created by a Pester automated test.</p>'
        }
        $ArrayOfActionsAfterCreate = @(
            @{
                id = $ActionID + 1
                ticket_id = $TicketID
                who = 'Admin'
                who_type = 1
                note = 'This is an action created by a Pester automated test.'
                note_html = '<p>This is an action created by a Pester automated test.</p>'
            },
            @{
                id = $ActionID + 2
                ticket_id = $TicketID
                who = 'Admin'
                who_type = 1
                note = 'This is an action created by a Pester automated test.'
                note_html = '<p>This is an action created by a Pester automated test.</p>'
            }
        )
    }
    Context 'Create' {
        It 'succeeds with a valid Action object.' {
            $ActionResult = New-HaloAction -Action $ValidAction
            $ActionResult.actionby_application_id | Should -Be 'AzureDevops Testing App'
            $ActionResult.note | Should -BeLike 'This is an action created by a Pester automated test.*'
            $ActionResult.id | Should -Be ($ActionID + 1)
        }
        It 'succeeds with an array of valid Action objects.' {
            $ActionResult = New-HaloAction -Action @($ValidAction, $ValidAction)
            $ArrayActionID = ($ActionID + 1)
            $ActionResult | ForEach-Object {
                $ActionResult.actionby_application_id | Should -Be 'AzureDevops Testing App'
                $ActionResult.note | Should -BeLike 'This is an action created by a Pester automated test.*'
                $ActionResult.id | Should -Be ($ArrayActionID + 1)
                $ArrayActionID++
            }
        }
        It 'fails with a missing ticket id property' {
            { New-HaloAction -Action $InvalidActionMissingTicketID } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 400 (Bad Request).'
        }
        It 'fails with a missing outcome property.' {
            { New-HaloAction -Action $InvalidActionMissingOutcome } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 400 (Bad Request).'
        }
    }

    Context 'Get' {
        BeforeAll {
            Connect-HaloAPI @HaloConnectionParameters *> $null
        }
        It 'succeeds to get the created action.' {
            $ActionResult = Get-HaloAction -ActionID $ActionID -TicketID $TicketID
            $ActionResult.actionby_application_id | Should -Be 'AzureDevops Testing App'
            $ActionResult.note | Should -BeLike 'This is an action created by a Pester automated test.*'
            $ActionResult.id | Should -Be $ActionID
        }
        It 'fails to get a non existent action' {
            $ActionID = 3
            { Get-HaloAction -ActionID $ActionID -TicketID $TicketID } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 404 (Not Found).'
        }
    }
    
    Context 'Update' {
        BeforeAll {
            Connect-HaloAPI @HaloConnectionParameters *> $null
        }
        It 'succeeds with a valid update.' {
            $ActionAfterCreate.note = 'This action has been updated by a Pester automated test.'
            $ActionAfterCreate.note_html = '<p>This action has been updated by a Pester automated test.</p>'
            $ActionResult = Set-HaloAction -Action $ActionAfterCreate
            $ActionResult.note | Should -BeLike 'This action has been updated by a Pester automated test.*'
        }
        It 'succeeds with a valid array of updates.' {
            $ArrayOfActionsAfterCreate[0].note = 'This action has been updated by a Pester automated test.'
            $ArrayOfActionsAfterCreate[0].note_html = '<p>This action has been updated by a Pester automated test.</p>'
            $ArrayOfActionsAfterCreate[1].note = 'This action has been updated by a Pester automated test.'
            $ArrayOfActionsAfterCreate[1].note_html = '<p>This action has been updated by a Pester automated test.</p>'
            $ArrayOfActionsResult = Set-HaloAction -Action $ArrayOfActionsAfterCreate
            $ArrayOfActionsResult | ForEach-Object {
                $ArrayOfActionsResult.note | Should -BeLike 'This action has been updated by a Pester automated test.*'
            }
        }
        It 'fails with no action ID.' {
            $ActionAfterCreate.id = $null
            { Set-HaloAction -Action $ActionAfterCreate } | Should -Throw -ExceptionType 'System.Exception'
        }
        It 'fails with an invalid action ID in an array.' {
            $ArrayOfActionsAfterCreate[1].id = $null
            { Set-HaloAction -Action $ArrayOfActionsAfterCreate } | Should -Throw -ExceptionType 'System.Exception'
        }
    }

    Context 'Delete' {
        BeforeAll {
            Connect-HaloAPI @HaloConnectionParameters *> $null
        }
        It 'succeeds with a valid ticket and action id.' {
            $ActionResult = Remove-HaloAction -ActionID $ActionID -TicketID $TicketID -Confirm:$False
            $ActionResult.id | Should -Be $ActionID
        }
        It 'can no longer get deleted action.' {
            { Get-HaloAction -ActionID $ActionID -TicketID $TicketID } | Should -Throw -ExceptionType 'System.Exception' -ExpectedMessage 'Response status code does not indicate success: 404 (Not Found).'
        }
    }

    AfterAll {
        Remove-HaloAction -ActionID ($ActionID + 1) -TicketID $TicketID -Confirm:$False
        Remove-HaloAction -ActionID ($ActionID + 2) -TicketID $TicketID -Confirm:$False
    }
}
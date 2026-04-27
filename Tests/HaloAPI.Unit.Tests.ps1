<#
    .SYNOPSIS
        Unit test suite for the HaloAPI module.
    .NOTES
        All HTTP calls are mocked. No live Halo instance is required.
        Mocks target the private request functions via -ModuleName 'HaloAPI'.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Test file - parameters are used in separate scopes.')]
param()

BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'HaloAPI'
    $ManifestPath = ('{0}\{1}.psd1' -f $ModulePath, $ModuleName)
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$False
}

Describe 'Get-HaloClient' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -MockWith { return @{} }
    }

    It 'requests the multi endpoint when no ClientID is provided' {
        Get-HaloClient
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/client'
        } -Times 1 -Exactly
    }

    It 'maps -Search to the search query key' {
        Get-HaloClient -Search 'Fabrikam'
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/client' -and $QSCollection['search'] -eq 'Fabrikam'
        } -Times 1 -Exactly
    }

    It 'requests the single-client resource path when -ClientID is provided' {
        Get-HaloClient -ClientID 42
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/client/42'
        } -Times 1 -Exactly
    }

    It 'maps -PageSize to the page_size query key via its alias' {
        Get-HaloClient -PageSize 50
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $QSCollection['page_size'] -eq 50
        } -Times 1 -Exactly
    }

    It 'maps the -IncludeActive switch to the includeactive query key' {
        Get-HaloClient -IncludeActive
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $QSCollection['includeactive'] -eq 'true'
        } -Times 1 -Exactly
    }
}

Describe 'New-HaloTicket' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { return @{} }
    }

    It 'posts to the tickets endpoint' {
        New-HaloTicket -Ticket @{ subject = 'Test ticket' }
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Endpoint -eq 'tickets'
        } -Times 1 -Exactly
    }

    It 'passes the provided ticket object through to the request body' {
        $TicketObject = @{ subject = 'Body check'; client_id = 7 }
        New-HaloTicket -Ticket $TicketObject
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Object[0].subject -eq 'Body check' -and $Object[0].client_id -eq 7
        } -Times 1 -Exactly
    }
}

Describe 'New-HaloDistributionListMember' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { return @{} }
    }

    It 'posts to the correct distribution list members endpoint' {
        New-HaloDistributionListMember -DistributionListID 99 -Member @{ agent_id = 1 }
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Endpoint -eq 'distributionlist/99/members'
        } -Times 1 -Exactly
    }

    It 'passes the provided member object through to the request body' {
        $MemberObject = @{ agent_id = 7 }
        New-HaloDistributionListMember -DistributionListID 1 -Member $MemberObject
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Object[0].agent_id -eq 7
        } -Times 1 -Exactly
    }

    It 'does not call New-HaloPOSTRequest when -WhatIf is specified' {
        New-HaloDistributionListMember -DistributionListID 5 -Member @{ agent_id = 2 } -WhatIf
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }
}

Describe 'Remove-HaloTemplate' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTemplate' -ModuleName 'HaloAPI' -MockWith {
            return [pscustomobject]@{ id = 5; name = 'Test Template' }
        }
        Mock -CommandName 'New-HaloDELETERequest' -ModuleName 'HaloAPI' -MockWith { return @{} }
    }

    It 'deletes via the correct template resource path' {
        Remove-HaloTemplate -TemplateID 5 -Confirm:$false
        Should -Invoke -CommandName 'New-HaloDELETERequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/template/5'
        } -Times 1 -Exactly
    }
}

Describe 'New-HaloRecurringInvoiceBatch' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -MockWith { return @('ok') }
    }

    It 'passes a flat recurring invoice array to Invoke-HaloBatchProcessor' {
        $RecurringInvoices = @(
            [pscustomobject]@{ id = 101; description = 'Invoice A' },
            [pscustomobject]@{ id = 102; description = 'Invoice B' }
        )

        New-HaloRecurringInvoiceBatch -RecurringInvoices $RecurringInvoices -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -ParameterFilter {
            $EntityType -eq 'RecurringInvoice' -and
            $Operation -eq 'New' -and
            $BatchInput.Count -eq 2 -and
            $BatchInput[0].id -eq 101 -and
            $BatchInput[1].id -eq 102
        } -Times 1 -Exactly
    }

    It 'passes batch tuning values when supplied' {
        New-HaloRecurringInvoiceBatch -RecurringInvoices @([pscustomobject]@{ id = 201 }) -BatchSize 25 -BatchWait 4 -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -ParameterFilter {
            $Size -eq 25 -and $Wait -eq 4
        } -Times 1 -Exactly
    }
}

Describe 'Set-HaloActionBatch' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -MockWith { return @('ok') }
    }

    It 'uses default batch size and wait values' {
        $Actions = @(
            [pscustomobject]@{ id = 1; ticket_id = 2001; details = 'update one' },
            [pscustomobject]@{ id = 2; ticket_id = 2002; details = 'update two' }
        )

        Set-HaloActionBatch -Actions $Actions -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -ParameterFilter {
            $EntityType -eq 'Action' -and
            $Operation -eq 'Set' -and
            $Size -eq 100 -and
            $Wait -eq 1
        } -Times 1 -Exactly
    }

    It 'passes SkipValidation through additional parameters' {
        Set-HaloActionBatch -Actions @([pscustomobject]@{ id = 5; ticket_id = 5001 }) -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -ParameterFilter {
            $null -ne $Parameters -and $Parameters['SkipValidation'] -eq $true
        } -Times 1 -Exactly
    }
}

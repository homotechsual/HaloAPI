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

Describe 'New-HaloQuery' {
    It 'maps aliases and values into the query hashtable' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryAlias {
                [CmdletBinding()]
                param(
                    [Alias('search_term')]
                    [string]$Search,
                    [Alias('open_only')]
                    [switch]$OpenOnly,
                    [Alias('agent_id')]
                    [int32]$AgentID
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryAlias').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryAlias' -Parameters $Parameters
            }

            $Query = Invoke-TestNewHaloQueryAlias -Search 'printer' -OpenOnly -AgentID 9
            $Query['search_term'] | Should -Be 'printer'
            $Query['open_only'] | Should -Be 'true'
            $Query['agent_id'] | Should -Be 9
        }
    }

    It 'adds pagination defaults in multi mode when pagination is unspecified' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryMultiDefault {
                [CmdletBinding()]
                param(
                    [string]$Search
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryMultiDefault').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryMultiDefault' -Parameters $Parameters -IsMulti
            }

            $Query = Invoke-TestNewHaloQueryMultiDefault -Search 'term'
            $Query['pageinate'] | Should -Be 'true'
            $Query['page_size'] | Should -Be $Script:HAPIDefaultPageSize
            $Query['page_no'] | Should -Be 1
        }
    }

    It 'throws when paginating without an initial page number in multi mode' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryRequiresPageNo {
                [CmdletBinding()]
                param(
                    [Alias('pageinate')]
                    [switch]$Paginate
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryRequiresPageNo').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryRequiresPageNo' -Parameters $Parameters -IsMulti
            }

            { Invoke-TestNewHaloQueryRequiresPageNo -Paginate } | Should -Throw -ExpectedMessage 'When using pagination you must specify an initial page number with ''-PageNo''.'
        }
    }

    It 'joins array values when comma-separated arrays are enabled' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryCommaSeparatedArray {
                [CmdletBinding()]
                param(
                    [int32[]]$Team
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryCommaSeparatedArray').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryCommaSeparatedArray' -Parameters $Parameters -CommaSeparatedArrays
            }

            $Query = Invoke-TestNewHaloQueryCommaSeparatedArray -Team @(1, 2, 3)
            $Query['team'] | Should -Be '1,2,3'
        }
    }
}

Describe 'Invoke-HaloBatchProcessor' {
    It 'rejects unsupported operation values' {
        InModuleScope 'HaloAPI' {
            {
                Invoke-HaloBatchProcessor -BatchInput @() -EntityType 'Action' -Operation 'Get'
            } | Should -Throw
        }
    }

    It 'rejects an empty batch input array' {
        InModuleScope 'HaloAPI' {
            {
                Invoke-HaloBatchProcessor -BatchInput @() -EntityType 'Action' -Operation 'Set'
            } | Should -Throw
        }
    }
}

Describe 'New-HaloGETRequest' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'builds a GET request and unwraps the ResourceType payload when autopagination is off' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{
                tickets = @([pscustomobject]@{ id = 1; summary = 'A' })
            }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }

            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{
                pageinate = 'true'
                page_no = 2
                page_size = 10
                search = 'printer'
            } -AutoPaginateOff -ResourceType 'tickets'

            $Result.Count | Should -Be 1
            $Result[0].id | Should -Be 1
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Method -eq 'GET' -and
            $WebRequestParams.Uri -match '^https://example\.halo/api/tickets\?' -and
            $WebRequestParams.Uri -match 'search=printer' -and
            $WebRequestParams.Uri -match 'pageinate=true' -and
            $WebRequestParams.Uri -match 'page_no=2' -and
            $WebRequestParams.Uri -match 'page_size=10'
        }
    }

    It 'iterates paginated responses when page information is provided' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            if ($WebRequestParams.Uri -match 'page_no=1') {
                return [pscustomobject]@{
                    record_count = 3
                    tickets = @(
                        [pscustomobject]@{ id = 1 },
                        [pscustomobject]@{ id = 2 }
                    )
                }
            }

            [pscustomobject]@{
                record_count = 3
                tickets = @([pscustomobject]@{ id = 3 })
            }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }

            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{
                pageinate = 'true'
                page_no = 1
                page_size = 2
            } -ResourceType 'tickets'

            $Result.Count | Should -Be 3
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 2 -Exactly
    }
}

Describe 'New-HaloPOSTRequest' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'builds a POST request with query string and JSON array body' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            return [pscustomobject]@{ status = 'ok' }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $BodyObject = @([pscustomobject]@{ subject = 'Test ticket'; client_id = 7 })

            $Result = New-HaloPOSTRequest -Object $BodyObject -Endpoint 'tickets' -QSCollection @{
                includeinactive = 'true'
                ids = @(1, 2)
            }

            $Result.status | Should -Be 'ok'
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Method -eq 'POST' -and
            $WebRequestParams.Uri -match '^https://example\.halo/api/tickets\?' -and
            $WebRequestParams.Uri -match 'includeinactive=true' -and
            $WebRequestParams.Uri -match 'ids=1' -and
            $WebRequestParams.Uri -match 'ids=2' -and
            $WebRequestParams.Body -match '"subject"\s*:\s*"Test ticket"' -and
            $WebRequestParams.Body -match '"client_id"\s*:\s*7'
        }
    }

    It 'routes non-http exceptions through New-HaloError' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            throw 'boom'
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            New-HaloPOSTRequest -Object @([pscustomobject]@{ subject = 'x' }) -Endpoint 'tickets'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'New-HaloDELETERequest' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'builds a DELETE request with the expected uri' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ deleted = $true }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $Result = New-HaloDELETERequest -Resource 'api/template/5'
            $Result.deleted | Should -BeTrue
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Method -eq 'DELETE' -and
            $WebRequestParams.Uri -eq 'https://example.halo/api/template/5'
        }
    }

    It 'routes non-http exceptions through New-HaloError' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            throw 'delete failed'
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            New-HaloDELETERequest -Resource 'api/template/7'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Connect-HaloAPI' {
    BeforeAll {
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Write-Success' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-TokenExpiry' -ModuleName 'HaloAPI' -MockWith { [datetime]'2026-01-01T00:00:00Z' }
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -MockWith {
            @([pscustomobject]@{ id = 1; name = 'Lookup' })
        }
    }

    It 'uses authinfo endpoint, applies provided tenant, and joins scopes for token request' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"authTenant"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-1' -ClientSecret 'secret-1' -Scopes @('all', 'tickets') -Tenant 'tenantProvided'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'GET' -and $Uri -eq 'https://example.halo/api/authinfo'
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and
            $Uri -eq 'https://auth.example/oauth2/token?tenant=tenantProvided' -and
            $Body.scope -eq 'all tickets' -and
            $Body.client_id -eq 'client-1'
        }
    }

    It 'falls back to auth/token when authinfo response is empty' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = $null }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-2' -ClientSecret 'secret-2' -Scopes 'all' -Tenant 'fallbackTenant'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://example.halo/auth/token?tenant=fallbackTenant'
        }
    }

    It 'returns no confirmation value when NoConfirm is specified' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/","tenant_id":"authTenant"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-3' -ClientSecret 'secret-3' -Scopes 'all' -NoConfirm

        $Result | Should -BeNullOrEmpty
        Should -Invoke -CommandName 'Write-Success' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
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

Describe 'Get-HaloTicket' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -MockWith { return @{} }
    }

    It 'maps multiple filters and aliases to expected query keys' {
        Get-HaloTicket -PageSize 25 -PageNo 2 -AgentID 7 -OpenOnly -Search 'printer'

        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/tickets' -and
            $QSCollection['page_size'] -eq 25 -and
            $QSCollection['page_no'] -eq 2 -and
            $QSCollection['agent_id'] -eq 7 -and
            $QSCollection['open_only'] -eq 'true' -and
            $QSCollection['search'] -eq 'printer'
        } -Times 1 -Exactly
    }

    It 'uses single-ticket resource mode when TicketID is provided' {
        Get-HaloTicket -TicketID 42

        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -ParameterFilter {
            $Resource -eq 'api/tickets/42'
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

    It 'does not call Invoke-HaloBatchProcessor when -WhatIf is specified' {
        Set-HaloActionBatch -Actions @([pscustomobject]@{ id = 8; ticket_id = 8001 }) -WhatIf

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }
}

Describe 'Remove-HaloActionBatch' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -MockWith { return @('ok') }
    }

    It 'does not call Invoke-HaloBatchProcessor when -WhatIf is specified' {
        Remove-HaloActionBatch -Actions @(101, 102) -WhatIf

        Should -Invoke -CommandName 'Invoke-HaloBatchProcessor' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }
}

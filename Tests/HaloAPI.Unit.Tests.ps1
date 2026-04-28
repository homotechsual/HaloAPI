<#
    .SYNOPSIS
        Unit test suite for the HaloAPI module.
    .DESCRIPTION
        Runs mock-driven Pester unit tests for HaloAPI cmdlets and private
        helpers. This suite is designed to run without live Halo credentials.
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

    It 'returns a query string when AsString is specified' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryAsString {
                [CmdletBinding()]
                param(
                    [string]$Search,
                    [Alias('page_no')]
                    [int32]$PageNo,
                    [int32[]]$Team
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryAsString').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryAsString' -Parameters $Parameters -AsString
            }

            $QueryString = Invoke-TestNewHaloQueryAsString -Search 'printer' -PageNo 3 -Team @(1, 2)

            $QueryString | Should -Match '^\?'
            $QueryString | Should -Match 'search=printer'
            $QueryString | Should -Match 'page_no=3'
            $QueryString | Should -Match 'team=1'
            $QueryString | Should -Match 'team=2'
        }
    }

    It 'formats DateTime arrays as ISO values when comma-separated arrays are enabled' {
        InModuleScope 'HaloAPI' {
            function Invoke-TestNewHaloQueryDateArray {
                [CmdletBinding()]
                param(
                    [datetime[]]$Dates
                )
                $Parameters = (Get-Command -Name 'Invoke-TestNewHaloQueryDateArray').Parameters
                New-HaloQuery -CommandName 'Invoke-TestNewHaloQueryDateArray' -Parameters $Parameters -CommaSeparatedArrays
            }

            $DateA = [datetime]'2026-01-01T10:00:00Z'
            $DateB = [datetime]'2026-01-02T12:30:00Z'
            $Query = Invoke-TestNewHaloQueryDateArray -Dates @($DateA, $DateB)

            $Query['dates'] | Should -Match '2026-01-01T10:00:00.0000000\+00:00'
            $Query['dates'] | Should -Match '2026-01-02T12:30:00.0000000\+00:00'
            $Query['dates'] | Should -Match ','
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

Describe 'Invoke-HaloBatchItem' {
    BeforeEach {
        Mock -CommandName 'Connect-HaloAPI' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloDistributionListMember' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{
                Id = $Member.id
                DistributionListID = $DistributionListID
            }
        }
        Mock -CommandName 'Write-Error' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'connects and invokes the target command with merged parameters' {
        InModuleScope 'HaloAPI' {
            $ConnectionInformation = [pscustomobject]@{
                URL = 'https://example.halo/'
                ClientID = 'client-id'
                ClientSecret = 'client-secret'
                AuthScopes = @('all')
                Tenant = 'tenant-id'
                AdditionalHeaders = @{ 'X-Test' = 'HeaderValue' }
            }

            $Result = Invoke-HaloBatchItem -BatchItem ([pscustomobject]@{ id = 42 }) -EntityType 'Member' -CommandName 'New-HaloDistributionListMember' -CommandExists $true -Parameters @{ DistributionListID = 99 } -ConnectionInformation $ConnectionInformation

            $Result.Id | Should -Be 42
            $Result.DistributionListID | Should -Be 99
        }

        Should -Invoke -CommandName 'Connect-HaloAPI' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $URL -eq 'https://example.halo/' -and $ClientID -eq 'client-id' -and $ClientSecret -eq 'client-secret' -and $Scopes[0] -eq 'all' -and $Tenant -eq 'tenant-id'
        }
        Should -Invoke -CommandName 'New-HaloDistributionListMember' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Member.id -eq 42 -and $DistributionListID -eq 99
        }
    }

    It 'writes an error when the target command is unavailable' {
        InModuleScope 'HaloAPI' {
            $ConnectionInformation = [pscustomobject]@{
                URL = 'https://example.halo/'
                ClientID = 'client-id'
                ClientSecret = 'client-secret'
                AuthScopes = @('all')
                Tenant = 'tenant-id'
                AdditionalHeaders = @{}
            }

            $Result = Invoke-HaloBatchItem -BatchItem ([pscustomobject]@{ id = 42 }) -EntityType 'Action' -CommandName 'Missing-HaloAction' -CommandExists $false -ConnectionInformation $ConnectionInformation -ErrorAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
        }

        Should -Invoke -CommandName 'Connect-HaloAPI' -ModuleName 'HaloAPI' -Times 1 -Exactly
        Should -Invoke -CommandName 'Write-Error' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Message -eq "The command Missing-HaloAction doesn't exist or isn't loaded."
        }
    }
}

Describe 'Invoke-HaloRequest' {
    BeforeEach {
        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{
                URL = 'https://example.halo/'
                ClientID = 'client-id'
                ClientSecret = 'client-secret'
                AuthScopes = @('all')
                Tenant = 'tenant-id'
                AdditionalHeaders = @{ 'X-Test' = 'HeaderValue' }
                MaxRetries = 3
            }

            $Script:HAPIAuthToken = [pscustomobject]@{
                Type = 'Bearer'
                Access = 'abc123'
                Expires = [datetime]'2099-01-01T00:00:00Z'
            }
        }

        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Connect-HaloAPI' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'adds the base URL for relative URIs and merges auth and additional headers' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"ok":true}' }
        }

        InModuleScope 'HaloAPI' {
            $Result = Invoke-HaloRequest -WebRequestParams @{
                Method = 'GET'
                Uri = 'api/test'
            }

            $Result.ok | Should -BeTrue
        }

        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://example.halo/api/test' -and
            $Headers.Authorization -eq 'Bearer abc123' -and
            $Headers['X-Test'] -eq 'HeaderValue' -and
            $ContentType -eq 'application/json; charset=utf-8'
        }
    }

    It 'returns the raw web response when RawResult is specified' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"ok":true}'; StatusCode = 200 }
        }

        InModuleScope 'HaloAPI' {
            $Result = Invoke-HaloRequest -WebRequestParams @{
                Method = 'GET'
                Uri = 'https://example.halo/api/test'
            } -RawResult

            $Result.StatusCode | Should -Be 200
            $Result.Content | Should -Be '{"ok":true}'
        }
    }

    It 'refreshes the auth token when expired' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"ok":true}' }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIAuthToken = [pscustomobject]@{
                Type = 'Bearer'
                Access = 'expired-token'
                Expires = [datetime]'2000-01-01T00:00:00Z'
            }

            $null = Invoke-HaloRequest -WebRequestParams @{
                Method = 'GET'
                Uri = 'api/test'
            }
        }

        Should -Invoke -CommandName 'Connect-HaloAPI' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $URL -eq 'https://example.halo/' -and
            $ClientId -eq 'client-id' -and
            $ClientSecret -eq 'client-secret' -and
            $Tenant -eq 'tenant-id'
        }
    }

    It 'retries on 429 responses and succeeds on a subsequent attempt' {
        $CallCount = 0
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('throttled', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            $script:CallCount += 1
            if ($script:CallCount -eq 1) {
                throw $HttpException
            }

            [pscustomobject]@{ Content = '{"ok":true}' }
        }

        InModuleScope 'HaloAPI' {
            $Result = Invoke-HaloRequest -WebRequestParams @{
                Method = 'GET'
                Uri = 'api/test'
            }

            $Result.ok | Should -BeTrue
        }

        Should -Invoke -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -Times 1 -Exactly
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 2 -Exactly
    }

    It 'rethrows non-429 HTTP exceptions' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('bad request', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        }

        InModuleScope 'HaloAPI' {
            {
                Invoke-HaloRequest -WebRequestParams @{
                    Method = 'GET'
                    Uri = 'api/test'
                }
            } | Should -Throw -ExpectedMessage 'bad request'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'calls New-HaloError when retries are exhausted without a result' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith { $null }

        InModuleScope 'HaloAPI' {
            $null = Invoke-HaloRequest -WebRequestParams @{
                Method = 'GET'
                Uri = 'api/test'
            }
        }

        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 3 -Exactly
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $ModuleMessage -match 'Retried request to "https://example\.halo/api/test" 3 times, request unsuccessful\.'
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

    It 'removes page_size when pagination is not enabled' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ ok = $true }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }

            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{
                page_size = 100
                search = 'abc'
            } -AutoPaginateOff

            $Result.ok | Should -BeTrue
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Uri -match 'search=abc' -and
            $WebRequestParams.Uri -notmatch 'page_size='
        }
    }

    It 'returns the full response when ResourceType does not match a response property' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ record_count = 1; tickets = @([pscustomobject]@{ id = 10 }) }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{ search = 'ticket' } -AutoPaginateOff -ResourceType 'users'
            $Result.record_count | Should -Be 1
            $Result.tickets[0].id | Should -Be 10
        }
    }

    It 'passes RawResult to Invoke-HaloRequest when requested' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ ok = $true }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $null = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{ search = 'ticket' } -AutoPaginateOff -RawResult
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $RawResult -eq $true
        }
    }

    It 'stops before request execution when preflight fails' {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {
            throw 'preflight failed'
        }
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {}

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }

            {
                New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{ search = 'x' } -AutoPaginateOff
            } | Should -Throw -ExpectedMessage 'preflight failed'
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'rethrows HttpResponseException without routing through New-HaloError' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('http failure', $Response)

        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            {
                New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{ search = 'x' } -AutoPaginateOff
            } | Should -Throw -ExpectedMessage 'http failure'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'returns no result when pagination is enabled without page_no and AutoPaginateOff is not set' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ should_not_run = $true }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{
                pageinate = 'true'
                page_size = 50
            } -ResourceType 'tickets'

            $Result | Should -BeNullOrEmpty
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'processes a single page when record_count is missing from paginated response' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{
                tickets = @([pscustomobject]@{ id = 42 })
            }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $Result = New-HaloGETRequest -Method 'GET' -Resource 'api/tickets' -QSCollection @{
                pageinate = 'true'
                page_no = 1
                page_size = 10
            } -ResourceType 'tickets'

            $Result.Count | Should -Be 1
            $Result[0].id | Should -Be 42
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly
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

    It 'builds a POST request without query string when QSCollection is not provided' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            return [pscustomobject]@{ status = 'ok' }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $null = New-HaloPOSTRequest -Object @([pscustomobject]@{ subject = 'No QS' }) -Endpoint 'tickets'
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Uri -eq 'https://example.halo/api/tickets'
        }
    }

    It 'stops before request execution when preflight fails' {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {
            throw 'preflight failed'
        }
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {}

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            {
                New-HaloPOSTRequest -Object @([pscustomobject]@{ subject = 'x' }) -Endpoint 'tickets'
            } | Should -Throw -ExpectedMessage 'preflight failed'
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'rethrows HttpResponseException without routing through New-HaloError' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('http failure', $Response)

        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            {
                New-HaloPOSTRequest -Object @([pscustomobject]@{ subject = 'x' }) -Endpoint 'tickets'
            } | Should -Throw -ExpectedMessage 'http failure'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'treats an empty query collection as no query string' {
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            return [pscustomobject]@{ status = 'ok' }
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            $null = New-HaloPOSTRequest -Object @([pscustomobject]@{ subject = 'Empty QS' }) -Endpoint 'tickets' -QSCollection @{}
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WebRequestParams.Uri -eq 'https://example.halo/api/tickets'
        }
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

    It 'stops before request execution when preflight fails' {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {
            throw 'preflight failed'
        }
        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {}

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            {
                New-HaloDELETERequest -Resource 'api/template/8'
            } | Should -Throw -ExpectedMessage 'preflight failed'
        }

        Should -Invoke -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'rethrows HttpResponseException without routing through New-HaloError' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('http failure', $Response)

        Mock -CommandName 'Invoke-HaloRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        }

        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{ URL = 'https://example.halo/' }
            {
                New-HaloDELETERequest -Resource 'api/template/8'
            } | Should -Throw -ExpectedMessage 'http failure'
        }

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly
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
        Mock -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -MockWith {}
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

    It 'uses tenant_id from authinfo when Tenant is not provided' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-4' -ClientSecret 'secret-4' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://auth.example/oauth2/token?tenant=tenantFromAuthInfo'
        }
    }

    It 'stores the base url without path in script connection information' {
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

        InModuleScope 'HaloAPI' {
            $null = Connect-HaloAPI -URL 'https://example.halo/path/segment' -ClientID 'client-5' -ClientSecret 'secret-5' -Scopes 'all'
            $Script:HAPIConnectionInformation.URL | Should -Match '^https://example\.halo(:443)?/$'
        }
    }

    It 'uses /token when auth_url does not contain a path' {
        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-6' -ClientSecret 'secret-6' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://auth.example/token?tenant=tenantFromAuthInfo'
        }
    }

    It 'forwards AdditionalHeaders to auth info and token requests' {
        $Headers = @{ 'X-Test' = 'true' }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-7' -ClientSecret 'secret-7' -Scopes 'all' -AdditionalHeaders $Headers

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'GET' -and $Headers['X-Test'] -eq 'true'
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Headers['X-Test'] -eq 'true'
        }
    }

    It 'loads URL, client ID, and client secret from Key Vault using managed identity' {
        Mock -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -MockWith {} -ParameterFilter {
            $Identity
        }

        Mock -CommandName 'Get-AzKeyVaultSecret' -ModuleName 'HaloAPI' -MockWith {
            switch ($Name) {
                'halo_URL' { [pscustomobject]@{ SecretValueText = 'https://vault.example/' } }
                'halo_ClientID' { [pscustomobject]@{ SecretValueText = 'vault-client' } }
                'halo_ClientSecret' { [pscustomobject]@{ SecretValueText = 'vault-secret' } }
            }
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"vaultTenant"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://placeholder.example/' -ClientID 'unused' -ClientSecret 'unused' -Scopes 'all' -UseKeyVault $true -VaultName 'vault' -SecretName 'halo' -Identity 'mi-1'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Identity
        }
        Should -Invoke -CommandName 'Get-AzKeyVaultSecret' -ModuleName 'HaloAPI' -Times 3 -Exactly -ParameterFilter {
            $VaultName -eq 'vault'
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'GET' -and $Uri -eq 'https://vault.example/api/authinfo'
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Body.client_id -eq 'vault-client' -and $Body.client_secret -eq 'vault-secret'
        }
    }

    It 'saves URL, client ID, and client secret to Key Vault before authenticating' {
        Mock -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -MockWith {} -ParameterFilter {
            $Identity
        }

        Mock -CommandName 'Set-AzKeyVaultSecret' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Name = $Name }
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-save' -ClientSecret 'secret-save' -Scopes 'all' -SaveToKeyVault $true -VaultName 'vault' -SecretName 'halo' -Identity 'mi-2'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Identity
        }
        Should -Invoke -CommandName 'Set-AzKeyVaultSecret' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $VaultName -eq 'vault' -and $Name -eq 'halo_URL'
        }
        Should -Invoke -CommandName 'Set-AzKeyVaultSecret' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $VaultName -eq 'vault' -and $Name -eq 'halo_ClientID'
        }
        Should -Invoke -CommandName 'Set-AzKeyVaultSecret' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $VaultName -eq 'vault' -and $Name -eq 'halo_ClientSecret'
        }
    }

    It 'loads secrets from Key Vault using interactive Azure login when no identity is provided' {
        Mock -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -MockWith {} -ParameterFilter {
            -not $Identity
        }

        Mock -CommandName 'Get-AzKeyVaultSecret' -ModuleName 'HaloAPI' -MockWith {
            switch ($Name) {
                'halo_URL' { [pscustomobject]@{ SecretValueText = 'https://interactive.example/' } }
                'halo_ClientID' { [pscustomobject]@{ SecretValueText = 'interactive-client' } }
                'halo_ClientSecret' { [pscustomobject]@{ SecretValueText = 'interactive-secret' } }
            }
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://placeholder.example/' -ClientID 'unused' -ClientSecret 'unused' -Scopes 'all' -UseKeyVault $true -VaultName 'vault' -SecretName 'halo'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            -not $Identity
        }
    }

    It 'saves secrets to Key Vault using interactive Azure login when no identity is provided' {
        Mock -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -MockWith {} -ParameterFilter {
            -not $Identity
        }

        Mock -CommandName 'Set-AzKeyVaultSecret' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Name = $Name }
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-save' -ClientSecret 'secret-save' -Scopes 'all' -SaveToKeyVault $true -VaultName 'vault' -SecretName 'halo'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Connect-AzAccount' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            -not $Identity
        }
    }

    It 'falls back to auth/token without tenant when authinfo response is empty and no tenant is provided' {
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

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-fallback' -ClientSecret 'secret-fallback' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://example.halo/auth/token'
        }
    }

    It 'rethrows non-throttling HttpResponseException from auth info lookup' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('bad request', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        {
            Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-authinfo' -ClientSecret 'secret-authinfo' -Scopes 'all'
        } | Should -Throw

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly -ParameterFilter {
            $HasResponse
        }
    }

    It 'routes unexpected auth info lookup errors through New-HaloError and then falls back to the default auth path' {
        $script:AuthInfoErrorCallCount = 0

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            $script:AuthInfoErrorCallCount += 1
            if ($script:AuthInfoErrorCallCount -eq 1) {
                throw [System.Exception]::new('auth info failed')
            }

            [pscustomobject]@{ content = $null }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-authinfo' -ClientSecret 'secret-authinfo' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $HasResponse
        }
    }

    It 'reports auth info retry exhaustion after repeated throttling before falling back to the default auth path' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('throttled', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-authinfo' -ClientSecret 'secret-authinfo' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -Times 10 -Exactly -ParameterFilter {
            $Seconds -eq 5
        }
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $ModuleMessage -eq 'Retried auth info request 10 times, request unsuccessful.'
        }
    }

    It 'rethrows non-throttling HttpResponseException from token request' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::BadRequest)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('bad request', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        {
            Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-token' -ClientSecret 'secret-token' -Scopes 'all'
        } | Should -Throw

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly -ParameterFilter {
            -not $HasResponse -and $ErrorRecord
        }
    }

    It 'routes unexpected token request errors through New-HaloError before succeeding on retry' {
        $script:TokenErrorCallCount = 0

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            $script:TokenErrorCallCount += 1
            if ($script:TokenErrorCallCount -eq 1) {
                throw [System.Exception]::new('token failed')
            }

            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-token' -ClientSecret 'secret-token' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            -not $HasResponse -and $ErrorRecord
        }
    }

    It 'reports auth retry exhaustion after repeated throttling and returns false' {
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('throttled', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            throw $HttpException
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-token' -ClientSecret 'secret-token' -Scopes 'all'

        $Result | Should -BeFalse
        Should -Invoke -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -Times 10 -Exactly -ParameterFilter {
            $Seconds -eq 5
        }
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $ModuleMessage -eq 'Retried auth request 10 times, request unsuccessful.'
        }
    }

    It 'retries the auth info request after a throttled response and does not report a failure after success' {
        $script:AuthInfoCallCount = 0
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('throttled', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            $script:AuthInfoCallCount += 1
            if ($script:AuthInfoCallCount -eq 1) {
                throw $HttpException
            }

            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-retry' -ClientSecret 'secret-retry' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Seconds -eq 5
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 2 -Exactly -ParameterFilter {
            $Method -eq 'GET'
        }
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly -ParameterFilter {
            $ModuleMessage -like 'Retried auth info request*'
        }
    }

    It 'retries the token request after a throttled response and does not report a failure after success' {
        $script:TokenCallCount = 0
        $Response = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
        $HttpException = [Microsoft.PowerShell.Commands.HttpResponseException]::new('throttled', $Response)

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            $script:TokenCallCount += 1
            if ($script:TokenCallCount -eq 1) {
                throw $HttpException
            }

            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-retry' -ClientSecret 'secret-retry' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'Start-Sleep' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Seconds -eq 5
        }
        Should -Invoke -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -Times 2 -Exactly -ParameterFilter {
            $Method -eq 'POST'
        }
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 0 -Exactly -ParameterFilter {
            $ModuleMessage -like 'Retried auth request*'
        }
    }

    It 'reports a lookup initialisation failure when lookup types cannot be retrieved' {
        Mock -CommandName 'Get-HaloLookup' -ModuleName 'HaloAPI' -MockWith { $null }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ content = '{"auth_url":"https://auth.example/oauth2","tenant_id":"tenantFromAuthInfo"}' }
        } -ParameterFilter {
            $Method -eq 'GET'
        }

        Mock -CommandName 'Invoke-WebRequest' -ModuleName 'HaloAPI' -MockWith {
            [pscustomobject]@{ Content = '{"token_type":"Bearer","access_token":"abc","expires_in":3600,"refresh_token":"ref","id_token":"id"}' }
        } -ParameterFilter {
            $Method -eq 'POST'
        }

        $Result = Connect-HaloAPI -URL 'https://example.halo/' -ClientID 'client-lookup' -ClientSecret 'secret-lookup' -Scopes 'all'

        $Result | Should -BeTrue
        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $ModuleMessage -eq 'Could not retrieve lookup types from Halo.'
        }
    }
}

Describe 'Get-TokenExpiry' {
    It 'returns a DateTime approximately ExpiresIn seconds in the future' {
        InModuleScope 'HaloAPI' {
            $Before = Get-Date
            $Expiry = Get-TokenExpiry -ExpiresIn 120
            $After = Get-Date

            ($Expiry -ge $Before.AddSeconds(119)) | Should -BeTrue
            ($Expiry -le $After.AddSeconds(121)) | Should -BeTrue
        }
    }
}

Describe 'Write-Success' {
    BeforeAll {
        Mock -CommandName 'Write-Information' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'writes an information message using green host styling' {
        InModuleScope 'HaloAPI' {
            Write-Success -Message 'Connected'
        }

        Should -Invoke -CommandName 'Write-Information' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $InformationAction -eq 'Continue' -and
            $MessageData.Message -eq 'Connected' -and
            $MessageData.ForegroundColor -eq 'Green'
        }
    }
}

Describe 'New-HaloError' {
    It 'throws the module message when ModuleMessage is provided' {
        InModuleScope 'HaloAPI' {
            { New-HaloError -ModuleMessage 'module failure' } | Should -Throw -ExpectedMessage 'module failure'
        }
    }

    It 'includes API and HTTP details when ErrorDetails JSON and response are present' {
        InModuleScope 'HaloAPI' {
            $Exception = [System.Exception]::new('request failed')
            $Response = [pscustomobject]@{
                StatusCode = [pscustomobject]@{ value__ = 400 }
                ReasonPhrase = 'Bad Request'
            }
            $Exception | Add-Member -NotePropertyName 'Response' -NotePropertyValue $Response -Force
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'BadRequest',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            $ErrorRecord.ErrorDetails = '{"resultCode":"BadInput","errorMessage":"Invalid payload"}'

            $Caught = $null
            try {
                New-HaloError -ErrorRecord $ErrorRecord -HasResponse
            } catch {
                $Caught = $_
            }

            $Caught | Should -Not -BeNullOrEmpty
            ([string]$Caught.ErrorDetails) | Should -Match 'BadInput'
            ([string]$Caught.ErrorDetails) | Should -Match 'Invalid payload'
            ([string]$Caught.ErrorDetails) | Should -Match '400 Bad Request'
        }
    }

    It 'uses exception message when ErrorDetails and ModuleMessage are not provided' {
        InModuleScope 'HaloAPI' {
            $Exception = [System.Exception]::new('plain failure')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'PlainFailure',
                [System.Management.Automation.ErrorCategory]::NotSpecified,
                $null
            )

            { New-HaloError -ErrorRecord $ErrorRecord } | Should -Throw -ExpectedMessage 'plain failure'
        }
    }

    It 'extracts ClassName and Message from JSON ErrorDetails' {
        InModuleScope 'HaloAPI' {
            $Exception = [System.Exception]::new('request failed')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'JsonFailure',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            $ErrorRecord.ErrorDetails = '{"ClassName":"ValidationException","Message":"Payload rejected"}'

            $Caught = $null
            try {
                New-HaloError -ErrorRecord $ErrorRecord
            } catch {
                $Caught = $_
            }

            $Caught | Should -Not -BeNullOrEmpty
            ([string]$Caught.ErrorDetails) | Should -Match 'ValidationException'
            ([string]$Caught.ErrorDetails) | Should -Match 'Payload rejected'
        }
    }

    It 'extracts error field from JSON ErrorDetails' {
        InModuleScope 'HaloAPI' {
            $Exception = [System.Exception]::new('request failed')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'JsonErrorField',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            $ErrorRecord.ErrorDetails = '{"error":"Ticket not found"}'

            $Caught = $null
            try {
                New-HaloError -ErrorRecord $ErrorRecord
            } catch {
                $Caught = $_
            }

            $Caught | Should -Not -BeNullOrEmpty
            ([string]$Caught.ErrorDetails) | Should -Match 'Ticket not found'
        }
    }

    It 'parses split API and HTTP detail lines from plain-text ErrorDetails' {
        InModuleScope 'HaloAPI' {
            $Exception = [System.Exception]::new('request failed')
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                'SplitDetails',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            $ErrorRecord.ErrorDetails = "The Halo API said ValidationError: Bad data.`r`nThe API returned the following HTTP error response: 400 Bad Request"

            $Caught = $null
            try {
                New-HaloError -ErrorRecord $ErrorRecord
            } catch {
                $Caught = $_
            }

            $Caught | Should -Not -BeNullOrEmpty
            ([string]$Caught.ErrorDetails) | Should -Match 'ValidationError'
            ([string]$Caught.ErrorDetails) | Should -Match '400 Bad Request'
        }
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

Describe 'Get cmdlet request wiring' {
    BeforeAll {
        InModuleScope 'HaloAPI' {
            $Script:HAPIConnectionInformation = [pscustomobject]@{
                URL = 'https://example.halo/'
                ClientID = 'client-id'
                ClientSecret = 'client-secret'
                AuthScopes = @('all')
                Tenant = 'tenant-id'
            }
            $Script:HAPIAuthToken = [pscustomobject]@{
                Type = 'Bearer'
                Access = 'token'
                Expires = [datetime]'2099-01-01T00:00:00Z'
            }
        }

        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -MockWith {
            @([pscustomobject]@{ id = 1; Content = [byte[]](1, 2, 3); Headers = @{}; RawContentLength = 3 })
        }
    }

    It 'routes Get-HaloAttachment multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloAttachment -TicketID 101 -ActionID 5
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/attachment' -and $ResourceType -eq 'attachments' -and $AutoPaginateOff -eq $true -and $QSCollection['ticket_id'] -eq 101
        }
    }

    It 'routes Get-HaloAttachment single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloAttachment -AttachmentID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/attachment/42' -and $ResourceType -eq 'attachments' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloInvoice multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloInvoice -Search 'invoice' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/invoice' -and $ResourceType -eq 'invoices' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'invoice'
        }
    }

    It 'routes Get-HaloInvoice single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloInvoice -InvoiceID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/invoice/42' -and $ResourceType -eq 'invoices' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloSite multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSite -Search 'hq' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/site' -and $ResourceType -eq 'sites' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'hq'
        }
    }

    It 'routes Get-HaloSite single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSite -SiteID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/site/42' -and $ResourceType -eq 'sites' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloAssetType multi mode' {
        $Result = InModuleScope 'HaloAPI' {
            Get-HaloAssetType -Search 'laptop' -Paginate -PageNo 1
        }
        $Result | Should -Not -BeNullOrEmpty
    }

    It 'routes Get-HaloAssetType single mode' {
        $Result = InModuleScope 'HaloAPI' {
            Get-HaloAssetType -AssetTypeID 42
        }
        $Result | Should -Not -BeNullOrEmpty
    }

    It 'routes Get-HaloRecurringInvoice multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloRecurringInvoice -Search 'renewal' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/RecurringInvoice' -and $ResourceType -eq 'invoices' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'renewal'
        }
    }

    It 'routes Get-HaloRecurringInvoice single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloRecurringInvoice -RecurringInvoiceID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/RecurringInvoice/42' -and $ResourceType -eq 'invoices' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloAssetGroup multi mode' {
        $Result = InModuleScope 'HaloAPI' {
            Get-HaloAssetGroup -Search 'group' -Paginate -PageNo 1
        }
        $Result | Should -Not -BeNullOrEmpty
    }

    It 'routes Get-HaloAssetGroup single mode' {
        $Result = InModuleScope 'HaloAPI' {
            Get-HaloAssetGroup -AssetGroupID 42
        }
        $Result | Should -Not -BeNullOrEmpty
    }

    It 'routes Get-HaloUser multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloUser -Search 'alex' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/users' -and $ResourceType -eq 'users' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'alex'
        }
    }

    It 'routes Get-HaloUser single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloUser -UserID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/users/42' -and $ResourceType -eq 'users' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloContract multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloContract -Search 'gold' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/clientcontract' -and $ResourceType -eq 'contracts' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'gold'
        }
    }

    It 'routes Get-HaloContract single mode' {
        $Result = InModuleScope 'HaloAPI' {
            Get-HaloContract -ContractID 42
        }
        $Result | Should -Not -BeNullOrEmpty
    }

    It 'routes Get-HaloAsset multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloAsset -Search 'device' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/asset' -and $ResourceType -eq 'assets' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'device'
        }
    }

    It 'routes Get-HaloAsset single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloAsset -AssetID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/asset/42' -and $ResourceType -eq 'assets' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloProject multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloProject -Search 'roadmap' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/projects' -and $ResourceType -eq 'tickets' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'roadmap'
        }
    }

    It 'routes Get-HaloProject single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloProject -ProjectID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/projects/42' -and $ResourceType -eq 'tickets' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloTemplate multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloTemplate -Search 'standard' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/template' -and $ResourceType -eq 'templates' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'standard'
        }
    }

    It 'routes Get-HaloTemplate single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloTemplate -TemplateID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/template/42' -and $ResourceType -eq 'templates' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloSupplier multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSupplier -Search 'vendor' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/supplier' -and $ResourceType -eq 'suppliers' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'vendor'
        }
    }

    It 'routes Get-HaloSupplier single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSupplier -SupplierID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/supplier/42' -and $ResourceType -eq 'suppliers' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloItem multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloItem -Search 'keyboard' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/item' -and $ResourceType -eq 'items' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'keyboard'
        }
    }

    It 'routes Get-HaloItem single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloItem -ItemID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/item/42' -and $ResourceType -eq 'items' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloCustomField multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloCustomField -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/FieldInfo' -and $ResourceType -eq 'FieldInfo' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloCustomField single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloCustomField -CustomFieldID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/FieldInfo/42' -and $ResourceType -eq 'FieldInfo' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloDistributionList multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloDistributionList -Search 'ops' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/distributionlist' -and $ResourceType -eq 'distributionlists' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'ops'
        }
    }

    It 'routes Get-HaloDistributionList single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloDistributionList -DistributionListID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/distributionlist/42' -and $ResourceType -eq 'distributionlists' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloTab multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloTab -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/Tabs' -and $ResourceType -eq 'Tabs' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloTab single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloTab -TableID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/Tabs/42' -and $ResourceType -eq 'Tabs' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloKBArticle multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloKBArticle -Search 'vpn' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/KBArticle' -and $ResourceType -eq 'articles' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'vpn'
        }
    }

    It 'routes Get-HaloKBArticle single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloKBArticle -KBArticleID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/KBArticle/42' -and $ResourceType -eq 'articles' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloSoftwareLicence multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSoftwareLicence -ClientID 7 -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/SoftwareLicence' -and $ResourceType -eq 'licences' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloSoftwareLicence single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloSoftwareLicence -LicenceID 42 -ClientID 7
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/SoftwareLicence/42' -and $ResourceType -eq 'licences' -and $AutoPaginateOff -eq $true
        }
    }

    It 'routes Get-HaloOpportunity multi mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloOpportunity -Search 'renewal' -Paginate -PageNo 1
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/opportunities' -and $ResourceType -eq 'tickets' -and $AutoPaginateOff -eq $true -and $QSCollection['search'] -eq 'renewal'
        }
    }

    It 'routes Get-HaloOpportunity single mode' {
        InModuleScope 'HaloAPI' {
            Get-HaloOpportunity -OpportunityID 42
        }
        Should -Invoke -CommandName 'New-HaloGETRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Resource -eq 'api/opportunities/42' -and $ResourceType -eq 'tickets' -and $AutoPaginateOff -eq $true
        }
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

Describe 'Set-HaloTicketRules' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTicketRules' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 9 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts updates to the TicketRules endpoint when the rule exists' {
        $Rule = [pscustomobject]@{ id = 9; name = 'Rule 9' }

        Set-HaloTicketRules -Rule $Rule -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Get-HaloTicketRules' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $RuleID -eq 9
        }
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'TicketRules' -and $Object.id -eq 9
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloTicketRules -Rule ([pscustomobject]@{ id = 10; name = 'Rule 10' }) -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Rule id through New-HaloError' {
        Set-HaloTicketRules -Rule ([pscustomobject]@{ name = 'NoId' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloTicketType' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTicketType' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 21 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to tickettype endpoint when all ticket types pass validation' {
        $TicketTypes = @(
            [pscustomobject]@{ id = 21; name = 'Incident' },
            [pscustomobject]@{ id = 22; name = 'Request' }
        )

        Set-HaloTicketType -TicketType $TicketTypes -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'tickettype' -and $Object.Count -eq 2
        }
    }

    It 'bypasses lookup when SkipValidation is used' {
        Set-HaloTicketType -TicketType @([pscustomobject]@{ id = 30; name = 'Skip' }) -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Get-HaloTicketType' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }

    It 'routes missing TicketType id through New-HaloError' {
        Set-HaloTicketType -TicketType @([pscustomobject]@{ name = 'NoId' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloUser' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloUser' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 101 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to users endpoint when user validation succeeds' {
        $Users = @([pscustomobject]@{ id = 101; name = 'Alex' })

        Set-HaloUser -User $Users -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Get-HaloUser' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $UserId -eq 101
        }
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'users' -and $Object[0].id -eq 101
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloUser -User @([pscustomobject]@{ id = 102; name = 'Jordan' }) -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing User id through New-HaloError' {
        Set-HaloUser -User @([pscustomobject]@{ name = 'NoId' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloViewColumn' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloViewColumn' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 301 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to viewcolumns endpoint when SkipValidation is used' {
        $ViewColumns = @([pscustomobject]@{ id = 301; ticket_id = 77; name = 'Priority' })

        Set-HaloViewColumn -ViewColumn $ViewColumns -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'viewcolumns' -and $Object[0].id -eq 301
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloViewColumn -ViewColumn @([pscustomobject]@{ id = 401; ticket_id = 88 }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'Get-HaloViewColumn' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing ViewColumn id through New-HaloError' {
        Set-HaloViewColumn -ViewColumn @([pscustomobject]@{ ticket_id = 99 }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloViewFilter' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloViewFilter' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 501 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to viewfilter endpoint when SkipValidation is used' {
        $ViewFilters = @([pscustomobject]@{ id = 501; ticket_id = 91; name = 'Filter A' })

        Set-HaloViewFilter -ViewFilter $ViewFilters -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'viewfilter' -and $Object[0].id -eq 501
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloViewFilter -ViewFilter @([pscustomobject]@{ id = 502; ticket_id = 92 }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'Get-HaloViewFilter' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing ViewFilter id through New-HaloError' {
        Set-HaloViewFilter -ViewFilter @([pscustomobject]@{ ticket_id = 93 }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloViewList' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloViewList' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 601 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to viewlists endpoint when SkipValidation is used' {
        $ViewLists = @([pscustomobject]@{ id = 601; ticket_id = 94; name = 'List A' })

        Set-HaloViewList -ViewList $ViewLists -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'viewlists' -and $Object[0].id -eq 601
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloViewList -ViewList @([pscustomobject]@{ id = 602; ticket_id = 95 }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'Get-HaloViewList' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing ViewList id through New-HaloError' {
        Set-HaloViewList -ViewList @([pscustomobject]@{ ticket_id = 96 }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloViewListGroup' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloViewListGroup' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 701 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to viewlistgroup endpoint when SkipValidation is used' {
        $ViewListGroups = @([pscustomobject]@{ id = 701; ticket_id = 97; name = 'Group A' })

        Set-HaloViewListGroup -ViewListGroup $ViewListGroups -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'viewlistgroup' -and $Object[0].id -eq 701
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloViewListGroup -ViewListGroup @([pscustomobject]@{ id = 702; ticket_id = 98 }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'Get-HaloViewListGroup' -ModuleName 'HaloAPI' -Times 0 -Exactly
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing ViewListGroup id through New-HaloError' {
        Set-HaloViewListGroup -ViewListGroup @([pscustomobject]@{ ticket_id = 99 }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloWorkday' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloWorkday' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 801 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts updates to workday endpoint when workday exists' {
        $Workday = [pscustomobject]@{ id = 801; name = 'Monday' }

        Set-HaloWorkday -Workday $Workday -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'Get-HaloWorkday' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $WorkdayID -eq 801
        }
        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'workday' -and $Object.id -eq 801
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloWorkday -Workday ([pscustomobject]@{ id = 802; name = 'Tuesday' }) -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Workday id through New-HaloError' {
        Set-HaloWorkday -Workday ([pscustomobject]@{ name = 'NoId' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloTicket' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTicket' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 5001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to tickets endpoint when SkipValidation is used' {
        $Tickets = @([pscustomobject]@{ id = 5001; summary = 'Update ticket' })

        Set-HaloTicket -Ticket $Tickets -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'tickets' -and $Object[0].id -eq 5001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloTicket -Ticket @([pscustomobject]@{ id = 5002; summary = 'Another ticket' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Ticket id through New-HaloError' {
        Set-HaloTicket -Ticket @([pscustomobject]@{ summary = 'No ID ticket' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloTemplate' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTemplate' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 6001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to template endpoint when SkipValidation is used' {
        $Templates = @([pscustomobject]@{ id = 6001; name = 'Template A' })

        Set-HaloTemplate -Template $Templates -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'template' -and $Object[0].id -eq 6001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloTemplate -Template @([pscustomobject]@{ id = 6002; name = 'Template B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Template id through New-HaloError' {
        Set-HaloTemplate -Template @([pscustomobject]@{ name = 'No ID template' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloTeam' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloTeam' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 7001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to team endpoint when SkipValidation is used' {
        $Teams = @([pscustomobject]@{ id = 7001; name = 'Team A' })

        Set-HaloTeam -Team $Teams -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'team' -and $Object[0].id -eq 7001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloTeam -Team @([pscustomobject]@{ id = 7002; name = 'Team B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Team id through New-HaloError' {
        Set-HaloTeam -Team @([pscustomobject]@{ name = 'No ID team' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloStatus' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloStatus' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 8001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to status endpoint when SkipValidation is used' {
        $Statuses = @([pscustomobject]@{ id = 8001; name = 'Open' })

        Set-HaloStatus -Status $Statuses -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'status' -and $Object[0].id -eq 8001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloStatus -Status @([pscustomobject]@{ id = 8002; name = 'Closed' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Status id through New-HaloError' {
        Set-HaloStatus -Status @([pscustomobject]@{ name = 'No ID status' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloSite' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloSite' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 9001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to site endpoint when SkipValidation is used' {
        $Sites = @([pscustomobject]@{ id = 9001; name = 'Site A' })

        Set-HaloSite -Site $Sites -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'site' -and $Object[0].id -eq 9001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloSite -Site @([pscustomobject]@{ id = 9002; name = 'Site B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Site id through New-HaloError' {
        Set-HaloSite -Site @([pscustomobject]@{ name = 'No ID site' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloSupplier' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloSupplier' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 10001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to supplier endpoint when SkipValidation is used' {
        $Suppliers = @([pscustomobject]@{ id = 10001; name = 'Supplier A' })

        Set-HaloSupplier -Supplier $Suppliers -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'supplier' -and $Object[0].id -eq 10001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloSupplier -Supplier @([pscustomobject]@{ id = 10002; name = 'Supplier B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Supplier id through New-HaloError' {
        Set-HaloSupplier -Supplier @([pscustomobject]@{ name = 'No ID supplier' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloReport' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloReport' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 11001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to report endpoint when SkipValidation is used' {
        $Reports = @([pscustomobject]@{ id = 11001; name = 'Report A' })

        Set-HaloReport -Report $Reports -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'report' -and $Object[0].id -eq 11001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloReport -Report @([pscustomobject]@{ id = 11002; name = 'Report B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Report id through New-HaloError' {
        Set-HaloReport -Report @([pscustomobject]@{ name = 'No ID report' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloProject' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloProject' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 12001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to projects endpoint when SkipValidation is used' {
        $Projects = @([pscustomobject]@{ id = 12001; name = 'Project A' })

        Set-HaloProject -Project $Projects -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'projects' -and $Object[0].id -eq 12001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloProject -Project @([pscustomobject]@{ id = 12002; name = 'Project B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Project id through New-HaloError' {
        Set-HaloProject -Project @([pscustomobject]@{ name = 'No ID project' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloAction' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloAction' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 13001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to actions endpoint when SkipValidation is used' {
        $Actions = @([pscustomobject]@{ id = 13001; ticket_id = 7001; name = 'Action A' })

        Set-HaloAction -Action $Actions -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'actions' -and $Object[0].id -eq 13001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloAction -Action @([pscustomobject]@{ id = 13002; ticket_id = 7002; name = 'Action B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Action id through New-HaloError' {
        Set-HaloAction -Action @([pscustomobject]@{ ticket_id = 7003; name = 'No ID action' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloAsset' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloAsset' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 14001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to asset endpoint when SkipValidation is used' {
        $Assets = @([pscustomobject]@{ id = 14001; name = 'Asset A' })

        Set-HaloAsset -Asset $Assets -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'asset' -and $Object[0].id -eq 14001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloAsset -Asset @([pscustomobject]@{ id = 14002; name = 'Asset B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Asset id through New-HaloError' {
        Set-HaloAsset -Asset @([pscustomobject]@{ name = 'No ID asset' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloClient' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloClient' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 15001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to client endpoint when SkipValidation is used' {
        $Clients = @([pscustomobject]@{ id = 15001; name = 'Client A' })

        Set-HaloClient -Client $Clients -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'client' -and $Object[0].id -eq 15001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloClient -Client @([pscustomobject]@{ id = 15002; name = 'Client B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Client id through New-HaloError' {
        Set-HaloClient -Client @([pscustomobject]@{ name = 'No ID client' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
    }
}

Describe 'Set-HaloContract' {
    BeforeAll {
        Mock -CommandName 'Invoke-HaloPreFlightCheck' -ModuleName 'HaloAPI' -MockWith {}
        Mock -CommandName 'Get-HaloContract' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ id = 16001 } }
        Mock -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -MockWith { [pscustomobject]@{ updated = $true } }
        Mock -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -MockWith {}
    }

    It 'posts to clientcontract endpoint when SkipValidation is used' {
        $Contracts = @([pscustomobject]@{ id = 16001; name = 'Contract A' })

        Set-HaloContract -Contract $Contracts -SkipValidation -Confirm:$false | Out-Null

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'clientcontract' -and $Object[0].id -eq 16001
        }
    }

    It 'does not post updates when -WhatIf is specified' {
        Set-HaloContract -Contract @([pscustomobject]@{ id = 16002; name = 'Contract B' }) -SkipValidation -WhatIf

        Should -Invoke -CommandName 'New-HaloPOSTRequest' -ModuleName 'HaloAPI' -Times 0 -Exactly
    }

    It 'routes missing Contract id through New-HaloError' {
        Set-HaloContract -Contract @([pscustomobject]@{ name = 'No ID contract' }) -Confirm:$false

        Should -Invoke -CommandName 'New-HaloError' -ModuleName 'HaloAPI' -Times 1 -Exactly
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

#Requires -Version 7
function Get-HaloReport {
    <#
        .SYNOPSIS
            Gets reports from the Halo API.
        .DESCRIPTION
            Retrieves reports from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Report ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ReportID,
        # Number of records to return
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Filters response based on the search string
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # The name of the first field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc,
        # The name of the second field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy2,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc2,
        # The name of the third field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy3,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc3,
        # The name of the fourth field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy4,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc4,
        # The name of the fifth field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$OrderBy5,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderByDesc5,
        # Filters by the specified ticket
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticket_id')]
        [int64]$TicketID,
        # Filters by the specified client
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int64]$ClientID,
        # Filters by the specified site
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('site_id')]
        [int64]$SiteID,
        # Filters by the specified user
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int64]$UserID,
        # Filters by the specified report group
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('reportgroup_id')]
        [int64]$ReportGroupID,
        # Whether to return only records for reports that include graphs
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ChartOnly,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        # Whether to include the report data in the response
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$LoadReport
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'reportid=' parameter by removing it from the set parameters.
    if ($ReportID) {
        $Parameters.Remove('ReportID') | Out-Null
    }
    try {
        if ($ReportID) {
            Write-Verbose "Running in single-report mode because '-ReportID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/Report/$($ReportID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'reports'
            }
        } else {
            Write-Verbose 'Running in multi-report mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/Report'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'reports'
            }
        }
        $ReportResults = New-HaloGETRequest @RequestParams
        Return $ReportResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
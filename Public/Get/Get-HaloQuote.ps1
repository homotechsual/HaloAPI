#Requires -Version 7
function Get-HaloQuote {
    <#
        .SYNOPSIS
            Gets quotes from the Halo API.
        .DESCRIPTION
            Retrieves quotes from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Quote ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$QuoteID,
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
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'QuoteID=' parameter by removing it from the set parameters.
    if ($QuoteID) {
        $Parameters.Remove('QuoteID') | Out-Null
    }
    try {
        if ($QuoteID) {
            Write-Verbose "Running in single-quote mode because '-QuoteID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/quotation/$($QuoteID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'quotes'
            }
        } else {
            Write-Verbose 'Running in multi-quote mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/quotation'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'quotes'
            }
        }
        $QuoteResults = New-HaloGETRequest @RequestParams
        Return $QuoteResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
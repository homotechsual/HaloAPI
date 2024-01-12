#Requires -Version 7
function Get-HaloSalesOrder {
    <#
        .SYNOPSIS
            Gets sales orders from the Halo API.
        .DESCRIPTION
            Retrieves sales orders from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Sales Order ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$SalesOrderID,
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
        # Include open sales orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Open,
        # Include closed sales orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Closed,
        # Include sales orders which require ordering in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$NeedsOrdering,
        # Include active sales orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeActive,
        # Include inactive sales orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeInactive,
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Filters by the specified client
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int64]$ClientID,
        # Filters by the specified site
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('site_id')]
        [int64]$SiteID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        # Include billing details in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeBillingInfo
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'SalesOrderID=' parameter by removing it from the set parameters.
    if ($SalesOrderID) {
        $Parameters.Remove('SalesOrderID') | Out-Null
    }
    try {
        if ($SalesOrderID) {
            Write-Verbose "Running in single-sales order mode because '-SalesOrderID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/salesorder/$($SalesOrderID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'salesorders'
            }
        } else {
            Write-Verbose 'Running in multi-sales order mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/salesorder'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'salesorders'
            }
        }
        $SalesOrderResults = New-HaloGETRequest @RequestParams
        Return $SalesOrderResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
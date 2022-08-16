#Requires -Version 7
function Get-HaloPurchaseOrder {
    <#
        .SYNOPSIS
            Gets purchase orders from the Halo API.
        .DESCRIPTION
            Retrieves purchase orders from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Purchase Order ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$PurchaseOrderID,
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
        # Include open purchase orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Open,
        # Include closed purchase orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Closed,
        # Include active purchase orders in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeActive,
        # Include inactive purchase orders in the results.
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
    # Workaround to prevent the query string processor from adding a PurchaseOrderID=' parameter by removing it from the set parameters.
    if ($PurchaseOrderID) {
        $Parameters.Remove('PurchaseOrderID') | Out-Null
    }
    try {
        if ($PurchaseOrderID) {
            Write-Verbose "Running in single-purchase order mode because '-PurchaseOrderID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/purchaseorder/$($PurchaseOrderID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'purchaseorders'
            }
        } else {
            Write-Verbose 'Running in multi-purchase order mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/purchaseorder'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'purchaseorders'
            }
        }
        $PurchaseOrderResults = New-HaloGETRequest @RequestParams
        Return $PurchaseOrderResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
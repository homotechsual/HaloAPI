#Requires -Version 7
function Get-HaloAsset {
    <#
        .SYNOPSIS
            Gets assets from the Halo API.
        .DESCRIPTION
            Retrieves assets from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Asset ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$AssetID,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize = $Script:HAPIDefaultPageSize,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # Filter by Assets with an asset field like your search
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Filter by Assets belonging to a particular ticket
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticket_id')]
        [int64]$TicketID,
        # Filter by Assets belonging to a particular client
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int64]$ClientID,
        # Filter by Assets belonging to a particular site
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('')]
        [int64]$SiteID,
        # Filter by Assets belonging to a particular user
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Username,
        # Filter by Assets belonging to a particular Asset group
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('assetgroup_id')]
        [int64]$AssetGroupID,
        # Filter by Assets belonging to a particular Asset type
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('assettype_id')]
        [int64]$AssetTypeID,
        # Filter by Assets linked to a particular Asset
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('linkedto_id')]
        [int64]$LinkedToID,
        # Include inactive Assets in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [Switch]$includeinactive,
        # Include active Assets in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [Switch]$includeactive,
        # Include child Assets in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [Switch]$includechildren,
        # Filter by Assets linked to a particular Asset
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('contract_id')]
        [int64]$ContractID,
        # Parameter to return the complete objects.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$FullObjects,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include the last action in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDiagramDetails,
        # Advanced search query
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('advanced_search')]
        [string]$AdvancedSearch,
        # Asset groups to filter by
        [Parameter( ParameterSetName = 'Multi' )]
        [int[]]$AssetGroups,
        # Asset statuses to filter by
        [Parameter( ParameterSetName = 'Multi' )]
        [string[]]$AssetStatuses,
        # Asset types to filter by
        [Parameter( ParameterSetName = 'Multi' )]
        [int[]]$AssetTypes,
        # Filter by bookmarked assets
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Bookmarked,
        # Use the provided column profile
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('columns_id')]
        [int]$ColumnsID,
        # Filter by consignable assets
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Consignable,
        # Include the billing period of the linked contract id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('contract_id_adding_to')]
        [switch]$IncludeBillingPeriod,
        # Return this number of assets.
        [Parameter( ParameterSetName = 'Multi' )]
        [int]$Count,
        # Filter by assets with a linked Domotz agent
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$DomotzAgents,
        # Exclude assets by id
        [Parameter( ParameterSetName = 'Multi' )]
        [int[]]$ExcludeThese,
        # Return only the asset id
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IDOnly,
        # Include the asset column `tallowallstatus` in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeallowedstatus,
        # Include the asset fields in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeassetfields,
        # Include column details in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includecolumns,
        # Include assets linked service ids in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeservices,
        # Include the user details in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$includeuser,
        # Filter by integration tenant ids
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('integration_tenantids')]
        [int[]]$IntegrationTenantIDs,
        # Filter by inventory number
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('inventory_number')]
        [string]$InventoryNumber,
        # Filter by linked item id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('item_id')]
        [int]$ItemId,
        # Filter by linked item stock id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('itemstock_id')]
        [int]$ItemStockId,
        # Filter by linked kb article id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('kb_id')]
        [int]$KBId,
        # Include the last update from date in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$lastupdatefromdate,
        # Include the last update to date in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$lastupdatetodate,
        # Filter by assets assigned to a particular license
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('license_id')]
        [int]$LicenseID,
        # Filter to assets owned by the current user
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$Mine,
        # Filter to assets in the current user's site
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$MySite,
        # Exclude the asset icon from the response
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$NoIcon,
        # First field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results for the first field in descending order (respects the field choice in '-OrderBy')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Second field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order2,
        # Order results for the second field in descending order (respects the field choice in '-OrderBy2')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc2,
        # Third field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order3,
        # Order results for the third field in descending order (respects the field choice in '-OrderBy3')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc3,
        # Fourth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order4,
        # Order results for the fourth field in descending order (respects the field choice in '-OrderBy4')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc4,
        # Fifth field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order5,
        # Order results for the fifth field in descending order (respects the field choice in '-OrderBy5')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc5,
        # Filter by assets belonging to a particular service
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('service_id')]
        [int]$ServiceId,
        # Filter by assets belonging to any of the specified services
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('service_ids')]
        [int[]]$ServiceIds,
        # Filter by stockbin id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('stockbin_id')]
        [int]$StockBinId,
        # Filter by stockbin ids
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('stockbin_ids')]
        [int[]]$StockBinIds,
        # Filter by supplier contract id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('supplier_contract_id')]
        [int]$SupplierContractId,
        # Filter by supplier id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('supplier_id')]
        [int]$SupplierId,
        # Filter by supplier contract ids
        [Parameter( ParameterSetName = 'Multi' )]
        [int[]]$SupplierContracts,
        # Filter by assets with linked tickets of the given type
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('tickettype_id')]
        [int]$TicketTypeId,
        # Filter by assets belonging to the given user id
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('user_id')]
        [int]$UserId
    )   
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'assetid=' parameter by removing it from the set parameters.
    if ($AssetID) {
        $Parameters.Remove('AssetID') | Out-Null
    }
    # Similarly we don't want a `fullobjects=` parameter
    if ($FullObjects) {
        $Parameters.Remove('FullObjects') | Out-Null
    }
    try {
        if ($AssetID) {
            Write-Verbose "Running in single-asset mode because '-AssetID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/asset/$($AssetID)"
            $RequestParams = @{
                Method          = 'GET'
                Resource        = $Resource
                AutoPaginateOff = $True
                QSCollection    = $QSCollection
                ResourceType    = 'assets'
            }
        } else {
            Write-Verbose 'Running in multi-asset mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/asset'
            $RequestParams = @{
                Method          = 'GET'
                Resource        = $Resource
                AutoPaginateOff = $Paginate
                QSCollection    = $QSCollection
                ResourceType    = 'assets'
            }
        }    
        $AssetResults = New-HaloGETRequest @RequestParams

        if ($FullObjects) {
            $AllAssetResults = $AssetResults | ForEach-Object {             
                Get-HaloAsset -AssetID $_.id
            }
            $AssetResults = $AllAssetResults
        }

        Return $AssetResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
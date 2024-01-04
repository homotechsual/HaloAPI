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
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
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
        [Alias('site_id')]
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
        [Switch]$IncludeDiagramDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
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
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'assets'
            }
        } else {
            Write-Verbose 'Running in multi-asset mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/asset'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'assets'
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
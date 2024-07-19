#Requires -Version 7
function Get-HaloItem {
    <#
        .SYNOPSIS
            Gets items from the Halo API.
        .DESCRIPTION
            Retrieves items from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ItemID,
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
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'itemid=' parameter by removing it from the set parameters.
    if ($ItemID) {
        $Parameters.Remove('ItemID') | Out-Null
    }
    try {
        if ($ItemID) {
            Write-Verbose "Running in single-item mode because '-ItemID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/item/$($ItemID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'items'
            }
        } else {
            Write-Verbose 'Running in multi-item mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/item'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'items'
            }
        }
        $ItemResults = New-HaloGETRequest @RequestParams
        Return $ItemResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
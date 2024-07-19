#Requires -Version 7
function Get-HaloClient {
    <#
        .SYNOPSIS
            Gets clients from the Halo API.
        .DESCRIPTION
            Retrieves clients from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Client ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ClientID,
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
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return clients matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Filter by the specified top level ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('toplevel_id')]
        [int32]$TopLevelID,
        # Include active clients in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeActive,
        # Include inactive clients in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeInactive,
        # The number of clients to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Parameter to return the complete objects.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$FullObjects,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include ticket activity in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeActivity,
        # Include prepay objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludePrepay
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'clientid=' parameter by removing it from the set parameters.
    if ($ClientID) {
        $Parameters.Remove('ClientID') | Out-Null
    }
    # Similarly we don't want a `fullobjects=` parameter
    if ($FullObjects) {
        $Parameters.Remove('FullObjects') | Out-Null
    }
    try {
        if ($ClientID) {
            Write-Verbose "Running in single-client mode because '-ClientID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/client/$($ClientID)"
            $RequestParams = @{
                Method          = 'GET'
                Resource        = $Resource
                AutoPaginateOff = $True
                QSCollection    = $QSCollection
                ResourceType    = 'clients'
            }
        } else {
            Write-Verbose 'Running in multi-client mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/client'
            $RequestParams = @{
                Method          = 'GET'
                Resource        = $Resource
                AutoPaginateOff = $Paginate
                QSCollection    = $QSCollection
                ResourceType    = 'clients'
            }
        }
        $ClientResults = New-HaloGETRequest @RequestParams
        if ($FullObjects) {
            $AllClientResults = $ClientResults | ForEach-Object {
                Get-HaloClient -ClientID $_.id
            }
            $ClientResults = $AllClientResults
        }
        Return $ClientResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
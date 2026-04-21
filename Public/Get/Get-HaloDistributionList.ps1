#Requires -Version 7
function Get-HaloDistributionList {
    <#
        .SYNOPSIS
            Gets distribution lists from the Halo API.
        .DESCRIPTION
            Retrieves distribution lists from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    param(
        # Distribution List ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$DistributionListID,
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
        # The field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return distribution lists matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # The number of distribution lists to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'distributionlistid=' parameter by removing it from the set parameters.
    if ($DistributionListID) {
        $Parameters.Remove('DistributionListID') | Out-Null
    }
    try {
        if ($DistributionListID) {
            Write-Verbose "Running in single-distribution list mode because '-DistributionListID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/distributionlist/$($DistributionListID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'distributionlists'
            }
        } else {
            Write-Verbose 'Running in multi-distribution list mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/distributionlist'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'distributionlists'
            }
        }
        $DistributionListResults = New-HaloGETRequest @RequestParams
        return $DistributionListResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
#Requires -Version 7
function Get-HaloDistributionList {
    <#
        .SYNOPSIS
            Gets distribution lists from the Halo API.
        .DESCRIPTION
            Retrieves distribution lists from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    param(
        # Distribution List ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$DistributionListID,
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
        # The field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return distribution lists matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # The number of distribution lists to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'distributionlistid=' parameter by removing it from the set parameters.
    if ($DistributionListID) {
        $Parameters.Remove('DistributionListID') | Out-Null
    }
    try {
        if ($DistributionListID) {
            Write-Verbose "Running in single-distribution list mode because '-DistributionListID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/distributionlist/$($DistributionListID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'distributionlists'
            }
        } else {
            Write-Verbose 'Running in multi-distribution list mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/distributionlist'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'distributionlists'
            }
        }
        $DistributionListResults = New-HaloGETRequest @RequestParams
        return $DistributionListResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

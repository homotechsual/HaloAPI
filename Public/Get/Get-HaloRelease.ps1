#Requires -Version 7
function Get-HaloRelease {
    <#
        .SYNOPSIS
            Gets software releases from the Halo API.
        .DESCRIPTION
            Retrieves software releases from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Software Release ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ReleaseID,
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
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Include release note count in the result.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeNoteCount,
        # Filter by specified product ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('product_id')]
        [int32]$ProductID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a ReleaseID=' parameter by removing it from the set parameters.
    if ($ReleaseID) {
        $Parameters.Remove('ReleaseID') | Out-Null
    }
    try {
        if ($ReleaseID) {
            Write-Verbose "Running in single-software release mode because '-ReleaseID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/release/$($ReleaseID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'releases'
            }
        } else {
            Write-Verbose 'Running in multi-software release mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/release'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'releases'
            }
        }
        $ReleaseResults = New-HaloGETRequest @RequestParams
        Return $ReleaseResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
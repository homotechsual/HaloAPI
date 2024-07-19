#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloViewFilter {
    <#
        .SYNOPSIS
            Gets view filter profiles from the Halo API.
        .DESCRIPTION
            Retrieves view filter from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # View Filter Id.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ViewFilterId,
        # Return global view filters only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$GlobalOnly,
        # Show all view filters.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Show all view filters for a specific team.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTeam,
        # Show all view filters for a specific tech.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTech,
        # Show all view filters for a specific ticket area.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticketarea_id')]
        [int64]$TicketAreaId,
        # Filter by the following view filter type.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet('reqs', 'contracts', 'opps', 'suppliercontracts' )]
        [string]$Type,
        # Include detailed information about the view filter.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'viewfilterid=' parameter by removing it from the set parameters.
    if ($ViewFilterId) {
        $Parameters.Remove('ViewFilterId') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ViewFilterId) {
            Write-Verbose "Running in single-viewfilter mode because '-ViewFilterId' was provided."
            $Resource = "api/viewfilter/$($ViewFilterId)"
        } else {
            Write-Verbose 'Running in multi-viewfilter mode.'
            $Resource = 'api/viewfilter'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'viewfilter'
        }
        $ActionResults = New-HaloGETRequest @RequestParams
        Return $ActionResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
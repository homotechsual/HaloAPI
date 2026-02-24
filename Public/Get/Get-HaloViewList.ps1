#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloViewList {
    <#
        .SYNOPSIS
            Gets view list profiles from the Halo API.
        .DESCRIPTION
            Retrieves view list from the Halo API - supports a variety of listing parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # View List Id.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ViewListId,
        # Filter by connected instance id.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('connectedinstance_id')]
        [int64]$ConnectedInstanceID,
        # Filter by domain.
        [Parameter( ParameterSetName = 'Multi' )]
        [Parameter( ParameterSetName = 'Single' )]
        [string]$Domain,
        # Return global view lists only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$GlobalOnly,
        # Return only tree view lists.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IsTree,
        # Show all view lists.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Show all view lists for a specific team.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTeam,
        # Show all view lists for a specific tech.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTech,
        # Show the counts for the view lists.
        [Parameter( ParameterSetName = 'Multi' )]
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$ShowCounts,
        # Show all view lists for a specific ticket area.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticketarea_id')]
        [int64]$TicketAreaId,
        # Filter by the following view list type.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet('reqs', 'contracts', 'opps', 'suppliercontracts' )]
        [string]$Type,
        # Include detailed information about the view list.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'viewlistid=' parameter by removing it from the set parameters.
    if ($ViewListId) {
        $Parameters.Remove('ViewListId') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters    
    try {
        if ($ViewListId) {
            Write-Verbose "Running in single-viewlist mode because '-ViewListId' was provided."
            $Resource = "api/viewlists/$($ViewListId)"
        } else {
            Write-Verbose 'Running in multi-viewlist mode.'
            $Resource = 'api/viewlists'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'viewlists'
        }
        $ActionResults = New-HaloGETRequest @RequestParams
        Return $ActionResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
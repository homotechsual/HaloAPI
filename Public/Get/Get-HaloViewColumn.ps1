#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloViewColumn {
    <#
        .SYNOPSIS
            Gets view column profiles from the Halo API.
        .DESCRIPTION
            Retrieves view columns from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # View Column Id.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ViewColumnId,
        # Return global view columns only.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$GlobalOnly,
        # Show all view columns.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Show all view columns for a specific team.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTeam,
        # Show all view columns for a specific tech.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$ShowAllForTech,
        # Show all view columns for a specific ticket area.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('ticketarea_id')]
        [int64]$TicketAreaId,
        # Filter by the following view column type.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet('reqs', 'contracts', 'opps', 'suppliercontracts' )]
        [string]$Type,
        # Include detailed information about the view column.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'viewcolumnid=' parameter by removing it from the set parameters.
    if ($ViewColumnId) {
        $Parameters.Remove('ViewColumnId') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ViewColumnId) {
            Write-Verbose "Running in single-viewcolumn mode because '-ViewColumnId' was provided."
            $Resource = "api/viewcolumns/$($ViewColumnId)"
        } else {
            Write-Verbose 'Running in multi-viewcolumn mode.'
            $Resource = 'api/viewcolumns'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'viewcolumns'
        }
        $ActionResults = New-HaloGETRequest @RequestParams
        Return $ActionResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
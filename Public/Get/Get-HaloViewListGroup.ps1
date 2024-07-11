#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloViewListGroup {
    <#
        .SYNOPSIS
            Gets view list group profiles from the Halo API.
        .DESCRIPTION
            Retrieves view list group from the Halo API - supports a variety of list grouping parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # View List Group Id.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ViewListGroupId,
        # Filter by the following view list group type.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet('reqs', 'contracts', 'opps', 'suppliercontracts' )]
        [string]$Type,
        # Include detailed information about the view list group.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'viewlistgroupid=' parameter by removing it from the set parameters.
    if ($ViewListGroupId) {
        $Parameters.Remove('ViewListGroupId') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ViewListGroupId) {
            Write-Verbose "Running in single-viewlistgroup mode because '-ViewListGroupId' was provided."
            $Resource = "api/viewlistgroup/$($ViewListGroupId)"
        } else {
            Write-Verbose 'Running in multi-viewlistgroup mode.'
            $Resource = 'api/viewlistgroup'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'viewlistgroup'
        }
        $ActionResults = New-HaloGETRequest @RequestParams
        Return $ActionResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
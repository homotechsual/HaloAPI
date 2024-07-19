#Requires -Version 7
function Get-HaloCategory {
    <#
        .SYNOPSIS
            Gets Category information from the Halo API.
        .DESCRIPTION
            Retrieves Category types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Category ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$CategoryID,
        # Type ID
        [Parameter( ParameterSetName = 'Multi')]
        [Alias('type_id')]
        [string]$TypeID,
        # Include Details
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'CategoryID=' parameter by removing it from the set parameters.
    if ($CategoryID) {
        $Parameters.Remove('CategoryID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($CategoryID) {
            Write-Verbose "Running in single-field mode because '-CategoryID' was provided."
            $Resource = "api/Category/$($CategoryID)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/Category'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'categories'
        }
        $CategoryResults = New-HaloGETRequest @RequestParams
        Return $CategoryResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
#Requires -Version 7
function Get-HaloWorkday {
    <#
        .SYNOPSIS
            Gets workday information from the Halo API.
        .DESCRIPTION
            Retrieves workdays from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Workday Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$WorkdayID,
        # Show All
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'WorkdayID=' parameter by removing it from the set parameters.
    if ($WorkdayID) {
        $Parameters.Remove('WorkdayID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($WorkdayID) {
            Write-Verbose "Running in single-field mode because '-WorkdayID' was provided."
            $Resource = "api/Workday/$($WorkdayID)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/Workday'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'workdays'
        }
        $WorkdayResults = New-HaloGETRequest @RequestParams
        Return $WorkdayResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
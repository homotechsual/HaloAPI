#Requires -Version 7
function Get-HaloDashboard {
    <#
        .SYNOPSIS
            Gets dashboards from the Halo API.
        .DESCRIPTION
            Retrieves dashboards from the Halo API.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Dashboard ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$DashboardID
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters

    # Workaround to prevent the query string processor from adding a 'dashboardid=' parameter by removing it from the set parameters.
    if ($DashboardID) {
        $Parameters.Remove('DashboardID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($DashboardID) {
            Write-Verbose "Running in single-dashboard mode because '-DashboardID' was provided."
            $Resource = "api/DashboardLinks/$($DashboardID)"
        } else {
            Write-Verbose 'Running in multi-dashboard mode.'
            $Resource = 'api/DashboardLinks'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'dashboards'
        }
        $DashboardResults = New-HaloGETRequest @RequestParams
        Return $DashboardResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

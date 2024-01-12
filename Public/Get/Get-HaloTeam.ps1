#Requires -Version 7
function Get-HaloTeam {
    <#
        .SYNOPSIS
            Gets teams from the Halo API.
        .DESCRIPTION
            Retrieves teams from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Team ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$TeamID,
        # Filter teams to a specific type: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet(
            'reqs',
            'opps',
            'prjs'
        )]
        [string]$Type,
        # Teams to return agents for in the results. Comma separated string.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$IncludeAgentsForTeams,
        # Only include teams the current agent is a member of.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$MemberOnly,
        # Show the count of team tickets in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowCounts,
        # Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = 'Multi' )]
        [ValidateSet(
            'reqs',
            'opps',
            'prjs'
        )]
        [string]$Domain,
        # Filter counts to a specific view ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('view_id')]
        [int32]$ViewID,
        # Include enabled teams (defaults to $True).
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeEnabled,
        # Include disabled teams.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeDisabled,
        # Filter by the specified department ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('department_id')]
        [int32]$DepartmentID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'teamid=' parameter by removing it from the set parameters.
    if ($TeamID) {
        $Parameters.Remove('TeamID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($TeamID) {
            Write-Verbose "Running in single-team mode because '-TeamID' was provided."
            $Resource = "api/team/$($TeamID)"
        } else {
            Write-Verbose 'Running in multi-team mode.'
            $Resource = 'api/team'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'teams'
        }
        $TeamResults = New-HaloGETRequest @RequestParams
        Return $TeamResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
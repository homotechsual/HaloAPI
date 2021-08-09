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
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Team ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$TeamID,
        # Filter teams to a specific type: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = "Multi" )]
        [ValidateSet(
            "reqs",
            "opps",
            "prjs"
        )]
        [string]$Type,
        # Teams to return agents for in the results. Comma separated string.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$IncludeAgentsForTeams,
        # Only include teams the current agent is a member of.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$MemberOnly,
        # Show the count of team tickets in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowCounts,
        # Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.
        [Parameter( ParameterSetName = "Multi" )]
        [ValidateSet(
            "reqs",
            "opps",
            "prjs"
        )]
        [string]$Domain,
        # Filter counts to a specific view ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("view_id")]
        [int32]$ViewID,
        # Include enabled teams (defaults to $True).
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeEnabled,
        # Include disabled teams.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeDisabled,
        # Filter by the specified department ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("department_id")]
        [int32]$DepartmentID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'teamid=' parameter by removing it from the set parameters.
    if ($TeamID) {
        $Parameters.Remove("TeamID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($TeamID) {
            Write-Verbose "Running in single-team mode because '-TeamID' was provided."
            $Resource = "api/team/$($TeamID)$($QueryString)"
        } else {
            Write-Verbose "Running in multi-team mode."
            $Resource = "api/team$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $TeamResults = Invoke-HaloRequest @RequestParams
        Return $TeamResults
    } catch {
        Write-Error "Failed to get teams from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
#Requires -Version 7
function Get-HaloContract {
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
        # Filter counts to a specific domain: reqs = tickets, opps = opportunities and prjs = projects.
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
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'contractid=' parameter by removing it from the set parameters.
    if ($ContractID) {
        $Parameters.Remove("ContractID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ContractID) {
            Write-Verbose "Running in single-contract mode because '-ContractID' was provided."
            $Resource = "api/clientcontract/$ContractID$QueryString"
        } else {
            Write-Verbose "Running in multi-contract mode."
            $Resource = "api/clientcontract$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $ContractResults = Invoke-HaloRequest @RequestParams
        Return $ContractResults
    } catch {
        Write-Error "Failed to get contracts from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
#Requires -Version 7
function Get-HaloAgent {
    <#
        .SYNOPSIS
            Gets agents from the Halo API.
        .DESCRIPTION
            Retrieves agents from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Get the agent object for the access token owner
        [Parameter( ParameterSetName = "Me", Mandatory = $True )]
        [switch]$Me,
        # Agent ID.
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$AgentID,
        # Filter by the specified team name.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Team,
        # Filter by name, email address or telephone number using the specified search string.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Search,
        # Filter by the specified team ID. ?ACT Query with Halo what this does!
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("section_id")]
        [int32]$SectionID,
        # Filter by the specified department ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("department_id")]
        [int32]$DepartmentID,
        # Filter by the specified client ID (agents who have access to this client).
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("client_id")]
        [int]$ClientID,
        # Filter by the specified role ID (requires int as string.)
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Role,
        # Include agents with enabled accounts (defaults to $True).
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeEnabled,
        # Include agents with disabled accounts.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeDisabled,
        # Include the system unassigned agent account.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeUnassigned,
        # Include the agent's roles list in the response.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeRoles,
        # Include extra detail objects (for example teams and roles) in the response.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$IncludeDetail
        
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    if ($ActionID) {
        $Parameters.Remove("ActionID") | Out-Null
    }
    if ($Me) {
        $Parameters.Remove("Me") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ActionID) {
            Write-Verbose "Running in single-agent mode because '-ActionID' was provided."
            $Resource = "api/agent/$ActionID$QueryString"
        } elseif ($Me) {
            Write-Verbose "Running in 'Me' mode."
            $Resource = "api/agent/me"
        } else {I 
            Write-Verbose "Running in multi-agent mode."
            $Resource = "api/agent$($QueryString)"
        }
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $ActionResults = Invoke-HaloRequest @RequestParams
        Return $ActionResults
    } catch {
        Write-Error "Failed to get actions from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
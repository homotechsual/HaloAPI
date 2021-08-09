#Requires -Version 7
function Get-HaloStatus {
    <#
        .SYNOPSIS
            Gets statuses from the Halo API.
        .DESCRIPTION
            Retrieves statuses types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Status ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$StatusID,
        # Filter by Status type e.g. 'ticket' returns all ticket statuses
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Type,
        # Show the count of tickets in the results.
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
        # Exclude the pending closure status from the response
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ExcludePending,
        # Exclude the closed status from the response
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ExcludeClosed,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'StatusID=' parameter by removing it from the set parameters.
    if ($StatusID) {
        $Parameters.Remove("StatusID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($StatusID) {
            Write-Verbose "Running in single-status mode because '-StatusID' was provided."
            $Resource = "api/Status/$($StatusID)$($QueryString)"
        }
        else {
            Write-Verbose "Running in multi-status mode."
            $Resource = "api/Status$($QueryString)"
        }    
        $RequestParams = @{
            Method   = "GET"
            Resource = $Resource
        }
        $StatusResults = Invoke-HaloRequest @RequestParams
        Return $StatusResults
    }
    catch {
        Write-Error "Failed to get statuses from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
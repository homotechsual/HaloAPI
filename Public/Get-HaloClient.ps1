#Requires -Version 7
function Get-HaloClient {
    <#
        .SYNOPSIS
            Gets clients from the Halo API.
        .DESCRIPTION
            Retrieves clients from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Client ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$ClientID,
        # Paginate results
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("pageinate")]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("page_size")]
        [int32]$PageSize,
        # Which page to return.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("page_no")]
        [int32]$PageNo,
        # Which field to order results based on.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$OrderDesc,
        # Return clients matching the search term in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Search,
        # Filter by the specified top level ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("toplevel_id")]
        [int32]$TopLevelID,
        # Include active clients in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeActive,
        # Include inactive clients in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeInactive,
        # The number of clients to return if not using pagination.
        [Parameter( ParameterSetName = "Multi" )]
        [int32]$Count,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails,
        # Include ticket activity in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeActivity
    )
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'clientid=' parameter by removing it from the set parameters.
    if ($ClientID) {
        $Parameters.Remove("ClientID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ClientID) {
            Write-Verbose "Running in single-client mode because '-ClientID' was provided."
            $Resource = "api/client/$($ClientID)$($QueryString)"
        } else {
            Write-Verbose "Running in multi-client mode."
            $Resource = "api/client$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $ClientResults = Invoke-HaloRequest @RequestParams
        Return $ClientResults
    } catch {
        Write-Error "Failed to get clients from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
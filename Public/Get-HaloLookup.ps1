#Requires -Version 7
function Get-HaloLookup {
    <#
        .SYNOPSIS
            Gets Lookup information from the Halo API.
        .DESCRIPTION
            Retrieves lookup types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$ItemID,
        # Lookup ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [Parameter( ParameterSetName = "Multi", Mandatory = $True )]
        [int64]$LookupID,
        # Show all receords
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowAll,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("exclude_zero")]
        [Switch]$ExcludeZero
    )
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'ItemID=' parameter by removing it from the set parameters.
    if ($ItemID) {
        $Parameters.Remove("ItemID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ItemID) {
            Write-Verbose "Running in single mode because '-ItemID' was provided."
            $Resource = "api/Lookup/$($ItemID)$($QueryString)"
        }
        else {
            Write-Verbose "Running in multi mode."
            $Resource = "api/Lookup$($QueryString)"
        }    
        $RequestParams = @{
            Method   = "GET"
            Resource = $Resource
        }
        $LookupResults = Invoke-HaloRequest @RequestParams
        Return $LookupResults
    }
    catch {
        Write-Error "Failed to get Lookups from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
#Requires -Version 7
function Get-HaloLookup {
    <#
        .SYNOPSIS
            Gets lookup information from the Halo API.
        .DESCRIPTION
            Retrieves lookup types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$ItemID,
        # Lookup ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [Parameter( ParameterSetName = "Multi", Mandatory = $True )]
        [int64]$LookupID,
        # Show all records
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$ShowAll,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("exclude_zero")]
        [Switch]$ExcludeZero
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'ItemID=' parameter by removing it from the set parameters.
    if ($ItemID) {
        $Parameters.Remove("ItemID") | Out-Null
    }
    $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($ItemID) {
            Write-Verbose "Running in single-lookup mode because '-ItemID' was provided."
            $Resource = "api/Lookup/$($ItemID)"
        } else {
            Write-Verbose "Running in multi-lookup mode."
            $Resource = "api/Lookup"
        }
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = "lookups"
        }
        $LookupResults = New-HaloRequest @RequestParams
        Return $LookupResults
    } catch {
        Write-Error "Failed to get lookups from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
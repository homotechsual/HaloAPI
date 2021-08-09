#Requires -Version 7
function Get-HaloSupplier {
    <#
        .SYNOPSIS
            Gets suppliers from the Halo API.
        .DESCRIPTION
            Retrieves suppliers from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Supplier ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$SupplierID,
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
        # Return suppliers matching the search term in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Search,
        # The number of suppliers to return if not using pagination.
        [Parameter( ParameterSetName = "Multi" )]
        [int32]$Count,
        # Filter by the specified top level ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("toplevel_id")]
        [int32]$TopLevelID,
        # Include active suppliers in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeActive,
        # Include inactive suppliers in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeInactive,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'SupplierID=' parameter by removing it from the set parameters.
    if ($SupplierID) {
        $Parameters.Remove("SupplierID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($SupplierID) {
            Write-Verbose "Running in single-supplier mode because '-SupplierID' was provided."
            $Resource = "api/supplier/$($SupplierID)$($QueryString)"
        } else {
            Write-Verbose "Running in multi-supplier mode."
            $Resource = "api/supplier$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $SupplierResults = Invoke-HaloRequest @RequestParams
        Return $SupplierResults
    } catch {
        Write-Error "Failed to get suppliers from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
#Requires -Version 7
function Get-HaloContract {
    <#
        .SYNOPSIS
            Gets contracts from the Halo API.
        .DESCRIPTION
            Retrieves contracts from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Contract ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$ContractID,
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
        # Return contracts matching the search term in the results.
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Search,
        # The number of contracts to return if not using pagination.
        [Parameter( ParameterSetName = "Multi" )]
        [int32]$Count,
        # Filter by the specified client ID.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("client_id")]
        [int32]$ClientID
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'contractid=' parameter by removing it from the set parameters.
    if ($ContractID) {
        $Parameters.Remove("ContractID") | Out-Null
    }
    try {
        if ($ContractID) {
            Write-Verbose "Running in single-contract mode because '-ContractID' was provided."
            $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/clientcontract/$($ContractID)"
            $RequestParams = @{
                Method = "GET"
                Resource = $Resource
                QSCollection = $QSCollection
            }
        } else {
            Write-Verbose "Running in multi-contract mode."
            $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = "api/clientcontract"
            $RequestParams = @{
                Method = "GET"
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
            }
        }
        $ContractResults = New-HaloRequest @RequestParams
        Return $ContractResults
    } catch {
        Write-Error "Failed to get contracts from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
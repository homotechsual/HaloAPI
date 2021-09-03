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
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Contract ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ContractID,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return contracts matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # The number of contracts to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Filter by the specified client ID.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int32]$ClientID
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'contractid=' parameter by removing it from the set parameters.
    if ($ContractID) {
        $Parameters.Remove('ContractID') | Out-Null
    }
    try {
        if ($ContractID) {
            Write-Verbose "Running in single-contract mode because '-ContractID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/clientcontract/$($ContractID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'contracts'
            }
        } else {
            Write-Verbose 'Running in multi-contract mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/clientcontract'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'contracts'
            }
        }
        $ContractResults = New-HaloGETRequest @RequestParams
        Return $ContractResults
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorMessage = "$($CommandName) failed."
            InnerException = $_.Exception
            ErrorID = "Halo$($Command)CommandFailed"
            ErrorCategory = 'ReadError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}
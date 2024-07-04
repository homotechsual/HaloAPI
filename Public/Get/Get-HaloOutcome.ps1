#Requires -Version 7
function Get-HaloOutcome {
    <#
        .SYNOPSIS
            Gets outcomes from the Halo API.
        .DESCRIPTION
            Retrieves outcomes from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # The id of the outcome to retrieve.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$OutcomeId,
        # The number of results to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Enable pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # The number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        # The page number to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # The field to order results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Include details in the response.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters

    if ($OutcomeID) {
        $Parameters.Remove('OutcomeID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($OutcomeID) {
            Write-Verbose "Running in single-outcome mode because '-OutcomeID' was provided."
            $Resource = "api/outcome/$($OutcomeID)"
        } else {
            Write-Verbose 'Running in multi-outcome mode.'
            $Resource = 'api/outcome'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'outcomes'
        }
        $OutcomeResults = New-HaloGETRequest @RequestParams
        Return $OutcomeResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

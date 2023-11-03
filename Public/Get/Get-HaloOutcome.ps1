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
    try {
        if ($OutcomeID) {
            Write-Verbose "Running in single-item mode because '-OutcomeID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/Outcome/$($OutcomeID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'Outcome'
            }
        } else {
            Write-Verbose 'Running in multi-item mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/Outcome'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'Outcome'
            }
        }
        $OutcomeResults = New-HaloGETRequest @RequestParams
        Return $OutcomeResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

# Get-HaloOutcome.ps1
function Get-HaloOutcome {
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$OutcomeID,
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize,
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
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

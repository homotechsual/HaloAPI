#Requires -Version 7
function Get-HaloArea {
    <#
        .SYNOPSIS
            Gets area information from the Halo API.
        .DESCRIPTION
            Retrieves areas from the Halo API - supports a variety of filtering parameters.
        .EXAMPLE
            PS> Get-HaloArea -AreaID 1
            Returns the area information for the area with an ID of 1.
        .EXAMPLE
            PS> Get-HaloArea -ShowAll
            Returns all areas in the Halo API
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [alias('Get-HaloAreas')]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # ID of the area to retrieve
        [Parameter( ParameterSetName = 'Single', Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ValueFromRemainingArguments = $true, Position = 0)]
        [Alias('area_id')]
        [int64]$AreaID,
        # Show all ticket areas
        [Parameter( ParameterSetName = 'Multi', Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ValueFromRemainingArguments = $true, Position = 1 )]
        [switch]$ShowAll
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'AreaID=' parameter by removing it from the set parameters.
    if ($AreaID) {
        $Parameters.Remove('areaid') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($AreaID) {
            Write-Verbose "Running in single-field mode because '-AreaID' was provided."
            $Resource = "api/TicketArea/$($areaid)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/TicketArea'
        }
        $RequestParams = @{
            Method          = 'GET'
            Resource        = $Resource
            AutoPaginateOff = $True
            QSCollection    = $QSCollection
            ResourceType    = 'areas'
        }
        $CategoryResults = New-HaloGETRequest @RequestParams
        Return $CategoryResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
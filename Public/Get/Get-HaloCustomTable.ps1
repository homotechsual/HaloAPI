#Requires -Version 7
function Get-HaloCustomTable {
    <#
        .SYNOPSIS
            Gets custom tables from the Halo API.
        .DESCRIPTION
            Retrieves custom tables from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Custom Table ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$CustomTableId
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'customtableid=' parameter by removing it from the set parameters.
    if ($CustomTableId) {
        $Parameters.Remove('CustomTableId') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($CustomTableId) {
            Write-Verbose "Running in single-custom table mode because '-CustomTableId' was provided."
            $Resource = "api/customtable/$($CustomTableId)"
        } else {
            Write-Verbose 'Running in multi-custom button mode.'
            $Resource = 'api/customtable'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'customtables'
        }
        $CustomTableResults = New-HaloGETRequest @RequestParams
        Return $CustomTableResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
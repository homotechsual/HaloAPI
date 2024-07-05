#Requires -Version 7
function Get-HaloSoftwareLicence {
    <#
        .SYNOPSIS
            Gets software Licences from the Halo API.
        .DESCRIPTION
            Retrieves software Licences from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$LicenceID,
        # Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('client_id')]
        [int64]$ClientID,
        # Number of records to return
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
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
        # The name of the first field to order by
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails,
        # Include inactive software licenses / subscriptions.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeInactive
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'LicenceID=' parameter by removing it from the set parameters.
    if ($LicenceID) {
        $Parameters.Remove('LicenceID') | Out-Null
    }
    try {
        if ($LicenceID) {
            Write-Verbose "Running in single-item mode because '-ItemID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/SoftwareLicence/$($LicenceID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'licences'
            }
        } else {
            Write-Verbose 'Running in multi-item mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/SoftwareLicence'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'licences'
            }
        }
        $LicenceResults = New-HaloGETRequest @RequestParams
        Return $LicenceResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

#Requires -Version 7

function Get-HaloCustomField {
    <#
        .SYNOPSIS
            Gets Custom Fields from the Halo API.
        .DESCRIPTION
            Retrieves Custom Fields from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$CustomFieldID,
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
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'CustomFieldID=' parameter by removing it from the set parameters.
    if ($CustomFieldID) {
        $Parameters.Remove('CustomFieldID') | Out-Null
    }
    try {
        if ($CustomFieldID) {
            Write-Verbose "Running in single-item mode because '-ItemID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/FieldInfo/$($CustomFieldID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'FieldInfo'
            }
        } else {
            Write-Verbose 'Running in multi-item mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/FieldInfo'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'FieldInfo'
            }
        }
        $LicenceResults = New-HaloGETRequest @RequestParams
        Return $LicenceResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
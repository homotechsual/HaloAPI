#Requires -Version 7
function Get-HaloFAQList {
    <#
        .SYNOPSIS
            Gets FAQ List information from the Halo API.
        .DESCRIPTION
            Retrieves FAQ Lists from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$FAQListID,
        # Type
        [Parameter( ParameterSetName = 'Multi')]
        [string]$Type,
        # Show All
        [Parameter( ParameterSetName = 'Multi')]
        [string]$ShowAll,
        # Include Details
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'FAQListID=' parameter by removing it from the set parameters.
    if ($FAQListID) {
        $Parameters.Remove('FAQListID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($FAQListID) {
            Write-Verbose "Running in single-field mode because 'FAQListID' was provided."
            $Resource = "api/FAQLists/$($FAQListID)"
        } else {
            Write-Verbose 'Running in multi-field mode.'
            $Resource = 'api/FAQLists'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'FAQLists'
        }
        $FieldResults = New-HaloGETRequest @RequestParams
        Return $FieldResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
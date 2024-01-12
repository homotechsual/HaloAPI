using module ..\..\Classes\Completers\HaloLookupCompleter.psm1
using module ..\..\Classes\Validators\HaloLookupValidator.psm1
using module ..\..\Classes\HaloLookup.psm1
#Requires -Version 7
function Get-HaloLookup {
    <#
        .SYNOPSIS
            Gets lookup information from the Halo API.
        .DESCRIPTION
            Retrieves lookup types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$ItemID,
        # Lookup Type
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [ArgumentCompleter([HaloLookupCompleter])]
        [ValidateSet([HaloLookupValidator])]
        [string]$Lookup,
        # Lookup ID
        [Parameter( ParameterSetName = 'Single' )]
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$LookupID,
        # Show all records
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$ShowAll,
        # Exclude default lookup options with ID 0.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('exclude_zero')]
        [Switch]$ExcludeZero
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'ItemID=' parameter by removing it from the set parameters.
    if ($ItemID) {
        $Parameters.Remove('ItemID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    if ($Lookup) {
        $Parameters.Remove('Lookup') | Out-Null
        $LookupID = [HaloLookup]::ToID($Lookup)
        $QSCollection.Add('lookupid', $LookupID)
    }
    try {
        if ($ItemID) {
            Write-Verbose "Running in single-lookup mode because '-ItemID' was provided."
            $Resource = "api/lookup/$($ItemID)"
        } else {
            Write-Verbose 'Running in multi-lookup mode.'
            $Resource = 'api/lookup'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'lookup'
        }
        $LookupResults = New-HaloGETRequest @RequestParams
        Return $LookupResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
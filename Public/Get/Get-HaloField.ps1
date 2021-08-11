#Requires -Version 7
function Get-HaloField {
    <#
        .SYNOPSIS
            Gets field information from the Halo API.
        .DESCRIPTION
            Retrieves field types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Lookup Item ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$FieldID,
        # Kind
        [Parameter( ParameterSetName = "Single")]
        [Parameter( ParameterSetName = "Multi")]
        [string]$Kind,
        # Include Details
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeDetails
    )

    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'FieldID=' parameter by removing it from the set parameters.
    if ($FieldID) {
        $Parameters.Remove("FieldID") | Out-Null
    }
    $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($FieldID) {
            Write-Verbose "Running in single-lookup mode because '-FieldID' was provided."
            $Resource = "api/Field/$($FieldID)"
        } else {
            Write-Verbose "Running in multi-lookup mode."
            $Resource = "api/Field"
        }
        $RequestParams = @{
            Method          = "GET"
            Resource        = $Resource
            AutoPaginateOff = $True
            QSCollection    = $QSCollection
            ResourceType    = "fields"
        }
        $FieldResults = New-HaloRequest @RequestParams
        Return $FieldResults
    } catch {
        Write-Error "Failed to get fields from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
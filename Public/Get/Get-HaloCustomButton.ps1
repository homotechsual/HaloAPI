# Use ArgumentCompleter class for Halo Custom Button.
using module ..\..\Classes\Completers\HaloCustomButtonCompleter.psm1
# Use ValidateSet class for Halo Custom Button.
using module ..\..\Classes\Validators\HaloCustomButtonValidator.psm1
# Use HaloCustomButton class.
using module ..\..\Classes\HaloCustomButton.psm1

#Requires -Version 7
function Get-HaloCustomButton {
    <#
        .SYNOPSIS
            Gets custom buttons from the Halo API.
        .DESCRIPTION
            Retrieves custom buttons from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Custom Button ID.
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$CustomButtonID,
        # Filter by the specified type.
        [Parameter( ParameterSetName = "Multi" )]
        [ArgumentCompleter([HaloCustomButtonCompleter])]
        [ValidateSet([HaloCustomButtonValidator])]
        [string]$Type,
        # Include custom buttons which are setup (defaults to $True).
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IsButtonSetup,
        # Include extra detail objects in the response.
        [Parameter( ParameterSetName = "Single" )]
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$IncludeDetails
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'custombuttonid=' parameter by removing it from the set parameters.
    if ($CustomButtonID) {
        $Parameters.Remove("CustomButtonID") | Out-Null
    }
    $QSCollection = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    if ($Type) {
        $Parameters.Remove("Type")
        $TypeID = [HaloCustomButton]::ToID($Type)
        $QSCollection.Add("typeid", $TypeID)
    }
    try {
        if ($AgentID) {
            Write-Verbose "Running in single-custom button mode because '-CustomButtonID' was provided."
            $Resource = "api/custombutton/$($CustomButtonID)"
        } else {
            Write-Verbose "Running in multi-custom button mode."
            $Resource = "api/custombutton"
        }
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = "custombuttons"
        }
        $CustomButtonResults = New-HaloGETRequest @RequestParams
        Return $CustomButtonResults
    } catch {
        Write-Error "Failed to get custom buttons from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
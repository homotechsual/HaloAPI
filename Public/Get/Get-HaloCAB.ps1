#using module ..\..\Classes\Transformations\HaloPipelineIDArgumentTransformation.psm1
#Requires -Version 7
function Get-HaloCAB {
    <#
        .SYNOPSIS
            Gets CAB (Change Approval Board) information from the Halo API.
        .DESCRIPTION
            Retrieves change approval board information from the Halo API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # CAB ID.
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$CABID,
        # Include CAB member information in the response.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$IncludeMembers,
        # Include CAB details in the response.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'cabid=' parameter by removing it from the set parameters.
    if ($CABID) {
        $Parameters.Remove('CABID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($CABID) {
            Write-Verbose "Running in single-CAB mode because '-CABID' was provided."
            $Resource = "api/CAB/$($ActionID)"
        } else {
            Write-Verbose 'Running in multi-action mode.'
            $Resource = 'api/CAB'
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'CAB'
        }
        $CABResults = New-HaloGETRequest @RequestParams
        Return $CABResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
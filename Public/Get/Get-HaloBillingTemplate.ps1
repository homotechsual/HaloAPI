#Requires -Version 7
function Get-HaloBillingTemplate {
    <#
        .SYNOPSIS
            Gets billing templates from the Halo API.
        .DESCRIPTION
            Retrieves billing templates from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Template ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$TemplateID,
        # Show all results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('show_all')]
        [switch]$ShowAll,
        # Include details in results
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails

    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'TemplateID=' parameter by removing it from the set parameters.
    if ($TemplateID) {
        $Parameters.Remove('TemplateID') | Out-Null
    }
    try {
        if ($TemplateID) {
            Write-Verbose "Running in single-template mode because '-TemplateID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/billingtemplate/$($TemplateID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'billingtemplate'
            }
        } else {
            Write-Verbose 'Running in multi-template mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/billingtemplate'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'billingtemplate'
            }
        }
        $TemplateResults = New-HaloGETRequest @RequestParams
        Return $TemplateResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
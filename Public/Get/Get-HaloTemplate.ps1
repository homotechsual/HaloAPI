#Requires -Version 7
function Get-HaloTemplate {
    <#
        .SYNOPSIS
            Gets templates from the Halo API.
        .DESCRIPTION
            Retrieves templates from the Halo API - supports a variety of filtering parameters.
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
        # The field to order the results by.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Return templates matching the search term in the results.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # The number of templates to return if not using pagination.
        [Parameter( ParameterSetName = 'Multi' )]
        [int32]$Count,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [switch]$IncludeDetails
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'templateid=' parameter by removing it from the set parameters.
    if ($TemplateID) {
        $Parameters.Remove('TemplateID') | Out-Null
    }
    try {
        if ($TemplateID) {
            Write-Verbose "Running in single-template mode because '-TemplateID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = ('api/template/{0}' -f $TemplateID)
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'templates'
            }
        } else {
            Write-Verbose 'Running in multi-template mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/template'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'templates'
            }
        }
        $TemplateResults = New-HaloGETRequest @RequestParams
        Return $TemplateResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

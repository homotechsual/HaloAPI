#Requires -Version 7
function Get-HaloKBArticle {
    <#
        .SYNOPSIS
            Gets knowledgebase articles from the Halo API.
        .DESCRIPTION
            Retrieves knowledgebase articles from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Article ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$KBArticleID,
        # Number of records to return
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Count,
        # Filters response based on the search string
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Advanced Search
        [Parameter( ParameterSetName = 'Multi')]
        [Alias('advanced_search')]
        [string]$AdvancedSearch,
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
    # Workaround to prevent the query string processor from adding a 'KBArticleid=' parameter by removing it from the set parameters.
    if ($KBArticleID) {
        $Parameters.Remove('KBArticleID') | Out-Null
    }
    try {
        if ($KBArticleID) {
            Write-Verbose "Running in single-article mode because '-KBArticleID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/KBArticle/$($KBArticleID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'articles'
            }
        } else {
            Write-Verbose 'Running in multi-article mode.'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/KBArticle'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $Paginate
                QSCollection = $QSCollection
                ResourceType = 'articles'
            }
        }
        $ItemResults = New-HaloGETRequest @RequestParams
        Return $ItemResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
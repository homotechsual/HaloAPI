#Requires -Version 7
function Get-HaloKBArticle {
    <#
        .SYNOPSIS
            Gets KB Articles from the Halo API.
        .DESCRIPTION
            Retrieves KB Articles from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Item ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [int64]$KBArticleID,
        # Number of records to return
        [Parameter( ParameterSetName = "Multi" )]
        [int64]$Count,
        # Filters response based on the search string
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Search,
        # Paginate results
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("pageinate")]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("page_size")]
        [int32]$PageSize,
        # Which page to return.
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("page_no")]
        [int32]$PageNo,
        # The name of the first field to order by
        [Parameter( ParameterSetName = "Multi" )]
        [string]$Order,
        # Whether to order ascending or descending
        [Parameter( ParameterSetName = "Multi" )]
        [switch]$OrderDesc,  
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [switch]$IncludeDetails
    )
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'KBArticleid=' parameter by removing it from the set parameters.
    if ($KBArticleID) {
        $Parameters.Remove("KBArticleID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($KBArticleID) {
            Write-Verbose "Running in single-item mode because '-KBArticleID' was provided."
            $Resource = "api/KBArticle/$($KBArticleID)$($QueryString)"
        } else {
            Write-Verbose "Running in multi-item mode."
            $Resource = "api/KBArticle$($QueryString)"
        }    
        $RequestParams = @{
            Method = "GET"
            Resource = $Resource
        }
        $ItemResults = Invoke-HaloRequest @RequestParams
        Return $ItemResults
    } catch {
        Write-Error "Failed to get KB Articles from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
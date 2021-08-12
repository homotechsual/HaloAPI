Function Set-HaloKBArticle {
    <#
        .SYNOPSIS
            Updates a knowledgebase article via the Halo API.
        .DESCRIPTION
            Function to send an knowledgebase article update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing knowedgebase article.
        [Parameter( Mandatory = $True )]
        [Object]$KBArticle
    )
    try {
        $ObjectToUpdate = Get-HaloKBArticle -ArticleID $KBArticle.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Article '$($ObjectToUpdate.name)'", "Update")) {
                New-HaloPOSTRequest -Object $KBArticle -Endpoint "kbarticle" -Update
            }
        } else {
            Throw "Article was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update article with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
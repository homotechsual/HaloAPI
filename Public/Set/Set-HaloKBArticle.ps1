Function Set-HaloKBArticle {
    <#
        .SYNOPSIS
            Updates one or more knowledgebase articles via the Halo API.
        .DESCRIPTION
            Function to send an knowledgebase article update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing knowedgebase articles.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$KBArticle
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $KBArticle | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'KB article ID is required.'
            }
            $HaloKBArticleParams = @{
                ArticleId = $_.id
            }
            $KBArticleExists = Get-HaloArticle @HaloKBArticleParams
            if ($KBArticleExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($KBArticle -is [Array] ? 'Knowledgebase Articles' : 'Knowledgebase Article', 'Update')) {
                New-HaloPOSTRequest -Object $KBArticle -Endpoint 'kbarticle'
            }
        } else {
            Throw 'One or more knowledgebase articles was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
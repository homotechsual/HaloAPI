Function New-HaloKBArticle {
    <#
        .SYNOPSIS
            Creates a knowledgebase article via the Halo API.
        .DESCRIPTION
            Function to send a knowledgebase article creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new knowledgebase article.
        [Parameter( Mandatory = $True )]
        [Object]$KBArticle
    )
    try {
        if ($PSCmdlet.ShouldProcess("Article '$($Article.name)'", "Create")) {
            New-HaloPOSTRequest -Object $KBArticle -Endpoint "kbarticle"
        }
    } catch {
        Write-Error "Failed to create article with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
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
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Article '$($KBArticle.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $KBArticle -Endpoint 'kbarticle'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
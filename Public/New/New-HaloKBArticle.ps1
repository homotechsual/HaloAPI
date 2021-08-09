Function New-HaloKBArticle {
    <#
    .SYNOPSIS
        Creates a knowledgebase article via the Halo API.
    .DESCRIPTION
        Function to send a knowledgebase article creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$KBArticle
    )
    Invoke-HaloUpdate -Object $KBArticle -Endpoint "KBArticle"
}
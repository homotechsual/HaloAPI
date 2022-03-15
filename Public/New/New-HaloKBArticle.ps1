Function New-HaloKBArticle {
    <#
        .SYNOPSIS
            Creates one or more knowledgebase articles via the Halo API.
        .DESCRIPTION
            Function to send a knowledgebase article creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new knowledgebase articles.
        [Parameter( Mandatory = $True )]
        [Object[]]$KBArticle
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($KBArticle -is [Array] ? 'Knowledgebase Articles' : 'Knowledgebase Article', 'Create')) {
            New-HaloPOSTRequest -Object $KBArticle -Endpoint 'kbarticle'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
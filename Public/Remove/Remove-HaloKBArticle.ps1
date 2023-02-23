function Remove-HaloKBArticle {
    <#
        .SYNOPSIS
           Removes a knowledgebase articles from the Halo API.
        .DESCRIPTION
            Deletes a specific knowledgebase articles from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The client ID
        [Parameter( Mandatory = $True )]
        [Alias('KBArticle')]
        [int64]$KBArticleID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloKBArticle -KBArticleID $KBArticleID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("KBArticleID '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/KBArticle/$($KBArticleID)"
                $ClientResults = New-HaloDELETERequest -Resource $Resource
                Return $ClientResults
            }
        } else {
            Throw 'Knowledgebase article was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

Function New-HaloKBArticleBatch {
    <#
        .SYNOPSIS
            Creates multiple knowledgebase articles via the Halo API.
        .DESCRIPTION
            Function to send a batch of knowledgebase article creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new knowledgebase articles.
        [Parameter( Mandatory = $True )]
        [Array[]]$KBArticles,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('KBArticles', 'Create')) {
            if ($KBArticles -is [Array]) {
                $BatchParams = @{
                    BatchInput = $KBArticles
                    EntityType = 'KBArticle'
                    Operation = 'New'
                }
                if ($BatchSize) {
                    $BatchParams.Size = $BatchSize
                }
                if ($BatchWait) {
                    $BatchParams.Wait = $BatchWait
                }
                $BatchResults = Invoke-HaloBatchProcessor @BatchParams
                Return $BatchResults
            } else {
                throw 'New-HaloKBArticleBatch requires an array of knowledgebase articles to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
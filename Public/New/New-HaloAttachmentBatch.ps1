Function New-HaloAttachmentBatch {
    <#
        .SYNOPSIS
            Creates multiple attachments via the Halo API.
        .DESCRIPTION
            Function to send a batch of attachment creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new attachments.
        [Parameter( Mandatory = $True )]
        [Array[]]$Attachments,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Attachments', 'Create')) {
            if ($Attachments -is [Array]) {
                $BatchParams = @{
                    Input = $Attachments
                    EntityType = 'Attachment'
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
                throw 'New-HaloAttachmentBatch requires an array of attachments to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
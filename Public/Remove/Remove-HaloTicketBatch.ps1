Function Remove-HaloTicketBatch {
    <#
        .SYNOPSIS
            Removes multiple tickets via the Halo API.
        .DESCRIPTION
            Function to send a batch of ticket removal requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to remove one or more tickets. This should be an array of ticket ids.
        [Parameter( Mandatory = $True )]
        [Int64[]]$Tickets,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Tickets', 'Delete')) {
            if ($Tickets -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Tickets
                    EntityType = 'Ticket'
                    Operation = 'Remove'
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
                throw 'Remove-HaloTicketBatch requires an array of ticket ids to delete.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
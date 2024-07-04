Function Remove-HaloActionBatch {
    <#
        .SYNOPSIS
            Removes multiple actions via the Halo API.
        .DESCRIPTION
            Function to send a batch of action removal requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to remove one or more actions. This should be an array of objects containing an `Id` and `TicketId` property.
        [Parameter( Mandatory = $True )]
        [Int64[]]$Actions,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Actions', 'Delete')) {
            if ($Actions -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Actions
                    EntityType = 'Action'
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
                throw 'Remove-HaloActionBatch requires an array of actions to delete.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function New-HaloTicketTypeBatch {
    <#
        .SYNOPSIS
            Creates multiple ticket types via the Halo API.
        .DESCRIPTION
            Function to send a batch of ticket type creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new ticket types.
        [Parameter( Mandatory = $True )]
        [Array[]]$TicketTypes,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Ticket Types', 'Create')) {
            if ($TicketTypes -is [Array]) {
                $BatchParams = @{
                    Input = $TicketTypes
                    EntityType = 'TicketType'
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
                throw 'New-HaloTicketTypeBatch requires an array of ticket types to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
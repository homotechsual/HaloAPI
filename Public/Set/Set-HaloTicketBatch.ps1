Function Set-HaloTicketBatch {
    <#
        .SYNOPSIS
            Updates multiple tickets via the Halo API in a batch process.
        .DESCRIPTION
            Function to send a batch of ticket update requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to update one or more existing tickets.
        [Parameter(Mandatory = $True)]
        [Array[]]$Tickets,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize = 100,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait = 1,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Tickets', 'Update')) {
            if ($Tickets -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Tickets
                    EntityType = 'Ticket'
                    Operation = 'Set'
                    Size = $BatchSize
                    Wait = $BatchWait
                }
                if ($DebugPreference -eq 'Continue') {
                    $BatchParams.Debug = $True
                }
                if ($VerbosePreference -eq 'Continue') {
                    $BatchParams.Verbose = $True
                }
                $BatchResults = Invoke-HaloBatchProcessor @BatchParams
                Return $BatchResults
            } else {
                throw 'Set-HaloTicketBatch requires an array of tickets to update.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
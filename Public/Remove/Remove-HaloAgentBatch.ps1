Function Remove-HaloAgentBatch {
    <#
        .SYNOPSIS
            Removes multiple agents via the Halo API.
        .DESCRIPTION
            Function to send a batch of agent removal requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to remove one or more agents. This should be an array of agent ids.
        [Parameter( Mandatory = $True )]
        [Int64[]]$Agents,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Agents', 'Delete')) {
            if ($Agents -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Agents
                    EntityType = 'Agent'
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
                throw 'Remove-HaloAgentBatch requires an array of agent ids to delete.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
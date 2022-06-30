Function New-HaloAgentBatch {
    <#
        .SYNOPSIS
            Creates multiple agents via the Halo API.
        .DESCRIPTION
            Function to send a batch of agent creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new agents.
        [Parameter( Mandatory = $True )]
        [Array[]]$Agents,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Agents', 'Create')) {
            Write-Debug "Input:`n $($Agents | ConvertTo-Json -AsArray -Depth 5)"
            Write-Debug "Input type: $($Agents.GetType())"
            if ($Agents -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Agents
                    EntityType = 'Agent'
                    Operation = 'New'
                }
                if ($BatchSize) {
                    $BatchParams.Size = $BatchSize
                }
                if ($BatchWait) {
                    $BatchParams.Wait = $BatchWait
                }
                Write-Debug "Batch processor params:`n$($BatchParams | Out-String )"
                $BatchResults = Invoke-HaloBatchProcessor @BatchParams
                Return $BatchResults
            } else {
                throw 'New-HaloAgentBatch requires an array of agents to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
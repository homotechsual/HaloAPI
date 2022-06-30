Function New-HaloActionBatch {
    <#
        .SYNOPSIS
            Creates multiple actions via the Halo API.
        .DESCRIPTION
            Function to send a batch of action creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new actions.
        [Parameter( Mandatory = $True )]
        [Array[]]$Actions,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Actions', 'Create')) {
            if ($Actions -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Actions
                    EntityType = 'Action'
                    Operation = 'New'
                }
                if ($BatchSize) {
                    $BatchParams.Size = $BatchSize
                }
                if ($BatchWait) {
                    $BatchParams.Wait = $BatchWait
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
                throw 'New-HaloActionBatch requires an array of actions to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
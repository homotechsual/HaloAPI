Function Set-HaloActionBatch {
    <#
        .SYNOPSIS
            Updates multiple actions via the Halo API.
        .DESCRIPTION
            Function to send a batch of action update requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to update one or more existing actions.
        [Parameter( Mandatory = $True )]
        [Array[]]$Actions,
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
        if ($PSCmdlet.ShouldProcess('Actions', 'Update')) {
            if ($Actions -is [Array]) {
                $BatchParams = @{
                    BatchInput = $Actions
                    EntityType = 'Action'
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
                throw 'Set-HaloActionBatch requires an array of actions to update.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
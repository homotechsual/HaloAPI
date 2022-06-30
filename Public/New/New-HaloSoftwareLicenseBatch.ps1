Function New-HaloSoftwareLicenseBatch {
    <#
        .SYNOPSIS
            Creates multiple software licenses via the Halo API.
        .DESCRIPTION
            Function to send a batch of software license creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new software licenses.
        [Parameter( Mandatory = $True )]
        [Array[]]$SoftwareLicenses,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Software Licenses', 'Create')) {
            if ($SoftwareLicenses -is [Array]) {
                $BatchParams = @{
                    BatchInput = $SoftwareLicenses
                    EntityType = 'SoftwareLicense'
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
                throw 'New-HaloSoftwareLicenseBatch requires an array of software licenses to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
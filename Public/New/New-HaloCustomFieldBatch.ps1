Function New-HaloCustomFieldBatch {
    <#
        .SYNOPSIS
            Creates multiple custom fields via the Halo API.
        .DESCRIPTION
            Function to send a batch of custom field creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new custom fields.
        [Parameter( Mandatory = $True )]
        [Array[]]$CustomFields,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('CustomFields', 'Create')) {
            if ($CustomFields -is [Array]) {
                $BatchParams = @{
                    BatchInput = $CustomFields
                    EntityType = 'CustomField'
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
                throw 'New-HaloCustomFieldBatch requires an array of custom fields to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
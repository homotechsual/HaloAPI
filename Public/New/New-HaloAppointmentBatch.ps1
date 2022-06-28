Function New-HaloAppointmentBatch {
    <#
        .SYNOPSIS
            Creates multiple appointments via the Halo API.
        .DESCRIPTION
            Function to send a batch of appointment creation requests to the Halo API
        .OUTPUTS
            Outputs an object containing the responses from the web requests.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Array of objects containing properties and values used to create one or more new appointments.
        [Parameter( Mandatory = $True )]
        [Array[]]$Appointments,
        # How many objects to process at once before delaying. Default value is 100.
        [Int32]$BatchSize,
        # How long to wait between batch runs. Default value is 1 second.
        [Int32]$BatchWait
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess('Appointments', 'Create')) {
            if ($Appointments -is [Array]) {
                $BatchParams = @{
                    Input = $Appointments
                    EntityType = 'Appointment'
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
                throw 'New-HaloAppointmentBatch requires an array of appointments to create.'
            }  
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
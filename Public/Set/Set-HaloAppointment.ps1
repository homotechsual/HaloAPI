Function Set-HaloAppointment {
    <#
        .SYNOPSIS
            Updates one or more appointments via the Halo API.
        .DESCRIPTION
            Function to send an appointment update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing appointments.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Appointment
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Appointment {
            $HaloAppointmentParams = @{
                AppointmentId = $_.id
            }
            $AppointmentExists = Get-HaloAppointment @HaloAppointmentParams
            if ($AppointmentExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Appointment -is [Array] ? 'Appointments' : 'Appointment', 'Update')) {
                New-HaloPOSTRequest -Object $Appointment -Endpoint 'appointment' -Update
            }
        } else {
            Throw 'One or more appointments was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function New-HaloAppointment {
    <#
        .SYNOPSIS
            Creates one or more appointments via the Halo API.
        .DESCRIPTION
            Function to send an appointment creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new appointments.
        [Parameter( Mandatory = $True )]
        [Object[]]$Appointment
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Appointment -is [Array] ? 'Appointments' : 'Appointment', 'Create')) {
            New-HaloPOSTRequest -Object $Appointment -Endpoint 'appointment'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
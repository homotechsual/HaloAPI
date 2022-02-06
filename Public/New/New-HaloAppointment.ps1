Function New-HaloAppointment {
    <#
        .SYNOPSIS
            Creates an appointment via the Halo API.
        .DESCRIPTION
            Function to send an appointment creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new appointment.
        [Parameter( Mandatory = $True )]
        [Object]$Appointment
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Appointment '$($Appointment.subject)'", 'Create')) {
            New-HaloPOSTRequest -Object $Appointment -Endpoint 'appointment'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
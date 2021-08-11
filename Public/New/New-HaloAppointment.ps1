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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new appointment.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Appointment
    )
    if ($PSCmdlet.ShouldProcess("Appointment", "Create")) {
        Invoke-HaloUpdate -Object $Appointment -Endpoint "appointment"
    }
}
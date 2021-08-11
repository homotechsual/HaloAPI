Function Set-HaloAppointment {
    <#
        .SYNOPSIS
            Updates an appointment via the Halo API.
        .DESCRIPTION
            Function to send an appointment update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing appointment.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Appointment
    )
    if ($PSCmdlet.ShouldProcess("Appointment", "Update")) {
        Invoke-HaloUpdate -Object $Appointment -Endpoint "appointment" -Update
    }
}
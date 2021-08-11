Function Set-HaloAppointment {
    <#
    .SYNOPSIS
        Updates an appointment via the Halo API.
    .DESCRIPTION
        Function to send an appointment update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing appointment.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Appointment
    )
    Invoke-HaloUpdate -Object $Appointment -Endpoint "appointment" -Update
}
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
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Appointment
    )
    Invoke-HaloUpdate -Object $Appointment -Endpoint "Appointment" -update
}
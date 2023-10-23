function Remove-HaloAppointment {
    <#
        .SYNOPSIS
           Removes an Appointment from the Halo API.
        .DESCRIPTION
            Deletes a specific Appointment from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Appointment ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$AppointmentID,
        # Object containing Appointment id and ticket id for batch processing.
        [Parameter( Mandatory, ParameterSetName = 'Batch')]
        [Object]$Appointment
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($Appointment) {
            $AppointmentID = $Appointment.Id
        }
        $ObjectToDelete = Get-HaloAppointment -AppointmentID $AppointmentID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Appointment '$($ObjectToDelete.id)' by '$($ObjectToDelete.who)'", 'Delete')) {
                $Resource = "api/Appointment/$($AppointmentID)"
                $AppointmentResults = New-HaloDELETERequest -Resource $Resource
                Return $AppointmentResults
            }
        } else {
            Throw 'Appointment was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
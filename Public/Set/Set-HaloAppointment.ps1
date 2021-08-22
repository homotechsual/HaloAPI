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
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloAppointment -AppointmentID $Appointment.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Appointment '$($ObjectToUpdate.subject)'", 'Update')) {
                New-HaloPOSTRequest -Object $Appointment -Endpoint 'appointment' -Update
            }
        } else {
            Throw 'Appointment was not found in Halo to update.'
        }
    } catch {
        $Command = $CommandName -Replace '-', ''
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorMessage = "$($CommandName) failed."
            InnerException = $_.Exception
            ErrorID = "Halo$($Command)CommandFailed"
            ErrorCategory = 'ReadError'
            TargetObject = $_.TargetObject
            ErrorDetails = $_.ErrorDetails
            BubbleUpDetails = $False
        }
        $CommandError = New-HaloErrorRecord @ErrorRecord
        $PSCmdlet.ThrowTerminatingError($CommandError)
    }
}
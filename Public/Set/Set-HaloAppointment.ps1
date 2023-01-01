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
        [Object[]]$Appointment,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Appointment | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Appointment ID is required.'
            }
            $HaloAppointmentParams = @{
                AppointmentId = ($_.id)
            }
            if (-not $SkipValidation) {
                $AppointmentExists = Get-HaloAppointment @HaloAppointmentParams
                if ($AppointmentExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Appointment -is [Array] ? 'Appointments' : 'Appointment', 'Update')) {
                New-HaloPOSTRequest -Object $Appointment -Endpoint 'appointment'
            }
        } else {
            Throw 'One or more appointments was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
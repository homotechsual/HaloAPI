Function Set-HaloTicketType {
    <#
        .SYNOPSIS
            Updates a ticket type via the Halo API.
        .DESCRIPTION
            Function to send a ticket type update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing ticket type.
        [Parameter( Mandatory = $True )]
        [Object]$TicketType
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloTicketType -TicketTypeID $TicketType.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Ticket Type '$($TicketType.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype' -Update
            }
        } else {
            Throw 'Ticket Type not found in Halo to update.'
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
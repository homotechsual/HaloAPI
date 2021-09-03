Function Set-HaloTicket {
    <#
        .SYNOPSIS
            Updates a ticket via the Halo API.
        .DESCRIPTION
            Function to send a ticket update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing ticket.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Ticket
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToUpdate = Get-HaloTicket -TicketID $Ticket.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Ticket '$($Ticket.summary)'", 'Update')) {
                New-HaloPOSTRequest -Object $Ticket -Endpoint 'tickets' -Update
            }
        } else {
            Throw 'Ticket was not found in Halo to update.'
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
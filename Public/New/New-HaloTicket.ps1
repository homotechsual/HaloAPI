Function New-HaloTicket {
    <#
        .SYNOPSIS
            Creates a ticket via the Halo API.
        .DESCRIPTION
            Function to send a ticket creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new ticket.
        [Parameter( Mandatory = $True )]
        [Object]$Ticket
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        if ($PSCmdlet.ShouldProcess("Ticket '$($Ticket.summary)'", 'Create')) {
            New-HaloPOSTRequest -Object $Ticket -Endpoint 'tickets'
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
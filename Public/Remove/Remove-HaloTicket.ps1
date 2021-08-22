function Remove-HaloTicket {
    <#
        .SYNOPSIS
           Removes a ticket from the Halo API.
        .DESCRIPTION
            Deletes a specific ticket from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [int64]$TicketID
    )
    Invoke-HaloPreFlightChecks
    $CommandName = $MyInvocation.InvocationName
    try {
        $ObjectToDelete = Get-HaloTicket -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Ticket '$($ObjectToDelete.summary)')'", 'Delete')) {
                $Resource = "api/tickets/$($TicketID)"
                $TicketResults = New-HaloDELETERequest -Resource $Resource
                Return $TicketResults
            }
        } else {
            Throw 'Ticket was not found in Halo to delete.'
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
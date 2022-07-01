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
        [Alias('Ticket')]
        [int64]$TicketID
    )
    Invoke-HaloPreFlightCheck
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
        New-HaloError -ErrorRecord $_
    }
}
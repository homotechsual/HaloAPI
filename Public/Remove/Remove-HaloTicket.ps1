function Remove-HaloTicket {
    <#
        .SYNOPSIS
           Removes a ticket from the Halo API.
        .DESCRIPTION
            Deletes a specific ticket from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = "High" )]
    [OutputType([Object])]
    Param(
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [int64]$TicketID
    )
    try {
        $ObjectToDelete = Get-HaloTicket -TicketID $TicketID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Ticket '$($ObjectToDelete.summary)')'", "Delete")) {
                $Resource = "api/tickets/$($TicketID)"
                $TicketResults = New-HaloDELETERequest -Resource $Resource
                Return $TicketResults
            }
        } else {
            Throw "Ticket was not found in Halo to delete."
        }
    } catch {
        Write-Error "Failed to delete ticket from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
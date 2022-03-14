Function Set-HaloTicketType {
    <#
        .SYNOPSIS
            Updates one or more ticket types via the Halo API.
        .DESCRIPTION
            Function to send a ticket type update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing ticket types.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$TicketType
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloTicketType -TicketTypeID $TicketType.id
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $TicketType {
            $HaloTicketTypeParams = @{
                TicketTypeId = $_.id
            }
            $TicketTypeExists = Get-HaloTicketType @HaloTicketTypeParams
            if ($TicketTypeExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($TicketType -is [Array] ? 'Ticket Types' : 'Ticket Type', 'Update')) {
                New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype' -Update
            }
        } else {
            Throw 'One or more ticket types not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
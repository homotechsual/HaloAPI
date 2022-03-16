Function Set-HaloAction {
    <#
        .SYNOPSIS
            Updates one or more actions via the Halo API.
        .DESCRIPTION
            Function to send a action update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing actions.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$Action
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $Action | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Action ID is required.'
            }
            if ($null -eq $_.ticket_id) {
                throw 'Ticket ID is required.'
            }
            $HaloActionParams = @{
                ActionID = ($_.id)
                TicketID = ($_.ticket_id)
            }
            $ActionExists = Get-HaloAction @HaloActionParams
            if ($ActionExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectsToUpdate) {
            if ($PSCmdlet.ShouldProcess($Action -is [Array] ? 'Actions' : 'Action', 'Update')) {
                New-HaloPOSTRequest -Object $Action -Endpoint 'actions'
            }
        } else {
            Throw 'One or more actions was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
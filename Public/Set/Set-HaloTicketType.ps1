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
        [Object[]]$TicketType,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $TicketType | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Ticket type ID is required.'
            }
            $HaloTicketTypeParams = @{
                TicketTypeId = $_.id
            }
            if (-not $SkipValidation) {
                $TicketTypeExists = Get-HaloTicketType @HaloTicketTypeParams
                if ($TicketTypeExists) {
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
            if ($PSCmdlet.ShouldProcess($TicketType -is [Array] ? 'Ticket Types' : 'Ticket Type', 'Update')) {
                New-HaloPOSTRequest -Object $TicketType -Endpoint 'tickettype'
            }
        } else {
            Throw 'One or more ticket types not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function New-HaloClient {
    <#
        .SYNOPSIS
            Creates one or more clients via the Halo API.
        .DESCRIPTION
            Function to send a client creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new clients.
        [Parameter( Mandatory = $True )]
        [Object[]]$Client
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Client -is [Array] ? 'Clients' : 'Client', 'Create')) {
            New-HaloPOSTRequest -Object $Client -Endpoint 'client'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
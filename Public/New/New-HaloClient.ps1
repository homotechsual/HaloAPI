Function New-HaloClient {
    <#
        .SYNOPSIS
            Creates a client via the Halo API.
        .DESCRIPTION
            Function to send a client creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new client.
        [Parameter( Mandatory = $True )]
        [Object]$Client
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Client '$($Client.name)", 'Create')) {
            New-HaloPOSTRequest -Object $Client -Endpoint 'client'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
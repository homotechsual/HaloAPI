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
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new client.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Client
    )
    if ($PSCmdlet.ShouldProcess("Client", "Create")) {
        Invoke-HaloUpdate -Object $Client -Endpoint "client"
    }
}
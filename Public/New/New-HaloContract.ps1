Function New-HaloContract {
    <#
        .SYNOPSIS
            Creates a contract via the Halo API.
        .DESCRIPTION
            Function to send a contract creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new contract.
        [Parameter( Mandatory = $True )]
        [Object]$Contract
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Contract '$($Contract.ref)'", 'Create')) {
            New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
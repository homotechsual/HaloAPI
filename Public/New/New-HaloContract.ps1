Function New-HaloContract {
    <#
        .SYNOPSIS
            Creates one or more contracts via the Halo API.
        .DESCRIPTION
            Function to send a contract creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new contracts.
        [Parameter( Mandatory = $True )]
        [Object[]]$Contract
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Contract -is [Array] ? 'Contracts' : 'Contract', 'Create')) {
            New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
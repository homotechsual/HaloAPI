Function New-HaloContract {
    <#
    .SYNOPSIS
        Creates a contract via the Halo API.
    .DESCRIPTION
        Function to send a contract creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new contract.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Contract
    )
    Invoke-HaloUpdate -Object $Contract -Endpoint "clientcontract"
}
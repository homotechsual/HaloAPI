Function New-HaloContract {
    <#
        .SYNOPSIS
            Updates a contract via the Halo API.
        .DESCRIPTION
            Function to send a contract update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing contract.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Contract
    )
    if ($PSCmdlet.ShouldProcess("Contract", "Update")) {
        Invoke-HaloUpdate -Object $Contract -Endpoint "clientcontract" -Update
    }
}
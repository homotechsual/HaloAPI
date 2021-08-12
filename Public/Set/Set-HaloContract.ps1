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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing contract.
        [Parameter( Mandatory = $True )]
        [Object]$Contract
    )
    try {
        $ObjectToUpdate = Get-HaloContract -ContractID $Contract.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Contract '$($ObjectToUpdate.ref)'", "Update")) {
                New-HaloPOSTRequest -Object $Contract -Endpoint "clientcontract" -Update
            }
        } else {
            Throw "Contract was not found in Halo to update."
        }
    } catch {
        Write-Error "Failed to update contract with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
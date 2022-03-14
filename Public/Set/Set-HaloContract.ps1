Function Set-HaloContract {
    <#
        .SYNOPSIS
            Updates one or more contracts via the Halo API.
        .DESCRIPTION
            Function to send a contract update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing contracts.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Contract
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Contract {
            $HaloContractParams = @{
                ContractId = $_.id
            }
            $ContractExists = Get-HaloContract @HaloContractParams
            if ($ContractExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Contract -is [Array] ? 'Contracts' : 'Contract', 'Update')) {
                New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract' -Update
            }
        } else {
            Throw 'One or more contracts was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
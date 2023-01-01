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
        [Object[]]$Contract,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Contract | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Contract ID is required.'
            }
            $HaloContractParams = @{
                ContractId = ($_.id)
            }
            if (-not $SkipValidation) {
                $ContractExists = Get-HaloContract @HaloContractParams
                if ($ContractExists) {
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
            if ($PSCmdlet.ShouldProcess($Contract -is [Array] ? 'Contracts' : 'Contract', 'Update')) {
                New-HaloPOSTRequest -Object $Contract -Endpoint 'clientcontract'
            }
        } else {
            Throw 'One or more contracts was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
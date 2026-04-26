function Remove-HaloContract {
    <#
        .SYNOPSIS
           Removes a Contract from the Halo API.
        .DESCRIPTION
            Deletes a specific contract from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Contract ID
        [Parameter( Mandatory = $True )]
        [int64]$ContractID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloContract -ContractID $ContractID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess(('Contract ''{0}''' -f $ObjectToDelete.ref), 'Delete')) {
                $Resource = ('api/ClientContract/{0}' -f $ContractID)
                $ContractResult = New-HaloDELETERequest -Resource $Resource
                Return $ContractResult
            }
        } else {
            Throw ('Contract with ID: ''{0}'' was not found in Halo to delete.' -f $ContractID)
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

function Remove-HaloCAB {
    <#
        .SYNOPSIS
           Removes a CAB from the Halo API.
        .DESCRIPTION
            Deletes a specific CAB from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The CAB ID
        [Parameter( Mandatory, ParameterSetName = 'Single' )]
        [int64]$CABID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloCAB -CABID $CABID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("CAB '$($ObjectToDelete.name)'", 'Delete')) {
                $Resource = "api/CAB/$($CABID)"
                $CABResults = New-HaloDELETERequest -Resource $Resource
                Return $CABResults
            }
        } else {
            Throw 'CAB was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
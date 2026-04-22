function Remove-HaloService {
    <#
        .SYNOPSIS
           Removes a Service from the Halo API.
        .DESCRIPTION
            Deletes a specific Service from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Service ID
        [Parameter( Mandatory = $True )]
        [Alias('Service')]
        [int64]$ServiceID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloService -ServiceID $ServiceID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess(('Service ''{0}''' -f $ObjectToDelete.name), 'Delete')) {
                $Resource = ('api/Service/{0}' -f $ServiceID)
                $ServiceResults = New-HaloDELETERequest -Resource $Resource
                Return $ServiceResults
            }
        } else {
            Throw 'Service was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

function Remove-HaloClient {
    <#
        .SYNOPSIS
           Removes a client from the Halo API.
        .DESCRIPTION
            Deletes a specific client from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The client ID
        [Parameter( Mandatory = $True )]
        [Alias('Client')]
        [int64]$ClientID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloClient -ClientID $ClientID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Client '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/client/$($ClientID)"
                $ClientResults = New-HaloDELETERequest -Resource $Resource
                Return $ClientResults
            }
        } else {
            Throw 'Client was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
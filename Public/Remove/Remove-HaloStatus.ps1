function Remove-HaloStatus {
    <#
        .SYNOPSIS
           Removes a Status from the Halo API.
        .DESCRIPTION
            Deletes a specific Status from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Status ID
        [Parameter( Mandatory = $True )]
        [Alias('Status')]
        [int64]$StatusID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloStatus -StatusID $StatusID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Status '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/Status/$($StatusID)"
                $StatusResults = New-HaloDELETERequest -Resource $Resource
                Return $StatusResults
            }
        } else {
            Throw 'Status was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
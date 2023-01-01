function Remove-HaloUser {
    <#
        .SYNOPSIS
           Removes a user from the Halo API.
        .DESCRIPTION
            Deletes a specific user from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Ticket ID
        [Parameter( Mandatory = $True )]
        [Alias('User')]
        [int64]$UserId
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloUser -UserId $UserId
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("User '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/users/$($UserId)"
                $UserResults = New-HaloDELETERequest -Resource $Resource
                Return $UserResults
            }
        } else {
            Throw 'User was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
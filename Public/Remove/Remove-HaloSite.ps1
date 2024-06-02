function Remove-HaloSite {
    <#
        .SYNOPSIS
           Removes a Site from the Halo API.
        .DESCRIPTION
            Deletes a specific Site from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The Site ID
        [Parameter( Mandatory = $True )]
        [Alias('Site')]
        [int64]$SiteID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloSite -SiteID $SiteID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Site '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/Site/$($SiteID)"
                $SiteResults = New-HaloDELETERequest -Resource $Resource
                Return $SiteResults
            }
        } else {
            Throw 'Site was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
function Remove-HaloDashboard {
    <#
        .SYNOPSIS
           Removes a dashboard from the Halo API.
        .DESCRIPTION
            Deletes a specific dashboard from Halo.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The dashboard ID
        [Parameter( Mandatory = $True )]
        [Alias('Dashboard')]
        [int64]$DashboardID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloDashboard -DashboardID $DashboardID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Dashboard '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/DashboardLinks/$($DashboardID)"
                $DashboardResults = New-HaloDELETERequest -Resource $Resource
                Return $DashboardResults
            }
        } else {
            Throw 'Dashboard was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

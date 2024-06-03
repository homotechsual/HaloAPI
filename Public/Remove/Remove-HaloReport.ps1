function Remove-HaloReport {
    <#
        .SYNOPSIS
           Removes a report from the Halo API.
        .DESCRIPTION
            Deletes a specific report from Halo.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [cmdletbinding( SupportsShouldProcess = $True, ConfirmImpact = 'High' )]
    [OutputType([Object])]
    Param(
        # The report ID
        [Parameter( Mandatory = $True )]
        [Alias('Report')]
        [int64]$ReportID
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToDelete = Get-HaloReport -ReportID $ReportID
        if ($ObjectToDelete) {
            if ($PSCmdlet.ShouldProcess("Report '$($ObjectToDelete.name)')'", 'Delete')) {
                $Resource = "api/report/$($ReportID)"
                $ReportResults = New-HaloDELETERequest -Resource $Resource
                Return $ReportResults
            }
        } else {
            Throw 'Report was not found in Halo to delete.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
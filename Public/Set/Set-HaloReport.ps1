Function Set-HaloReport {
    <#
        .SYNOPSIS
            Updates one or more reports via the Halo API.
        .DESCRIPTION
            Function to send a report creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing report.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Report
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Report | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Report ID is required.'
            }
            $HaloReportParams = @{
                ReportId = $_.id
            }
            $ReportExists = Get-HaloReport @HaloReportParams
            if ($ReportExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Report -is [Array] ? 'Reports' : 'Report', 'Update')) {
                New-HaloPOSTRequest -Object $Report -Endpoint 'report'
            }
        } else {
            Throw 'One or more reports was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
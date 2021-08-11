Function Set-HaloReport {
    <#
        .SYNOPSIS
            Updates a report via the Halo API.
        .DESCRIPTION
            Function to send a report creation update to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing report.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Report
    )
    if ($PSCmdlet.ShouldProcess("Report", "Update")) {
        Invoke-HaloUpdate -Object $Report -Endpoint "report" -Update
    }
}
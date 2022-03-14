Function New-HaloReport {
    <#
        .SYNOPSIS
            Creates one or more reports via the Halo API.
        .DESCRIPTION
            Function to send a report creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new reports.
        [Parameter( Mandatory = $True )]
        [Object[]]$Report
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Reports -is [Array] ? 'Reports' : 'Report', 'Create')) {
            New-HaloPOSTRequest -Object $Report -Endpoint 'report'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
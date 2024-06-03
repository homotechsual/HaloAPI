function New-HaloDashboard {
    <#
        .SYNOPSIS
            Creates a dashboard via the Halo API.
        .DESCRIPTION
            Function to send a dashboard creation request to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new dashboard.
        [Parameter( Mandatory = $True )]
        [Object]$Dashboard
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Dashboard '$($Dashboard.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Dashboard -Endpoint 'DashboardLinks'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

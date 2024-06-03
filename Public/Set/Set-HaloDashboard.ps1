function Set-HaloDashboard {
    <#
        .SYNOPSIS
            Updates a dashboard via the Halo API.
        .DESCRIPTION
            Function to send a dashboard update request to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing dashboard.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Dashboard,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Dashboard.id) {
            throw 'Dashboard ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloDashboard -DashboardID $Dashboard.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Dashboard '$($Dashboard.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Dashboard -Endpoint 'DashboardLinks'
            }
        } else {
            Throw 'Dashboard was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

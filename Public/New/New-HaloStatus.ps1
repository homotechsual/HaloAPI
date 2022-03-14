Function New-HaloStatus {
    <#
        .SYNOPSIS
            Creates one or more statuses via the Halo API.
        .DESCRIPTION
            Function to send a status creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new statuses.
        [Parameter( Mandatory = $True )]
        [Object[]]$Status
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Status -is [Array] ? 'Statuses' : 'Status', 'Create')) {
            New-HaloPOSTRequest -Object $Status -Endpoint 'status'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
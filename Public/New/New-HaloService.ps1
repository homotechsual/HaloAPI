Function New-HaloService {
    <#
        .SYNOPSIS
            Creates one or more Service(s) via the Halo API.
        .DESCRIPTION
            Function to send a Service(s) creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new statuses.
        [Parameter( Mandatory = $True )]
        [Object[]]$Service
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Service -is [Array] ? 'Services' : 'Service', 'Create')) {
            New-HaloPOSTRequest -Object $Service -Endpoint 'Service'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
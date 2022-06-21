Function New-HaloTab {
    <#
        .SYNOPSIS
            Creates one or more Custom Field(s) via the Halo API.
        .DESCRIPTION
            Function to send a Custom Field(s) creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new statuses.
        [Parameter( Mandatory = $True )]
        [Object[]]$Tab
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Tab -is [Array] ? 'Tabs' : 'Tab', 'Create')) {
            New-HaloPOSTRequest -Object $Tab -Endpoint 'Tabs'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
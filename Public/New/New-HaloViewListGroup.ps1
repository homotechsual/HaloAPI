Function New-HaloViewListGroup {
    <#
        .SYNOPSIS
            Creates one or more viewlistgroups via the Halo API.
        .DESCRIPTION
            Function to send an viewlistgroup creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new viewlistgroups.
        [Parameter( Mandatory = $True )]
        [Object[]]$ViewListGroup
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($ViewListGroup -is [Array] ? 'ViewListGroups' : 'ViewListGroup', 'Create')) {
            New-HaloPOSTRequest -Object $ViewListGroup -Endpoint 'viewlistgroup'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
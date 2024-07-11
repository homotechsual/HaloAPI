Function New-HaloViewFilter {
    <#
        .SYNOPSIS
            Creates one or more viewfilters via the Halo API.
        .DESCRIPTION
            Function to send an viewfilter creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new viewfilters.
        [Parameter( Mandatory = $True )]
        [Object[]]$ViewFilter
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($ViewFilter -is [Array] ? 'ViewFilters' : 'ViewFilter', 'Create')) {
            New-HaloPOSTRequest -Object $ViewFilter -Endpoint 'viewfilter'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
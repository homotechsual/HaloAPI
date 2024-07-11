Function New-HaloViewList {
    <#
        .SYNOPSIS
            Creates one or more viewlists via the Halo API.
        .DESCRIPTION
            Function to send an viewlist creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new viewlists.
        [Parameter( Mandatory = $True )]
        [Object[]]$ViewList
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($ViewList -is [Array] ? 'ViewLists' : 'ViewList', 'Create')) {
            New-HaloPOSTRequest -Object $ViewList -Endpoint 'viewlists'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
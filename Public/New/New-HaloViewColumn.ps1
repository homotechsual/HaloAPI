Function New-HaloViewColumn {
    <#
        .SYNOPSIS
            Creates one or more viewcolumns via the Halo API.
        .DESCRIPTION
            Function to send an viewcolumn creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new viewcolumns.
        [Parameter( Mandatory = $True )]
        [Object[]]$ViewColumn
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($ViewColumn -is [Array] ? 'ViewColumns' : 'ViewColumn', 'Create')) {
            New-HaloPOSTRequest -Object $ViewColumn -Endpoint 'viewcolumns'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
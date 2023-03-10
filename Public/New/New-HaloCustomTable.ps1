Function New-HaloCustomTable {
    <#
        .SYNOPSIS
            Creates a custom table via the Halo API.
        .DESCRIPTION
            Function to send a custom table creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new custom table.
        [Parameter( Mandatory = $True )]
        [Object]$CustomTable
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Custom Table '$($CustomTable.ctname)'", 'Create')) {
            New-HaloPOSTRequest -Object $CustomTable -Endpoint 'customtable'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
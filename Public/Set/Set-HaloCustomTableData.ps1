function Set-HaloCustomTableData {
    <#
        .SYNOPSIS
            Updates custom table data via the Halo API.
        .DESCRIPTION
            Function to send a custom table data update request to the Halo API using the customtable endpoint.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    param (
        # Object or array of objects containing properties and values used to update custom table data records.
        # Use the Halo CustomTable payload shape (for example id with rows).
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$CustomTableData
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($CustomTableData -is [Array] ? 'Custom Table Data' : 'Custom Table Data', 'Update')) {
            New-HaloPOSTRequest -Object $CustomTableData -Endpoint 'customtable'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
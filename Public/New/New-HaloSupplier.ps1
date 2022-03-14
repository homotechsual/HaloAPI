Function New-HaloSupplier {
    <#
        .SYNOPSIS
            Creates one or more suppliers via the Halo API.
        .DESCRIPTION
            Function to send a supplier creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new suppliers.
        [Parameter( Mandatory = $True )]
        [Object[]]$Supplier
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Supplier -is [Array] ? 'Suppliers' : 'Supplier', 'Create')) {
            New-HaloPOSTRequest -Object $Supplier -Endpoint 'supplier'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
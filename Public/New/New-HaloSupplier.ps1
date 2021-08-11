Function New-HaloSupplier {
    <#
        .SYNOPSIS
            Creates a supplier via the Halo API.
        .DESCRIPTION
            Function to send a supplier creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to create a new supplier.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Supplier
    )
    if ($PSCmdlet.ShouldProcess("Supplier", "Create")) {
        Invoke-HaloUpdate -Object $Supplier -Endpoint "supplier"
    }
}
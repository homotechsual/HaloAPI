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
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new supplier.
        [Parameter( Mandatory = $True )]
        [Object]$Supplier
    )
    try {
        if ($PSCmdlet.ShouldProcess("Supplier '$($Supplier.name)'", "Create")) {
            New-HaloPOSTRequest -Object $Supplier -Endpoint "supplier"
        }
    } catch {
        Write-Error "Failed to create supplier with the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}
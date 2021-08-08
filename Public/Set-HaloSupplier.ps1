Function Set-HaloSupplier {
    <#
    .SYNOPSIS
        Updates a Supplier via the Halo API.
    .DESCRIPTION
        Function to send a Supplier update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Supplier
    )
    Invoke-HaloUpdate -Object $Supplier -Endpoint "Supplier" -update
}
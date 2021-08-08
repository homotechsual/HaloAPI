Function New-HaloSupplier {
    <#
    .SYNOPSIS
        Creates a Supplier via the Halo API.
    .DESCRIPTION
        Function to send a Supplier creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Supplier
    )
    Invoke-HaloUpdate -Object $Supplier -Endpoint "Supplier"
}
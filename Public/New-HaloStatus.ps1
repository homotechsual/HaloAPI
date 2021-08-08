Function New-HaloStatus {
    <#
    .SYNOPSIS
        Creates a Status via the Halo API.
    .DESCRIPTION
        Function to send a Status creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Status
    )
    Invoke-HaloUpdate -Object $Status -Endpoint "Status"
}
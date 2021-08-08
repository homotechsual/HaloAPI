Function New-HaloAction {
    <#
    .SYNOPSIS
        Creates a action via the Halo API.
    .DESCRIPTION
        Function to send a action creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Action
    )
    Invoke-HaloUpdate -Object $Action -Endpoint "Actions"
}
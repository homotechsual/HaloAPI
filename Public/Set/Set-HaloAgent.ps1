Function Set-HaloAgent {
    <#
    .SYNOPSIS
        Updates an agent via the Halo API.
    .DESCRIPTION
        Function to send an agent update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Agent
    )
    Invoke-HaloUpdate -Object $Agent -Endpoint "agent" -Update
}
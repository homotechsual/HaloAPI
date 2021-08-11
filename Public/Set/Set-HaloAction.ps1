Function Set-HaloAction {
    <#
    .SYNOPSIS
        Updates an action via the Halo API.
    .DESCRIPTION
        Function to send a action update request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to update an existing action.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Action
    )
    Invoke-HaloUpdate -Object $Action -Endpoint "actions" -Update
}
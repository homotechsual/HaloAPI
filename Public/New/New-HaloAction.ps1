Function New-HaloAction {
    <#
    .SYNOPSIS
        Creates an action via the Halo API.
    .DESCRIPTION
        Function to send an action creation request to the Halo API
    .OUTPUTS
        Outputs an object containing the response from the web request.
    #>
    [CmdletBinding()]
    Param (
        # Object containing properties and values used to create a new action.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Action
    )
    Invoke-HaloUpdate -Object $Action -Endpoint "actions"
}
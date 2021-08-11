Function Set-HaloAction {
    <#
        .SYNOPSIS
            Updates an action via the Halo API.
        .DESCRIPTION
            Function to send a action update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing action.
        [Parameter( Mandatory = $True )]
        [PSCustomObject]$Action
    )
    if ($PSCmdlet.ShouldProcess("Action", "Update")) {
        Invoke-HaloUpdate -Object $Action -Endpoint "actions" -Update
    }
}
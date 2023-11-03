#Requires -Version 7
Function New-HaloOutcome {
    <#
        .SYNOPSIS
            Creates one or more outcomes via the Halo API.
        .DESCRIPTION
            Function to send a outcome creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new outcomes.
        [Parameter( Mandatory = $True )]
        [Object[]]$Outcome
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Outcome -is [Array] ? 'Outcomes' : 'Outcome', 'Create')) {
            New-HaloPOSTRequest -Object $Outcome -Endpoint 'Outcome'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

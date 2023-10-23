# New-HaloOutcome.ps1
Function New-HaloOutcome {
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
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

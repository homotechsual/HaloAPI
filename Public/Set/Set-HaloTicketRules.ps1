Function Set-HaloTicketRules {
    <#
        .SYNOPSIS
            Updates a Rule via the Halo API.
        .DESCRIPTION
            Function to send an Rule update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing knowedgebase article.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Rule,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Rule.id) {
            throw 'Rule ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloTicketRules -RuleID $Rule.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Rule List', 'Update')) {
                New-HaloPOSTRequest -Object $Rule -Endpoint 'TicketRules'
            }
        } else {
            Throw 'Rule was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

Function Set-HaloOpportunity {
    <#
        .SYNOPSIS
            Updates one or more opportunities via the Halo API.
        .DESCRIPTION
            Function to send an opportunity update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing opportunities.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Opportunity,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Opportunity | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Opportunity ID is required.'
            }
            $HaloOpportunityParams = @{
                OpportunityId = $_.id
            }
            if (-not $SkipValidation) {
                $OpportunityExists = Get-HaloOpportunity @HaloOpportunityParams
                if ($OpportunityExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Opportunity -is [Array] ? 'Opportunities' : 'Opportunity', 'Update')) {
                New-HaloPOSTRequest -Object $Opportunity -Endpoint 'opportunities'
            }
        } else {
            Throw 'One or more opportunities was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
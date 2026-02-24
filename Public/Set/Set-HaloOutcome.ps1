#Requires -Version 7
function Set-HaloOutcome {
    <#
    .SYNOPSIS
        Updates one or more outcomes via the Halo API.

    .DESCRIPTION
        Function to send an outcome update request to the Halo API. This function validates the existence
        of outcomes before attempting to update them, unless validation is explicitly skipped.

    .PARAMETER Outcome
        Object or array of objects containing properties and values used to update one or more existing outcomes.
        Each object must contain an 'id' property.

    .PARAMETER SkipValidation
        Switch parameter to skip validation checks for outcome existence before updating.

    .OUTPUTS
        Outputs an object containing the response from the web request.

    .EXAMPLE
        $outcome = @{
            id = 123
            buttonname = "New Button Name"
            outcome = "New Outcome Text"
        }
        Set-HaloOutcome -Outcome $outcome

    .EXAMPLE
        $outcomes = @(
            @{
                id = 123
                buttonname = "First Button"
            },
            @{
                id = 456
                buttonname = "Second Button"
            }
        )
        Set-HaloOutcome -Outcome $outcomes -SkipValidation

    .NOTES
        Requires PowerShell 7.0 or higher
        The function performs validation by default to ensure outcomes exist before attempting updates
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing outcomes
        [Parameter(Mandatory = $True, ValueFromPipeline)]
        [Object[]]$Outcome,

        # Skip validation checks
        [Parameter()]
        [Switch]$SkipValidation
    )

    begin {
        Invoke-HaloPreFlightCheck
    }

    process {
        try {
            $ObjectToUpdate = $Outcome | ForEach-Object {
                if ($null -eq $_.id) {
                    throw 'Outcome ID is required.'
                }

                if (-not $SkipValidation) {
                    $OutcomeParams = @{
                        OutcomeID = $_.id
                    }
                    $OutcomeExists = Get-HaloOutcome @OutcomeParams
                    if ($OutcomeExists) {
                        Return $True
                    } else {
                        Return $False
                    }
                } else {
                    Write-Verbose 'Skipping validation checks'
                    Return $True
                }
            }

            if ($False -notin $ObjectToUpdate) {
                if ($PSCmdlet.ShouldProcess($Outcome -is [Array] ? 'Outcomes' : 'Outcome', 'Update')) {
                    New-HaloPOSTRequest -Object $Outcome -Endpoint 'Outcome'
                }
            } else {
                throw 'One or more outcomes was not found in Halo to update.'
            }
        } catch {
            New-HaloError -ErrorRecord $_
        }
    }
}

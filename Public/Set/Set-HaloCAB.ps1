Function Set-HaloCAB {
    <#
        .SYNOPSIS
            Updates one or more CABs (change approval boards) via the Halo API.
        .DESCRIPTION
            Function to send a change approval board update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing CABs.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$CAB,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $CAB | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'CAB ID is required.'
            }
            $HaloCABParams = @{
                CABID = ($_.id)
            }
            if (-not $SkipValidation) {
                $CABExists = Get-HaloCAB @HaloCABParams
                if ($CABExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectsToUpdate) {
            if ($PSCmdlet.ShouldProcess($CAB -is [Array] ? 'CABs' : 'CAB', 'Update')) {
                New-HaloPOSTRequest -Object $CAB -Endpoint 'cab'
            }
        } else {
            Throw 'One or more CABs was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function Set-HaloDistributionList {
    <#
        .SYNOPSIS
            Updates one or more distribution lists via the Halo API.
        .DESCRIPTION
            Function to send a distribution list update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing distribution lists.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$DistributionList,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $DistributionList | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Distribution List ID is required.'
            }
            $HaloDistributionListParams = @{
                DistributionListId = $_.id
            }
            if (-not $SkipValidation) {
                $DistributionListExists = Get-HaloDistributionList @HaloDistributionListParams
                if ($DistributionListExists) {
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
            if ($PSCmdlet.ShouldProcess($DistributionList -is [Array] ? 'Distribution Lists' : 'Distribution List', 'Update')) {
                $Results = New-HaloPOSTRequest -Object $DistributionList -Endpoint 'distributionlist'
                Return $Results
            }
        } else {
            Throw 'One or more distribution lists were not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

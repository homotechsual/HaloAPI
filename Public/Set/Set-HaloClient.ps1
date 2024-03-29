Function Set-HaloClient {
    <#
        .SYNOPSIS
            Updates one or more clients via the Halo API.
        .DESCRIPTION
            Function to send a client update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #> 
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing clients.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Client,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Client | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Client ID is required.'
            }
            $HaloClientParams = @{
                ClientId = ($_.id)
            }
            if (-not $SkipValidation) {
                $ClientExists = Get-HaloClient @HaloClientParams
                if ($ClientExists) {
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
            if ($PSCmdlet.ShouldProcess($Client -is [Array] ? 'Clients' : 'Client', 'Update')) {
                New-HaloPOSTRequest -Object $Client -Endpoint 'client'
            }
        } else {
            Throw 'One or more clients was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
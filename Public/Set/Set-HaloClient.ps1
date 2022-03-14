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
        [Object[]]$Client
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Client {
            $HaloClientParams = @{
                ClientId = $_.id
            }
            $ClientExists = Get-HaloClient @HaloClientParams
            if ($ClientExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) { 
            if ($PSCmdlet.ShouldProcess($Client -is [Array] ? 'Clients' : 'Client', 'Update')) {
                New-HaloPOSTRequest -Object $Client -Endpoint 'client' -Update
            }
        } else {
            Throw 'One or more clients was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function Set-HaloSoftwareLicence {
    <#
        .SYNOPSIS
            Updates one or more software Licences via the Halo API.
        .DESCRIPTION
            Function to send a software Licence update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing statuses.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$SoftwareLicence
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $SoftwareLicence | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Software license ID is required.'
            }
            $HaloSoftwareLicenceParams = @{
                SoftwareLicence = $_.id
            }
            $SoftwareLicenceExists = Get-HaloSoftwareLicence @HaloSoftwareLicenceParams
            if ($SoftwareLicenceExists) {
                Return $True
            } else {
                Return $False
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($SoftwareLicence -is [Array] ? 'Statuses' : 'Status', 'Update')) {
                New-HaloPOSTRequest -Object $SoftwareLicence -Endpoint 'SoftwareLicence'
            }
        } else {
            Throw 'One or more Software Licence was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function New-HaloSoftwareLicence {
    <#
        .SYNOPSIS
            Creates one or more Software Licences via the Halo API.
        .DESCRIPTION
            Function to send a Software Licence creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new statuses.
        [Parameter( Mandatory = $True )]
        [Object[]]$SoftwareLicence
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($SoftwareLicence -is [Array] ? 'Statuses' : 'Status', 'Create')) {
            New-HaloPOSTRequest -Object $SoftwareLicence -Endpoint 'SoftwareLicence'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
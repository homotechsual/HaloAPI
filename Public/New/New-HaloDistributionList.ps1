Function New-HaloDistributionList {
    <#
        .SYNOPSIS
            Creates one or more distribution lists via the Halo API.
        .DESCRIPTION
            Function to send a distribution list creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new distribution lists.
        [Parameter( Mandatory = $True )]
        [Object[]]$DistributionList
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($DistributionList -is [Array] ? 'Distribution Lists' : 'Distribution List', 'Create')) {
            $Results = New-HaloPOSTRequest -Object $DistributionList -Endpoint 'distributionlist'
            Return $Results
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

Function New-HaloTemplate {
    <#
        .SYNOPSIS
            Creates one or more templates via the Halo API.
        .DESCRIPTION
            Function to send a template creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new templates.
        [Parameter( Mandatory = $True )]
        [Object[]]$Template
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess($Template -is [Array] ? 'Templates' : 'Template', 'Create')) {
            $Results = New-HaloPOSTRequest -Object $Template -Endpoint 'template'
            Return $Results
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

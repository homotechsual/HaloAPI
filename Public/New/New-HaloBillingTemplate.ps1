Function New-HaloBillingTemplate {
    <#
        .SYNOPSIS
            Creates a billing template via the Halo API.
        .DESCRIPTION
            Function to send a billing template creation request to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new billing template.
        [Parameter( Mandatory = $True )]
        [Object]$Template
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Billing Template '$($Template.name)", 'Create')) {
            New-HaloPOSTRequest -Object $Template -Endpoint 'billingtemplate'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
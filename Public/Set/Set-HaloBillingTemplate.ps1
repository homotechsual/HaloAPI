Function Set-HaloBillingTemplate {
    <#
        .SYNOPSIS
            Updates a billing template via the Halo API.
        .DESCRIPTION
            Function to send an billing template update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing billing template.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Template
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Template.id) {
            throw 'Billing template ID is required.'
        }
        $ObjectToUpdate = Get-HaloBillingTemplate -TemplateID $Template.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Billing Template '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Template -Endpoint 'billingtemplate'
            }
        } else {
            Throw 'Billing Template was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
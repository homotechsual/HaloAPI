Function New-HaloScheduleTemplate {
    <#
        .SYNOPSIS
            Creates a schedule template via the Halo API.
        .DESCRIPTION
            Function to send a schedule template creation request to the Halo API.
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new schedule template.
        [Parameter( Mandatory = $True )]
        [Object]$Template
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Schedule Template '$($Template.name)", 'Create')) {
            New-HaloPOSTRequest -Object $Template -Endpoint 'Template'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

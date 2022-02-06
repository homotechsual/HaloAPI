Function New-HaloCRMNote {
    <#
        .SYNOPSIS
            Creates a CRM note via the Halo API.
        .DESCRIPTION
            Function to send a CRM note creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new CRM note.
        [Parameter( Mandatory = $True )]
        [Object]$CRMNote
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("CRM Note by '$($CRMNote.who_agentid)'", 'Create')) {
            New-HaloPOSTRequest -Object $CRMNote -Endpoint 'crmnote'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
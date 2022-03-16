Function Set-HaloCRMNote {
    <#
        .SYNOPSIS
            Updates a CRM note via the Halo API.
        .DESCRIPTION
            Function to send a CRM note update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([PSCustomObject])]
    Param (
        # Object containing properties and values used to update an existing CRM note.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [PSCustomObject]$CRMNote
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $CRMNote.id) {
            throw 'CRM note ID is required.'
        }
        if ($null -eq $CRMNote.client_id) {
            throw 'Client ID is required.'
        }
        $HaloCRMNoteParams = @{
            CRMNoteID = $CRMNote.id
            ClientID = [int]$CRMNote.client_id
        }
        $ObjectToUpdate = Get-HaloCRMNote @HaloCRMNoteParams
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("CRM Note $($ObjectToUpdate.id) by $($ObjectToUpdate.who_agentid)", 'Update')) {
                New-HaloPOSTRequest -Object $CRMNote -Endpoint 'crmnote'
            }
        } else {
            Throw 'CRM Note was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
Function Set-HaloStatus {
    <#
        .SYNOPSIS
            Updates a status via the Halo API.
        .DESCRIPTION
            Function to send a status update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing status.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Status
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloStatus -StatusID $Status.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Status '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Status -Endpoint 'status' -Update
            }
        } else {
            Throw 'Status was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
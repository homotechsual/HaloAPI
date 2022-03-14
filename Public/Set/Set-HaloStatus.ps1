Function Set-HaloStatus {
    <#
        .SYNOPSIS
            Updates one or more statuses via the Halo API.
        .DESCRIPTION
            Function to send a status update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing statuses.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Status
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloStatus -StatusID $Status.id
        $ObjectToUpdate = $False
        ForEach-Object -InputObject $Status {
            $HaloStatusParams = @{
                StatusId = $_.id
            }
            $StatusExists = Get-HaloStatus @HaloStatusParams
            if ($StatusExists) {
                Set-Variable -Scope 1 -Name 'ObjectToUpdate' -Value $True
            }
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Status -is [Array] ? 'Statuses' : 'Status', 'Update')) {
                New-HaloPOSTRequest -Object $Status -Endpoint 'status' -Update
            }
        } else {
            Throw 'One or more status was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
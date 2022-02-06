Function Set-HaloWorkday {
    <#
        .SYNOPSIS
            Updates a workday via the Halo API.
        .DESCRIPTION
            Function to send a workday update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing item.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Workday
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = Get-HaloWorkday -WorkdayID $Workday.id
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess("Workday '$($ObjectToUpdate.name)'", 'Update')) {
                New-HaloPOSTRequest -Object $Workday -Endpoint 'workday' -Update
            }
        } else {
            Throw 'Workday was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
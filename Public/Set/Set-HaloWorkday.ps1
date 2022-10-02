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
        [Object]$Workday,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Workday.id) {
            throw 'Workday ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloWorkday -WorkdayID $Workday.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Workday', 'Update')) {
                New-HaloPOSTRequest -Object $Workday -Endpoint 'workday'
            }
        } else {
            Throw 'Workday was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
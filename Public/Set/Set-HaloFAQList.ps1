Function Set-HaloFAQList {
    <#
        .SYNOPSIS
            Updates a FAQ List via the Halo API.
        .DESCRIPTION
            Function to send an FAQ List update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing knowedgebase article.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$FAQList,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $FAQList.id) {
            throw 'FAQ list ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloFAQList -FAQListID $FAQList.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('FAQ List', 'Update')) {
                New-HaloPOSTRequest -Object $FAQList -Endpoint 'FAQLists'
            }
        } else {
            Throw 'FAQ List was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
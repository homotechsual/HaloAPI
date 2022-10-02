Function Set-HaloCategory {
    <#
        .SYNOPSIS
            Updates a Category via the Halo API.
        .DESCRIPTION
            Function to send an Category update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to update an existing knowedgebase article.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object]$Category,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($null -eq $Category.id) {
            throw 'Category ID is required.'
        }
        if (-not $SkipValidation) {
            $ObjectToUpdate = Get-HaloCategory -CategoryID $Category.id
        } else {
            Write-Verbose 'Skipping validation checks.'
            $ObjectToUpdate = $True
        }
        if ($ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess('Category List', 'Update')) {
                New-HaloPOSTRequest -Object $Category -Endpoint 'Category'
            }
        } else {
            Throw 'Category was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
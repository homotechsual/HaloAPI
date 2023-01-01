Function Set-HaloItem {
    <#
        .SYNOPSIS
            Updates one or more items via the Halo API.
        .DESCRIPTION
            Function to send an item update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing items.
        [Parameter( Mandatory = $True, ValueFromPipeline )]
        [Object[]]$Item,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectToUpdate = $Item | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'Item ID is required.'
            }
            $HaloItemParams = @{
                ItemId = $_.id
            }
            if (-not $SkipValidation) {
                $ItemExists = Get-HaloItem @HaloItemParams
                if ($ItemExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks'
                Return $True
            }
        }
        if ($False -notin $ObjectToUpdate) {
            if ($PSCmdlet.ShouldProcess($Item -is [Array] ? 'Items' : 'Item', 'Update')) {
                New-HaloPOSTRequest -Object $Item -Endpoint 'item'
            }
        } else {
            Throw 'One or more items was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
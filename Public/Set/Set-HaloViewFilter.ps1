Function Set-HaloViewFilter {
    <#
        .SYNOPSIS
            Updates one or more viewfilters via the Halo API.
        .DESCRIPTION
            Function to send a viewfilter update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing viewfilters.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$ViewFilter,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $ViewFilter | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'ViewFilter ID is required.'
            }
            $HaloViewFilterParams = @{
                ViewFilterID = ($_.id)
                TicketID = ($_.ticket_id)
            }
            if (-not $SkipValidation) {
                $ViewFilterExists = Get-HaloViewFilter @HaloViewFilterParams
                if ($ViewFilterExists) {
                    Return $True
                } else {
                    Return $False
                }
            } else {
                Write-Verbose 'Skipping validation checks.'
                Return $True
            }
        }
        if ($False -notin $ObjectsToUpdate) {
            if ($PSCmdlet.ShouldProcess($ViewFilter -is [Array] ? 'ViewFilters' : 'ViewFilter', 'Update')) {
                New-HaloPOSTRequest -Object $ViewFilter -Endpoint 'viewfilter'
            }
        } else {
            Throw 'One or more viewfilters was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
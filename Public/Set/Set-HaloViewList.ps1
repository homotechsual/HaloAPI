Function Set-HaloViewList {
    <#
        .SYNOPSIS
            Updates one or more viewlists via the Halo API.
        .DESCRIPTION
            Function to send a viewlist update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing viewlists.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$ViewList,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $ViewList | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'ViewList ID is required.'
            }
            $HaloViewListParams = @{
                ViewListID = ($_.id)
                TicketID = ($_.ticket_id)
            }
            if (-not $SkipValidation) {
                $ViewListExists = Get-HaloViewList @HaloViewListParams
                if ($ViewListExists) {
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
            if ($PSCmdlet.ShouldProcess($ViewList -is [Array] ? 'ViewLists' : 'ViewList', 'Update')) {
                New-HaloPOSTRequest -Object $ViewList -Endpoint 'viewlists'
            }
        } else {
            Throw 'One or more viewlists was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
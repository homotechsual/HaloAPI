Function Set-HaloViewListGroup {
    <#
        .SYNOPSIS
            Updates one or more viewlistgroups via the Halo API.
        .DESCRIPTION
            Function to send a viewlistgroup update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing viewlistgroups.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$ViewListGroup,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $ViewListGroup | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'ViewListGroup ID is required.'
            }
            $HaloViewListGroupParams = @{
                ViewListGroupID = ($_.id)
                TicketID = ($_.ticket_id)
            }
            if (-not $SkipValidation) {
                $ViewListGroupExists = Get-HaloViewListGroup @HaloViewListGroupParams
                if ($ViewListGroupExists) {
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
            if ($PSCmdlet.ShouldProcess($ViewListGroup -is [Array] ? 'ViewListGroups' : 'ViewListGroup', 'Update')) {
                New-HaloPOSTRequest -Object $ViewListGroup -Endpoint 'viewlistgroup'
            }
        } else {
            Throw 'One or more viewlistgroups was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
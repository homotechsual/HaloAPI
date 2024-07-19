Function Set-HaloViewColumn {
    <#
        .SYNOPSIS
            Updates one or more viewcolumns via the Halo API.
        .DESCRIPTION
            Function to send a viewcolumn update request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to update one or more existing viewcolumns.
        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [Object[]]$ViewColumn,
        # Skip validation checks.
        [Parameter()]
        [Switch]$SkipValidation
    )
    Invoke-HaloPreFlightCheck
    try {
        $ObjectsToUpdate = $ViewColumn | ForEach-Object {
            if ($null -eq $_.id) {
                throw 'ViewColumn ID is required.'
            }
            $HaloViewColumnParams = @{
                ViewColumnID = ($_.id)
                TicketID = ($_.ticket_id)
            }
            if (-not $SkipValidation) {
                $ViewColumnExists = Get-HaloViewColumn @HaloViewColumnParams
                if ($ViewColumnExists) {
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
            if ($PSCmdlet.ShouldProcess($ViewColumn -is [Array] ? 'ViewColumns' : 'ViewColumn', 'Update')) {
                New-HaloPOSTRequest -Object $ViewColumn -Endpoint 'viewcolumns'
            }
        } else {
            Throw 'One or more viewcolumns was not found in Halo to update.'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
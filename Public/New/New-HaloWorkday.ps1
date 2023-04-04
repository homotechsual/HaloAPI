Function New-HaloWorkday {
    <#
        .SYNOPSIS
            Creates an Workday via the Halo API.
        .DESCRIPTION
            Function to send an Workday creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object])]
    Param (
        # Object containing properties and values used to create a new item.
        [Parameter( Mandatory = $True )]
        [Object]$Workday
    )
    Invoke-HaloPreFlightCheck
    try {
        if ($PSCmdlet.ShouldProcess("Workday '$($Workday.name)'", 'Create')) {
            New-HaloPOSTRequest -Object $Workday -Endpoint 'workday'
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
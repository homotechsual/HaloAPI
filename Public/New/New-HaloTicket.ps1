Function New-HaloTicket {
    <#
        .SYNOPSIS
            Creates one or more tickets via the Halo API.
        .DESCRIPTION
            Function to send a ticket creation request to the Halo API
        .OUTPUTS
            Outputs an object containing the response from the web request.
    #>
    [CmdletBinding( SupportsShouldProcess = $True )]
    [OutputType([Object[]])]
    Param (
        # Object or array of objects containing properties and values used to create one or more new tickets.
        [Parameter( Mandatory = $True )]
        [Object[]]$Ticket,
        # Return all results when letting Halo batch process.
        [Parameter()]
        [Switch]$ReturnAll
    )
    Invoke-HaloPreFlightCheck
    try {
        $CommandName = $MyInvocation.MyCommand.Name
        Write-Verbose "Running command '$CommandName'"
        $Parameters = (Get-Command -Name $CommandName).Parameters
        # Workaround to prevent the query string processor from adding an 'actionid=' parameter by removing it from the set parameters.
        if ($ActionID) {
            $Parameters.Remove('Ticket') | Out-Null
        }
        $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
        if ($PSCmdlet.ShouldProcess($Ticket -is [Array] ? 'Tickets' : 'Ticket', 'Create')) {
            $PostRequestParams = @{
                Object = $Ticket
                Endpoint = 'tickets'
            }
            if ($QSCollection) {
                $PostRequestParams.QSCollection = $QSCollection
            }
            New-HaloPOSTRequest @PostRequestParams
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
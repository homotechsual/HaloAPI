#Requires -Version 7
function Get-HaloControl {
    <#
        .SYNOPSIS
            Gets control information from the Halo API.
        .DESCRIPTION
            Retrieves control information from the Halo API.
        .OUTPUTS
            A PowerShell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    Param()

    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName

    try {
        Write-Verbose 'Fetching control information from the Halo API.'
        $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters @{}
        $Resource = 'api/control'
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            AutoPaginateOff = $True
            QSCollection = $QSCollection
            ResourceType = 'control'
        }

        $ControlResults = New-HaloGETRequest @RequestParams
        Return $ControlResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}

Function Set-HaloClient { 
    [CmdletBinding()]
    Param (
        [PSCustomObject]$Client
    )
    New-HaloClient -Update -Client $Client 
}
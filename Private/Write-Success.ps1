using namespace System.Management.Automation
#Requires -Version 7
function Write-Success {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Message
    )
    $MessageData = [HostInformationMessage]@{
        Message = $Message
        ForegroundColor = 'Green'
    }
    Write-Information -MessageData $MessageData -InformationAction Continue
}
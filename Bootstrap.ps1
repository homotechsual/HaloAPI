using namespace Microsoft.PowerShell.Commands
[CmdletBinding()]
param(
    # Set installation scope for required modules.
    [ValidateSet('CurrentUser', 'AllUsers')]
    $Scope = 'CurrentUser'
)
$requiredModuleData = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName RequiredModules

if ($requiredModuleData -is [hashtable]) {
    [ModuleSpecification[]]$RequiredModules = foreach ($moduleName in ($requiredModuleData.Keys | Sort-Object)) {
        @{
            ModuleName = $moduleName
            RequiredVersion = [string]$requiredModuleData[$moduleName]
        }
    }
} else {
    [ModuleSpecification[]]$RequiredModules = $requiredModuleData
}

$Policy = (Get-PSRepository PSGallery).InstallationPolicy
Set-PSRepository PSGallery -InstallationPolicy Trusted
try {
    $RequiredModules | Install-Module -Scope $Scope -Repository PSGallery -SkipPublisherCheck -Verbose
} finally {
    Set-PSRepository PSGallery -InstallationPolicy $Policy
}
$RequiredModules | Import-Module
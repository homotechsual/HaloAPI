[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TagName,

    [string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\..\HaloAPI.psd1')
)

# Guards against a stale PrivateData.PSData.Prerelease value being carried over between releases (e.g. 1.24.0-beta1 -> 1.25.0).
$ErrorActionPreference = 'Stop'

$ManifestPath = (Resolve-Path -Path $ManifestPath).Path
$manifest = Import-PowerShellDataFile -Path $ManifestPath
$manifestPrerelease = $manifest.PrivateData.PSData.Prerelease

$versionFromTag = $TagName.TrimStart('v')
$tagPrerelease = $null
if ($versionFromTag -match '-(?<suffix>(alpha|beta|rc)\d*)$') {
    $tagPrerelease = $Matches['suffix']
}

if ($tagPrerelease) {
    if ($manifestPrerelease -ne $tagPrerelease) {
        throw ('Tag ''{0}'' indicates prerelease ''{1}'' but HaloAPI.psd1 PrivateData.PSData.Prerelease is ''{2}''. Update the manifest to match before tagging.' -f $TagName, $tagPrerelease, $manifestPrerelease)
    }
    Write-Host ('Tag prerelease ''{0}'' matches manifest Prerelease value.' -f $tagPrerelease)
} elseif (-not [string]::IsNullOrWhiteSpace($manifestPrerelease)) {
    throw ('Tag ''{0}'' is a stable tag but HaloAPI.psd1 PrivateData.PSData.Prerelease is still set to ''{1}''. Clear Prerelease in the manifest before tagging a stable release.' -f $TagName, $manifestPrerelease)
} else {
    Write-Host 'Stable tag confirmed: manifest has no lingering Prerelease value.'
}

[CmdletBinding()]
param(
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser'
)

$BuildToolsRoot = $PSScriptRoot
$RepoRoot = Resolve-Path -Path (Join-Path -Path $BuildToolsRoot -ChildPath '..\..')

$ErrorActionPreference = 'Stop'

& (Join-Path -Path $RepoRoot -ChildPath 'Bootstrap.ps1') -Scope $Scope
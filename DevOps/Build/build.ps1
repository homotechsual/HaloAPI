# requires -Version 7.0
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleSyntax', '', Justification = 'Script runs in CI/CD pipelines and targets PowerShell 7.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSMissingParameterInlineComment', '', Justification = 'Internal DevOps script does not require parameter descriptions.')]
param(
    [string[]]$TaskNames = ('clean', 'build', 'updateHelp', 'publishDocs')
)

$BuildToolsRoot = $PSScriptRoot
$RepoRoot = (Resolve-Path -Path (Join-Path -Path $BuildToolsRoot -ChildPath '..\..')).Path
$Script:ModuleName = 'HaloAPI'
$Script:LegacyBuildScriptPath = Join-Path -Path $RepoRoot -ChildPath 'HaloAPI.build.ps1'
$Script:DocsSourcePath = Join-Path -Path $RepoRoot -ChildPath 'docs\HaloAPI\commandlets'

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function WriteMessage {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Script is not intended to be used as a module.')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,
        [ValidateSet('Information', 'Warning', 'Error', 'Success')]
        [string]$Category = 'Information',
        [string]$Details
    )

    process {
        $params = @{
            Object = ('{0}: {1}' -f $Message, $Details).TrimEnd(' :')
            ForegroundColor = switch ($Category) {
                'Success' { 'Green' }
                'Information' { 'Cyan' }
                'Warning' { 'Yellow' }
                'Error' { 'Red' }
            }
        }
        Write-Host @params
    }
}

function Invoke-LegacyBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$ArgumentList
    )

    & $Script:LegacyBuildScriptPath @ArgumentList
}

function Push {
    Invoke-LegacyBuild -ArgumentList @('-Push')
}

function Build {
    Invoke-LegacyBuild -ArgumentList @('-CopyModuleFiles', '-Configuration', 'Production')
}

function UpdateManifest {
    Invoke-LegacyBuild -ArgumentList @('-UpdateManifest')
}

function Publish {
    Invoke-LegacyBuild -ArgumentList @('-PublishModule', '-Configuration', 'Production')
}

function UpdateHelp {
    [CmdletBinding()]
    param(
        [string]$DocusaurusPath = $RepoRoot,
        [bool]$ForceUpdateCategoryFiles = $true
    )

    & $Script:LegacyBuildScriptPath `
        -UpdateHelp `
        -DocusaurusPath $DocusaurusPath `
        -ForceUpdateCategoryFiles:$ForceUpdateCategoryFiles
}

function PublishDocs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DocsOutputPath
    )

    if (-not $DocsOutputPath) {
        $DocsOutputPath = Join-Path -Path $RepoRoot -ChildPath '.build\docs'
    }

    if (-not (Test-Path -Path $Script:DocsSourcePath -PathType Container)) {
        throw ('Generated commandlet docs path not found: {0}' -f $Script:DocsSourcePath)
    }

    $destinationPath = Join-Path -Path $DocsOutputPath -ChildPath 'docs\haloapi\commandlets'
    if (Test-Path -Path $destinationPath) {
        Remove-Item -Path $destinationPath -Recurse -Force
    }

    New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
    Copy-Item -Path (Join-Path -Path $Script:DocsSourcePath -ChildPath '*') -Destination $destinationPath -Recurse -Force

    WriteMessage -Message 'Docs exported to output directory' -Details $destinationPath -Category Success
}

function Clean {
    Invoke-LegacyBuild -ArgumentList @('-Clean')

    $buildArtifactsPath = Join-Path -Path $RepoRoot -ChildPath '.build'
    if (Test-Path -Path $buildArtifactsPath) {
        Remove-Item -Path $buildArtifactsPath -Recurse -Force
    }
}

function InvokeTask {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Script is not intended to be used as a module.')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TaskName
    )

    begin {
        WriteMessage -Message ('Build {0}' -f $PSCommandPath) -Category Success
    }

    process {
        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            WriteMessage -Message ('Task {0}' -f $TaskName)
            & ('Script:{0}' -f $TaskName)
            WriteMessage -Message ('Done {0} {1}' -f $TaskName, $stopWatch.Elapsed)
        } catch {
            WriteMessage -Message ('Failed {0} [{1}]' -f $TaskName, $stopWatch.Elapsed) -Category Error -Details $_.Exception.Message
            exit 1
        } finally {
            $stopWatch.Stop()
        }
    }
}

$allowedTaskNames = @('clean', 'build', 'updateManifest', 'publish', 'publishDocs', 'updateHelp', 'push')
$normalizedTaskNames = foreach ($taskName in $TaskNames) {
    if ([string]::IsNullOrWhiteSpace($taskName)) {
        continue
    }

    $taskName -split ',' | ForEach-Object {
        $_.Trim()
    } | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }
}

foreach ($taskName in $normalizedTaskNames) {
    if ($allowedTaskNames -notcontains $taskName) {
        throw ('Unsupported task name: {0}. Allowed values: {1}' -f $taskName, ($allowedTaskNames -join ', '))
    }
}

$normalizedTaskNames | InvokeTask
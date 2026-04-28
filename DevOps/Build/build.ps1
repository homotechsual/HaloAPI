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

function Ensure-RequiredModules {
    [CmdletBinding()]
    param()

    $requiredModulesPath = Join-Path -Path $RepoRoot -ChildPath 'RequiredModules.psd1'
    [hashtable]$requiredModules = Import-PowerShellDataFile -Path $requiredModulesPath

    $missingModules = foreach ($requiredModule in $requiredModules.GetEnumerator()) {
        $module = Get-Module -Name $requiredModule.Key -ListAvailable -ErrorAction SilentlyContinue |
            Where-Object { $_.Version -eq $requiredModule.Value } |
            Select-Object -First 1

        if (-not $module) {
            $requiredModule.Key
        }
    }

    if (-not $missingModules) {
        return
    }

    $repositoryPolicy = (Get-PSRepository -Name 'PSGallery').InstallationPolicy
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    try {
        foreach ($missingModule in $missingModules) {
            Install-Module -Name $missingModule -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck -Force
        }
    } finally {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy $repositoryPolicy
    }

    foreach ($requiredModule in $requiredModules.Keys) {
        Import-Module -Name $requiredModule -ErrorAction SilentlyContinue
    }
}

function Push {
    [CmdletBinding()]
    param(
        [string[]]$Remotes = @('homotechsual')
    )

    foreach ($remote in $Remotes) {
        git push $remote
        git push $remote --tags
    }
}

function Build {
    [CmdletBinding()]
    param()

    $moduleOutputPath = Join-Path -Path $RepoRoot -ChildPath ('Output\{0}' -f $Script:ModuleName)
    if (-not (Test-Path -Path $moduleOutputPath -PathType Container)) {
        New-Item -Path $moduleOutputPath -ItemType Directory -Force | Out-Null
    }

    $pathsToCopy = @('Classes', 'Data', 'Private', 'Public')
    foreach ($pathToCopy in $pathsToCopy) {
        $sourcePath = Join-Path -Path $RepoRoot -ChildPath $pathToCopy
        if (Test-Path -Path $sourcePath -PathType Container) {
            Copy-Item -Path (Join-Path -Path $sourcePath -ChildPath '*') -Destination $moduleOutputPath -Recurse -Force
        }
    }

    Copy-Item -Path @(
        (Join-Path -Path $RepoRoot -ChildPath 'LICENSE.md')
        (Join-Path -Path $RepoRoot -ChildPath 'CHANGELOG.md')
        (Join-Path -Path $RepoRoot -ChildPath 'README.md')
        (Join-Path -Path $RepoRoot -ChildPath ('{0}.psd1' -f $Script:ModuleName))
        (Join-Path -Path $RepoRoot -ChildPath ('{0}.psm1' -f $Script:ModuleName))
    ) -Destination $moduleOutputPath -Force
}

function UpdateManifest {
    Ensure-RequiredModules

    $changeLogPath = Join-Path -Path $RepoRoot -ChildPath 'CHANGELOG.md'
    $manifestPath = Join-Path -Path $RepoRoot -ChildPath ('{0}.psd1' -f $Script:ModuleName)

    $changeLog = Get-Content -Path $changeLogPath -Raw
    $markdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$versionRegex = '\d*\.\d*\.\d*'
    $versions = $versionRegex.Matches($markdownObject.ParseString($changeLog).Children.Spans.Text) | ForEach-Object { $_.Value }
    $changeLogVersion = ($versions | Measure-Object -Maximum).Maximum

    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version

    if ($changeLogVersion -eq $version.ToString()) {
        throw 'No new version found in CHANGELOG.md'
    }

    Write-Output -InputObject ('Current Module Version: {0}' -f $version)
    Write-Output -InputObject ('New Module version: {0}' -f $changeLogVersion)

    $changeLogContent = Get-Content -Path $changeLogPath
    $releaseNotes = ((($markdownObject.ParseString($changeLogContent).Children.Spans.Text) -match '#{2}.*\d*\.\d*\.\d') -split ' - ')[1]

    Update-ModuleManifest -ModuleVersion $changeLogVersion -Path $manifestPath -ReleaseNotes $releaseNotes
}

function Publish {
    [CmdletBinding()]
    param(
        [ValidateSet('Development', 'Production')]
        [string]$Configuration = 'Production'
    )

    if ($Configuration -ne 'Production') {
        return
    }

    $publishPath = Join-Path -Path $RepoRoot -ChildPath ('Output\{0}' -f $Script:ModuleName)
    $manifestPath = Join-Path -Path $RepoRoot -ChildPath ('{0}.psd1' -f $Script:ModuleName)

    $publishParameters = @{
        Path = $publishPath
        ErrorAction = 'Stop'
    }

    if ($env:PSGalleryAPIKey) {
        $publishParameters.NuGetApiKey = $env:PSGalleryAPIKey
    } else {
        $publishParameters.NuGetApiKey = Get-AzKeyVaultSecret -VaultName $env:PSGalleryVault -Name $env:PSGallerySecret -AsPlainText
    }

    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    Publish-Module @publishParameters
    Write-Output -InputObject ('{0} PowerShell Module version {1} published to the PowerShell Gallery' -f $Script:ModuleName, $version)
}

function UpdateHelp {
    [CmdletBinding()]
    param(
        [string]$DocusaurusPath = $RepoRoot,
        [bool]$ForceUpdateCategoryFiles = $true
    )

    Ensure-RequiredModules

    $docusaurusModuleImported = $false
    $bundledDocusaurusModuleCandidates = @(
        (Join-Path -Path $RepoRoot -ChildPath 'Modules\Alt3.Docusaurus.Powershell\1.0.37\Alt3.Docusaurus.Powershell.psd1')
        'R:\Development\Docusaurus.PowerShell\Output\Alt3.Docusaurus.PowerShell\1.0.34\Alt3.Docusaurus.PowerShell.psd1'
    )
    foreach ($bundledDocusaurusModule in $bundledDocusaurusModuleCandidates) {
        if (Test-Path -Path $bundledDocusaurusModule) {
            Import-Module $bundledDocusaurusModule -Force
            $docusaurusModuleImported = $true
            break
        }
    }

    if (-not $docusaurusModuleImported -and (Get-Module -ListAvailable -Name 'Alt3.Docusaurus.PowerShell')) {
        Import-Module 'Alt3.Docusaurus.PowerShell' -Force
        $docusaurusModuleImported = $true
    }

    if (-not $docusaurusModuleImported) {
        throw 'Alt3.Docusaurus.PowerShell is required for updateHelp but could not be loaded from a local path or the module path.'
    }

    $docsFolderPath = Join-Path -Path $DocusaurusPath -ChildPath 'docs' -AdditionalChildPath $Script:ModuleName
    if (-not (Test-Path -Path $docsFolderPath -PathType Container)) {
        New-Item -Path $docsFolderPath -ItemType Directory | Out-Null
    }

    $markdownHeader = @'
:::powershell[Generated Cmdlet Help]
This page has been generated from the {0} PowerShell module source. To make changes please edit the appropriate PowerShell source file.
:::
'@ -f $Script:ModuleName

    $excludeFiles = Get-ChildItem -Path (Join-Path -Path $RepoRoot -ChildPath 'Private') -Filter '*.ps1' -Recurse |
        ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.FullName) }

    $newDocusaurusHelpParams = @{
        Module = ('.\{0}.psd1' -f $Script:ModuleName)
        DocsFolder = $docsFolderPath
        Exclude = $excludeFiles
        Sidebar = 'commandlets'
    }

    $optionalNewDocusaurusHelpParams = @{
        GroupByVerb = $true
        UseDescriptionFromHelp = $true
        NoPlaceHolderExamples = $true
        UseCustomShortTitles = $false
        PrependMarkdown = $markdownHeader
        RemoveParameters = @('-ProgressAction', '-FakeParam')
    }

    $supportedNewDocusaurusHelpParameters = (Get-Command -Name 'New-DocusaurusHelp' -ErrorAction Stop).Parameters.Keys
    foreach ($optionalParameter in $optionalNewDocusaurusHelpParams.GetEnumerator()) {
        if ($supportedNewDocusaurusHelpParameters -contains $optionalParameter.Key) {
            $newDocusaurusHelpParams[$optionalParameter.Key] = $optionalParameter.Value
        }
    }

    New-DocusaurusHelp @newDocusaurusHelpParams | Out-Null

    $commandletDocsFolder = Join-Path -Path $DocusaurusPath -ChildPath 'docs' -AdditionalChildPath @($Script:ModuleName, 'commandlets')
    $verbFolders = Get-ChildItem -Path $commandletDocsFolder -Directory
    $categoryFileBase = @{
        position = 1
        collapsible = $true
        collapsed = $true
        link = @{
            type = 'generated-index'
        }
        customProps = @{
            description = ''
        }
    }

    foreach ($verbFolder in $verbFolders) {
        $hasCategoryFile = Get-ChildItem -Path $verbFolder.FullName -Filter '_category_.*' -File -ErrorAction SilentlyContinue
        $categoryFilePath = Join-Path -Path $verbFolder.FullName -ChildPath '_category_.json'

        switch ($verbFolder.Name) {
            'Connect' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Connect to Services'
                $categoryFile.position = 0.1
                $categoryFile.className = 'category-connect'
                $categoryFile.link.title = 'Connect to Services'
                $categoryFile.customProps.description = 'This category contains commands for connecting to services, retrieving and storing credentials and managing connections.'
            }
            'Find' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Find Information'
                $categoryFile.position = 0.2
                $categoryFile.className = 'category-find'
                $categoryFile.link.title = 'Find Information'
                $categoryFile.customProps.description = 'This category contains commands for finding information from services, this may include data, objects, settings and more.'
            }
            'Get' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Retrieve Information'
                $categoryFile.position = 0.3
                $categoryFile.className = 'category-get'
                $categoryFile.link.title = 'Retrieve Information'
                $categoryFile.customProps.description = 'This category contains commands for retrieving information from services, this may include data, objects, settings and more.'
            }
            'Invoke' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Invoke Actions'
                $categoryFile.position = 0.4
                $categoryFile.className = 'category-invoke'
                $categoryFile.link.title = 'Invoke Actions'
                $categoryFile.customProps.description = 'This category contains commands for invoking actions, this may include running scripts, executing commands and more. For API modules, this category will contain commands for sending arbitrary requests to the API - that is requests not covered by existing commands.'
            }
            'New' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Create Data'
                $categoryFile.position = 0.5
                $categoryFile.className = 'category-new'
                $categoryFile.link.title = 'Create Data'
                $categoryFile.customProps.description = 'This category contains commands for creating data, objects, settings and more.'
            }
            'Remove' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Remove Data'
                $categoryFile.position = 0.6
                $categoryFile.className = 'category-remove'
                $categoryFile.link.title = 'Remove Data'
                $categoryFile.customProps.description = 'This category contains commands for removing data, objects, settings and more.'
            }
            'Reset' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Reset State'
                $categoryFile.position = 0.6
                $categoryFile.className = 'category-reset'
                $categoryFile.link.title = 'Reset State'
                $categoryFile.customProps.description = 'This category contains commands for resetting state, this may include resetting settings, connections and more.'
            }
            'Restart' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Restart Services'
                $categoryFile.position = 0.6
                $categoryFile.className = 'category-restart'
                $categoryFile.link.title = 'Restart Services'
                $categoryFile.customProps.description = 'This category contains commands for restarting services, this may include restarting services, processes and more.'
            }
            'Restore' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Restore Data'
                $categoryFile.position = 0.6
                $categoryFile.className = 'category-restore'
                $categoryFile.link.title = 'Restore Data'
                $categoryFile.customProps.description = 'This category contains commands for restoring data, objects, settings and more. These commands will primarily be used for restoring data to a previous state.'
            }
            'Set' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Update Data (Set)'
                $categoryFile.position = 0.4
                $categoryFile.className = 'category-set'
                $categoryFile.link.title = 'Update Data (Set)'
                $categoryFile.customProps.description = 'This category contains commands for updating data, objects, settings and more. This category will overlap with the Update category.'
            }
            'Update' {
                $categoryFile = $categoryFileBase
                $categoryFile.label = 'Update Data (Update)'
                $categoryFile.position = 0.4
                $categoryFile.className = 'category-update'
                $categoryFile.link.title = 'Update Data (Update)'
                $categoryFile.customProps.description = 'This category contains commands for updating data, objects, settings and more. This category will overlap with the Set category.'
            }
            default {
                $categoryFile = $categoryFileBase
                $categoryFile.label = $verbFolder.Name
                $categoryFile.link.title = $verbFolder.Name
            }
        }

        if (-not $hasCategoryFile) {
            $categoryFile | ConvertTo-Json | Out-File -FilePath $categoryFilePath -Force
        } else {
            if (-not $ForceUpdateCategoryFiles) {
                Write-Warning -Message ('Category file already exists in "{0}" verb folder. Use the ForceUpdateCategoryFiles switch to overwrite existing category files.' -f $verbFolder.Name)
            } else {
                Set-Content -Path $categoryFilePath -Value ($categoryFile | ConvertTo-Json) -Force
            }
        }
    }
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
    $moduleOutputRoot = Join-Path -Path $RepoRoot -ChildPath 'Output'
    if (Test-Path -Path $moduleOutputRoot -PathType Container) {
        Remove-Item -Path $moduleOutputRoot -Recurse -Force
    }

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
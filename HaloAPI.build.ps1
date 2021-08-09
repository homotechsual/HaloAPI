<#
    .SYNOPSIS
        Build script for HaloAPI module - uses 'Invoke-Build' https://github.com/nightroman/Invoke-Build 
#>
Param (
    [String]$Configuration = 'Development'
)

#region Config: Use string mode when building.
Set-StrictMode -Version Latest
#endregion

#region Task: Copy PowerShell Module files to output folder for release on PSGallery
task CopyModuleFiles {
    # Copy Module Files to Output Folder
    if (-not (Test-Path ".\Output\HaloAPI")) {
        New-Item -Path ".\Output\HaloAPI" -ItemType Directory | Out-Null
    }
    Copy-Item -Path '.\Data\' -Filter *.* -Recurse -Destination ".\Output\HaloAPI" -Force
    Copy-Item -Path '.\Private\' -Filter *.* -Recurse -Destination ".\Output\HaloAPI" -Force
    Copy-Item -Path '.\Public\' -Filter *.* -Recurse -Destination ".\Output\HaloAPI" -Force
    Copy-Item -Path '.\Tests\' -Filter *.* -Recurse -Destination ".\Output\HaloAPI" -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\LICENSE.md'
        '.\CHANGELOG.md'
        '.\README.md'
        '.\HaloAPI.psd1'
        '.\HaloAPI.psm1'
    ) -Destination ".\Output\HaloAPI" -Force        
}
#endregion

#region Task: Run all Pester tests in folder .\Tests
task Test {
    $Result = Invoke-Pester ".\Tests" -PassThru
    if ($Result.FailedCount -gt 0) {
        throw 'Pester tests failed'
    }

}
#endregion

#region Task: Update the Module Manifest file with info from the Changelog.
task UpdateManifest {
    # Import PlatyPS. Needed for parsing the versions in the Changelog.
    Import-Module -Name PlatyPS

    # Find Latest Version in Change log.
    $CHANGELOG = Get-Content -Path ".\CHANGELOG.md"
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$Regex = "\d\.\d\.\d"
    $Versions = $Regex.Matches($MarkdownObject.ParseString($CHANGELOG).Children.Spans.Text) | ForEach-Object { $_.Value }
    ($Versions | Measure-Object -Maximum).Maximum

    $ManifestPath = ".\HaloAPI.psd"
 
    # Start by importing the manifest to determine the version, then add 1 to the Build
    $Manifest = Test-ModuleManifest -Path $ManifestPath
    [System.Version]$Version = $Manifest.Version
    [String]$NewVersion = New-Object -TypeName System.Version -ArgumentList ($Version.Major, $Version.Minor, ($Version.Build + 1))
    Write-Output -InputObject ("New Module version: $($NewVersion)")

    # Update Manifest file with Release Notes
    $CHANGELOG = Get-Content -Path .\CHANGELOG.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($CHANGELOG).Children.Spans.Text) -Match '\d\.\d\.\d') -Split ' - ')[1]
    
    #Update Module with new version
    Update-ModuleManifest -ModuleVersion $NewVersion -Path ".\HaloAPI.psd" -ReleaseNotes $ReleaseNotes
}
#endregion

#region Task: Publish Module to PowerShell Gallery
task PublishModule -if ($Configuration -eq 'Production') {
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path        = ("$($PSScriptRoot)\Output\HaloAPI")
            NuGetApiKey = $env:PSGalleryKey
            ErrorAction = "Stop"
        }
        Publish-Module @params
        Write-Output -InputObject ("HaloAPI PowerShell Module version $($NewVersion) published to the PowerShell Gallery")
    }
    Catch {
        Throw $_
    }
}
#endregion

#region Task: Clean up Output folder
task Clean {
    # Clean output folder
    if ((Test-Path ".\Output")) {
        Remove-Item -Path ".\Output" -Recurse -Force
    }
}
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task . Clean, Test, CopyModuleFiles, PublishModule, Clean
#endregion
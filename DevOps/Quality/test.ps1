<#
    .SYNOPSIS
        Runs HaloAPI Pester test suites through a dedicated script entrypoint.
    .DESCRIPTION
        Provides a host-safe wrapper around Pester for HaloAPI development, CI,
        and VS Code task execution. Prefer this script over ad hoc Invoke-Pester
        calls in the VS Code host.
#>
#requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.5.0'; MaximumVersion = '5.999' }
param(
    # Enables VS Code Pester markers when running the test script interactively.
    [switch]$IncludeVSCodeMarker,
    # The test suites to execute.
    [ValidateSet('E2E', 'Live', 'Meta', 'Unit')]
    [string[]]$Suite = @('Meta'),
    # The Pester output verbosity level.
    [ValidateSet('Detailed', 'Normal', 'Minimal', 'None')]
    [string]$Verbosity = 'Detailed',
    # Enables Pester code coverage output for the selected suites.
    [switch]$CodeCoverage
)

$repoRoot = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\..')

try {
    Push-Location $repoRoot

    $artifactsPath = Join-Path -Path $repoRoot -ChildPath '.artifacts'
    $null = New-Item -Path $artifactsPath -ItemType Directory -Force
    Get-ChildItem -Path $artifactsPath -Filter 'TestResults.*.xml' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $artifactsPath -Filter 'CodeCoverage.*.xml' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    $coveragePaths = @(
        (Join-Path -Path $repoRoot -ChildPath 'HaloAPI.psm1')
    )
    $coveragePaths += Get-ChildItem -Path (Join-Path -Path $repoRoot -ChildPath 'Public') -Recurse -Filter '*.ps1' -File |
    Select-Object -ExpandProperty FullName
    $coveragePaths += Get-ChildItem -Path (Join-Path -Path $repoRoot -ChildPath 'Private') -Recurse -Filter '*.ps1' -File |
    Select-Object -ExpandProperty FullName
    $coveragePaths = $coveragePaths | Sort-Object -Unique

    $testSuites = @(
        [pscustomobject]@{
            Name = 'E2E'
            Paths = @('.\Tests\EndToEnd\Action.E2E.Tests.ps1', '.\Tests\EndToEnd\Agent.E2E.Tests.ps1')
            RequiresEnvironment = @('HaloTestingURL', 'HaloTestingClientID', 'HaloTestingClientSecret', 'HaloTestingTenant')
        },
        [pscustomobject]@{
            Name = 'Live'
            Paths = @('.\Tests\HaloAPI.Live.Tests.ps1')
            RequiresEnvironment = @('HaloTestingURL', 'HaloTestingClientID', 'HaloTestingClientSecret', 'HaloTestingTenant')
        },
        [pscustomobject]@{
            Name = 'Meta'
            Paths = @('.\Tests\HaloAPI.Meta.Tests.ps1')
            RequiresEnvironment = @()
        },
        [pscustomobject]@{
            Name = 'Unit'
            Paths = @('.\Tests\HaloAPI.Unit.Tests.ps1')
            RequiresEnvironment = @()
        }
    )

    $requestedSuites = @(
        $Suite |
        ForEach-Object { $_ -split '\s*,\s*' } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Select-Object -Unique
    )

    $validSuites = $testSuites.Name | Sort-Object -Unique
    $invalidSuites = $requestedSuites | Where-Object { $_ -notin $validSuites }
    if ($invalidSuites) {
        throw ('Invalid suite selection: {0}. Valid values: {1}' -f (($invalidSuites | Sort-Object) -join ', '), ($validSuites -join ', '))
    }

    $selectedSuites = $testSuites | Where-Object { $_.Name -in $requestedSuites }
    if (-not $selectedSuites) {
        throw ('No matching test suites were selected. Valid values: {0}' -f ($validSuites -join ', '))
    }

    $allResults = @()
    $totalPassed = 0
    $totalFailed = 0
    $totalSkipped = 0
    $suiteSummaries = @()
    $coverageSummaries = @()

    foreach ($testSuite in $selectedSuites) {
        $missingEnvironment = @(
            $testSuite.RequiresEnvironment |
            Where-Object { [string]::IsNullOrWhiteSpace((Get-Item -Path ('Env:{0}' -f $_) -ErrorAction SilentlyContinue).Value) }
        )
        if ($missingEnvironment) {
            throw ('Suite {0} requires environment variables that are not set: {1}' -f $testSuite.Name, ($missingEnvironment -join ', '))
        }

        $configuration = New-PesterConfiguration
        $testResultOutputPath = Join-Path -Path $artifactsPath -ChildPath ('TestResults.{0}.xml' -f $testSuite.Name.ToLowerInvariant())
        $coverageOutputPath = Join-Path -Path $artifactsPath -ChildPath ('CodeCoverage.{0}.xml' -f $testSuite.Name.ToLowerInvariant())
        $configuration.Run.Path = $testSuite.Paths
        $configuration.Run.PassThru = $true
        $configuration.Output.Verbosity = $Verbosity
        $configuration.TestResult.Enabled = $true
        $configuration.TestResult.OutputPath = $testResultOutputPath
        $configuration.TestResult.OutputFormat = 'JUnitXml'

        if ($CodeCoverage) {
            $configuration.CodeCoverage.Enabled = $true
            $configuration.CodeCoverage.Path = $coveragePaths
            $configuration.CodeCoverage.OutputPath = $coverageOutputPath
        }

        if ($IncludeVSCodeMarker) {
            if ($configuration | Get-Member -Name 'VSCodeMarker' -ErrorAction SilentlyContinue) {
                $configuration.VSCodeMarker = $true
            }
        }

        Write-Host ("`n=== Running {0} test suite ===" -f $testSuite.Name) -ForegroundColor Cyan
        $result = Invoke-Pester -Configuration $configuration
        $allResults += $result
        $totalPassed += $result.PassedCount
        $totalFailed += $result.FailedCount
        $totalSkipped += $result.SkippedCount
        $suiteSummaries += [pscustomobject]@{
            Suite = $testSuite.Name
            Paths = $testSuite.Paths
            PassedCount = $result.PassedCount
            FailedCount = $result.FailedCount
            SkippedCount = $result.SkippedCount
            OutputPath = $testResultOutputPath
        }

        if ($CodeCoverage -and $result.CodeCoverage) {
            $coverageSummaries += [pscustomobject]@{
                Suite = $testSuite.Name
                CommandsExecuted = $result.CodeCoverage.CommandsExecutedCount
                CommandsAnalyzed = $result.CodeCoverage.CommandsAnalyzedCount
                CoveragePercent = [math]::Round([double]$result.CodeCoverage.CoveragePercent, 2)
                OutputPath = $coverageOutputPath
            }
        }
    }

    Write-Host "`n=== Test Results Summary ===" -ForegroundColor Cyan
    foreach ($suiteSummary in $suiteSummaries) {
        Write-Host ('{0}: {1} passed, {2} failed, {3} skipped -> {4}' -f $suiteSummary.Suite, $suiteSummary.PassedCount, $suiteSummary.FailedCount, $suiteSummary.SkippedCount, $suiteSummary.OutputPath) -ForegroundColor $(if ($suiteSummary.FailedCount -gt 0) { 'Red' } else { 'Green' })
    }
    Write-Host ('Total: {0} passed, {1} failed, {2} skipped' -f $totalPassed, $totalFailed, $totalSkipped) -ForegroundColor $(if ($totalFailed -gt 0) { 'Red' } else { 'Green' })

    if ($coverageSummaries) {
        Write-Host "`n=== Code Coverage Summary ===" -ForegroundColor Cyan
        foreach ($coverageSummary in $coverageSummaries) {
            Write-Host ('{0}: {1}% ({2}/{3}) -> {4}' -f $coverageSummary.Suite, $coverageSummary.CoveragePercent, $coverageSummary.CommandsExecuted, $coverageSummary.CommandsAnalyzed, $coverageSummary.OutputPath) -ForegroundColor Green
        }
    }

    if ($env:GITHUB_STEP_SUMMARY) {
        $summaryLines = @(
            '## HaloAPI Test Summary',
            '',
            ('- Suites: {0}' -f (($selectedSuites.Name | Sort-Object) -join ', ')),
            ('- Passed: {0}' -f $totalPassed),
            ('- Failed: {0}' -f $totalFailed),
            ('- Skipped: {0}' -f $totalSkipped)
        )

        if ($coverageSummaries) {
            $summaryLines += ''
            $summaryLines += '## HaloAPI Coverage Summary'
            $summaryLines += ''
            $summaryLines += '| Suite | Coverage | Commands | Artifact |'
            $summaryLines += '| --- | ---: | ---: | --- |'
            foreach ($coverageSummary in $coverageSummaries) {
                $summaryLines += ('| {0} | {1}% | {2}/{3} | {4} |' -f $coverageSummary.Suite, $coverageSummary.CoveragePercent, $coverageSummary.CommandsExecuted, $coverageSummary.CommandsAnalyzed, $coverageSummary.OutputPath)
            }
        }

        Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value $summaryLines
    }

    $combinedResults = [pscustomobject]@{
        TotalPassed = $totalPassed
        TotalFailed = $totalFailed
        TotalSkipped = $totalSkipped
        Suites = $suiteSummaries
        Coverage = $coverageSummaries
        ExecutedAt = Get-Date
    }

    $combinedResults

    if ($totalFailed -gt 0) {
        throw ('Pester failed with {0} failing test(s).' -f $totalFailed)
    }
} finally {
    Pop-Location
}
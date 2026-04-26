param(
    [string]$SettingsPath
)

$RepoRoot = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\..')
if (-not $SettingsPath) {
    $SettingsPath = Join-Path -Path $RepoRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'
}

$settings = Import-PowerShellDataFile -Path $SettingsPath
$customRulePath = Join-Path -Path $RepoRoot -ChildPath 'CustomRules'
$customRules = @(
    'Measure-RequiredCommentBasedHelp',
    'Measure-EmptyCommentBasedHelpSections',
    'Measure-MissingParameterDescription',
    'Measure-AvoidSelfReferentialParameterAlias',
    'Measure-RequireCamelCaseParameterName',
    'Measure-RequireProperTypeAcceleratorCasing'
)

$publicSettings = @{
    Severity = $settings.Severity
    IncludeRules = [string[]]@($settings.IncludeRules)
    Rules = $settings.Rules
}
$publicOnlyCustomRules = @(
    'Measure-RequiredCommentBasedHelp',
    'Measure-EmptyCommentBasedHelpSections',
    'Measure-MissingParameterDescription',
    'Measure-AvoidSelfReferentialParameterAlias',
    'Measure-RequireCamelCaseParameterName',
    'Measure-RequireProperTypeAcceleratorCasing'
)

$nonPublicSettings = @{
    Severity = $settings.Severity
    IncludeRules = [string[]]@($settings.IncludeRules | Where-Object { $_ -notin $publicOnlyCustomRules })
    Rules = $settings.Rules
}

$excludeRegex = '/(CustomRules|Output)/'
$publicRoot = Join-Path -Path $RepoRoot -ChildPath 'Public'

if (Test-Path -Path $publicRoot) {
    Invoke-ScriptAnalyzer -Path $publicRoot -Recurse -Settings $publicSettings -CustomRulePath $customRulePath
}

Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.ps1, *.psm1, *.psd1 |
Where-Object {
    $fullName = $_.FullName
    $normalizedFullName = $fullName -replace '\\', '/'
    $normalizedFullName -notmatch $excludeRegex -and
    $fullName -notlike ('{0}*' -f $publicRoot)
} |
Invoke-ScriptAnalyzer -Settings $nonPublicSettings -CustomRulePath $customRulePath
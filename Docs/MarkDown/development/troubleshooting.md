# Development Troubleshooting

Common troubleshooting notes for HaloAPI development.

## Build and Environment

### Bootstrap does not install a required module

Symptoms:

```powershell
The specified module 'Pester' was not found.
```

Try:

```powershell
pwsh -File .\Bootstrap.ps1
Get-Content .\RequiredModules.psd1
Install-Module Pester -Force
```

### Build or publish behavior differs between local runs and GitHub Actions

Use the repo scripts as the source of truth first, then make workflow changes match them.

Try:

```powershell
pwsh -File .\Bootstrap.ps1
pwsh -File .\DevOps\Quality\run-pssa.ps1
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta
```

## Testing

### VS Code becomes unstable when running tests interactively

Cause:

* Direct `Invoke-Pester` runs in the VS Code host can be less stable than using the dedicated test script entrypoint.

Use this instead:

```powershell
pwsh -File .\DevOps\Quality\test.ps1 -IncludeVSCodeMarker
```

Or run the `Test HaloAPI` VS Code task. Treat `DevOps\Quality\test.ps1` as the only supported test entrypoint for normal validation.

### Core tests fail immediately because environment variables are missing

The `Core` suite requires these variables:

* `HaloTestingURL`
* `HaloTestingClientID`
* `HaloTestingClientSecret`
* `HaloTestingTenant`

If you only need a safe baseline test pass, use:

```powershell
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta
```

### Tests pass locally but fail in CI

Start by confirming you are using the same script entrypoint locally as CI:

```powershell
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta -Verbosity Detailed
```

Also confirm the branch context matches the repo workflow. Normal CI runs are centered on `develop`, while stable releases are cut from `main`.

If results still differ, clear stale artifacts and rerun:

```powershell
Remove-Item .\.artifacts\* -Recurse -Force -ErrorAction SilentlyContinue
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta
```

## PSScriptAnalyzer

### `run-pssa.ps1` and direct `Invoke-ScriptAnalyzer` runs disagree

The repo wrapper scopes custom rules differently for public and non-public code, so use the wrapper as the primary validation command:

```powershell
pwsh -File .\DevOps\Quality\run-pssa.ps1
```

If you scan directories manually, remember to recurse:

```powershell
Invoke-ScriptAnalyzer -Path .\Public -Recurse -Settings .\PSScriptAnalyzerSettings.psd1 -CustomRulePath .\CustomRules
```

### Parameter comment or help rules still appear after a change

Check the exact placement of inline comments and help blocks. The custom rules expect comments immediately before the parameter or help section they describe.

After changes, rerun:

```powershell
pwsh -File .\DevOps\Quality\run-pssa.ps1
```

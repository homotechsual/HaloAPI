# Quality Gates

This page documents the quality gates and code standards currently enforced in HaloAPI.

## Overview

HaloAPI quality checks are centered on these repo entrypoints:

```powershell
pwsh -File .\DevOps\Quality\run-pssa.ps1
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta
```

The repo currently uses:

* `PSScriptAnalyzer` for static analysis.
* HaloAPI-specific custom rules under `CustomRules/`.
* Inline parameter comments for functions where the custom rules require them.
* Comment-based help on public cmdlets.

## PSScriptAnalyzer

Use the dedicated wrapper instead of ad hoc analyzer commands:

```powershell
pwsh -File .\DevOps\Quality\run-pssa.ps1
```

The wrapper intentionally applies the full repo ruleset to `Public/` and a reduced ruleset elsewhere.

Public-surface conventions currently enforced include:

* required comment-based help
* empty help section detection
* missing parameter description detection
* self-referential parameter alias detection

## Tests

Use the dedicated test script rather than calling `Invoke-Pester` directly:

```powershell
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta -Verbosity Detailed
```

Generate coverage through the same entrypoint:

```powershell
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta -Verbosity Detailed -CodeCoverage
```

## CI Quality Gates

The GitHub Actions CI flow on `develop` currently validates:

1. PSScriptAnalyzer on Windows.
2. Cross-platform metadata smoke tests on Linux and macOS.
3. Windows metadata tests with JUnit output and coverage artifact generation.

## Expectations For Changes

When changing public cmdlets:

* keep comment-based help intact
* preserve exported function naming and aliasing conventions
* rerun `run-pssa.ps1`
* rerun `test.ps1 -Suite Meta`

When changing workflows:

* keep the repo script entrypoints as the source of truth
* avoid broadening secret usage unless required
* preserve the `develop` integration branch and `main` release branch behavior

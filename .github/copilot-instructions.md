# Copilot instructions for HaloAPI

This repository is a PowerShell module for the Halo API with helper classes, generated documentation output, and GitHub Actions workflows.

## General expectations

* Prefer small, targeted changes over wide refactors.
* Preserve the repository's existing PowerShell formatting conventions:
  * spaces for indentation
  * OTBS/K\&R brace style
  * comment-based help for public functions
* Keep public cmdlet names, aliases, and manifest exports consistent with existing patterns.
* Avoid editing generated output under `Output/` unless explicitly asked.
* Treat generated docs output under `docs/HaloAPI/`, `Docs/MAML/`, and `Docs/en_GB/` as generated unless the task is specifically about docs generation.
* Treat `Docs/development/` as repo-authored development documentation.

## Testing and verification

* Prefer the existing repo entrypoints when validating changes:
  * `pwsh -File .\Bootstrap.ps1`
  * `pwsh -File .\DevOps\Quality\run-pssa.ps1`
  * `pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta`
* For interactive VS Code test runs, prefer the `Test HaloAPI` task or:
  * `pwsh -File .\DevOps\Quality\test.ps1 -IncludeVSCodeMarker`
* Do not invoke `Invoke-Pester` directly from the VS Code host, terminal, or agent command flow for normal validation in this repo.
* Use `DevOps\Quality\test.ps1` as the only supported test entrypoint; direct Pester invocation is only acceptable inside that dedicated script.
* Treat CI/workflow changes carefully and keep them minimal.

## Release and workflow guidance

* Keep GitHub Actions changes focused and explicit.
* Normal branch and pull request work should target `develop`; `main` remains the stable release branch.
* Stable releases should continue to align with the repository's tagged release flow.
* When adjusting release automation, preserve PowerShell Gallery publishing behavior and avoid changing release semantics unless explicitly requested.

## PowerShell module conventions

* Public functions belong under `Public/` and should include comment-based help.
* Internal helpers belong under `Private/`.
* Helper classes, validators, transformations, and completers belong under `Classes/`.
* The module targets PowerShell 7 and is not intended to support Windows PowerShell 5.1.
* Preserve existing parameter naming and aliasing conventions in HaloAPI even where they differ from other repos.

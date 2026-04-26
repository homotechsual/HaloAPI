***

applyTo: ".github/workflows/**/\*.{yml,yaml},DevOps/**/\*.ps1"
description: "Use for CI/CD and automation changes in HaloAPI: keep workflows explicit, safe, and consistent with the GitHub Actions-based release flow."
---------------------------------------------------------------------------------------------------------------------------------------------------------

# Workflow and automation instructions

* Keep workflow changes minimal and focused.
* Prefer explicit failure handling in PowerShell workflow steps.
* Use the repo scripts (`Bootstrap.ps1`, `DevOps/Quality/run-pssa.ps1`, `DevOps/Quality/test.ps1`) instead of recreating logic inline in workflows.
* When making GitHub Actions changes, avoid broadening secrets usage or release scope unless explicitly requested.
* Preserve the repo's branch behavior: normal CI and pull request validation target `develop`, while stable releases are cut from `main`.
* Do not use raw `Invoke-Pester` as a workflow, terminal, or agent execution path for HaloAPI validation.
* Use `DevOps/Quality/test.ps1` as the only supported test entrypoint in CI and interactive tooling; direct Pester invocation is only allowed inside that dedicated script.
* Prefer dedicated script entrypoints over ad hoc analyzer commands in CI and interactive tooling.

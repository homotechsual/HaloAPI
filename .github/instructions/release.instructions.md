***

applyTo: "CHANGELOG.md,HaloAPI.psd1,.github/workflows/\*\*/\*.{yml,yaml}"
description: "Use for HaloAPI versioning and release work: update manifest and release automation carefully while preserving publishing behavior."
--------------------------------------------------------------------------------------------------------------------------------------------------

# Release instructions

* Update `CHANGELOG.md` and `HaloAPI.psd1` together when preparing releases.
* Preserve PowerShell Gallery publishing behavior unless explicitly asked to change it.
* Keep release workflow changes minimal and explicit.
* Treat tags and release automation as production-impacting changes.
* Stable tags must be reachable from `main`; prerelease tags may be cut from `develop`.

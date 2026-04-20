***

applyTo: "Public/**/\*.ps1,Private/**/*.ps1,Classes/\*\*/*.psm1,Tests/**/\*.ps1,DevOps/**/\*.ps1"
description: "Use for PowerShell files in HaloAPI: preserve formatting, help, structure, and PowerShell 7 conventions."
-----------------------------------------------------------------------------------------------------------------------

# PowerShell file instructions

* Match the existing repository style and indentation.
* Use spaces for indentation and keep OTBS/K\&R brace style.
* Preserve comment-based help for public functions.
* Keep public cmdlet names, aliases, and manifest exports aligned with existing patterns.
* Prefer PowerShell 7-compatible solutions; this repo does not target Windows PowerShell 5.1.
* Preserve existing HaloAPI parameter naming conventions even if they are not camelCase.
* Treat helper classes, validators, argument transformations, and completers as part of the public module design surface and change them carefully.
* For test execution, do not add or use raw `Invoke-Pester` commands as the standard repo workflow; route test runs through `DevOps/Quality/test.ps1` instead.

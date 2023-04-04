# Changelog

## 2023-04-04 - Version 1.14.1

* Fix bug in `New-HaloWorkDay`.

## 2023-03-10 - Version 1.14.0

* Add Custom Table endpoints `Get-HaloCustomTable`, `New-HaloCustomTable`, `Remove-HaloCustomTable`.

## 2023-01-01 - Version 1.13.2
  
* Fix incorrect pluralization of `Get-HaloCustomField`.
* Changes to pipeline and release process.

## 2023-01-01 - Version 1.13.1
  
* Added `IncludeTenants` Switch to `Get-HaloAzureADConnection` to fix Contact sync script.

## 2022-11-18 - Version 1.13.0

* Adds `Recover-HaloTicket` and `-Deleted` parameter for `Get-HaloTicket`.
* Fix `429` (API rate limiting) response handling.
* Refactor of 429 error handling.
* Increase batch wait to 30 seconds.
* Adds `Remove-HaloItem`.

## 2022-09-16 - Version 1.11.1

* Fix for `PostedOnly` and `NonPostedOnly` parameters on `Get-HaloInvoice`.

## 2022-07-02 - Version 1.10.1

* Fix incorrect bug fix reversion affecting batch cmdlets.

## 2022-07-01 - Version 1.10.0

* Internal contract change, `Invoke-HaloBatchProcessor` now uses `BatchInput` instead of `Input`. Bugfixes for batch processing.

## 2022-06-21 - Version 1.9.1

* Add `-FullObject` parameter for Sites, batch processing for Actions, Workflows, Custom Fields and expose `Invoke-HaloRequest` for ad hoc requests.

## 2022-03-23 - Version 1.9.0

* Adds Software Licences, Asset Types and new automated tests.

## 2022-03-15 - Version 1.8.0

* Handle arrays of objects for many New/Set commands.

## 2022-02-06 - Version 1.7.0

* Refactored error handling.

## 2022-01-04 - Version 1.5.0

* New Feature: Added Workday functions

## 2021-11-11 - Version 1.4.0

* Fixed: Bug in `Get-HaloAsset` where some parameters were in the incorrect set.
* Fixed: Bug in the token expiry calculation causing too many reconnects.
* Fixed: Bug in authentication to trial instances.
* Fixed: Bug in billing templates.
* New Feature: Added Recurring invoice functions.

## 2021-10-01 - Version 1.3.2

* Fixed: Token expiry calculation is now correct.

## 2021-10-01 - Version 1.3.1

* Fixes the authentication flow for trial instances. Starts adding pipeline support (Tickets/Actions currently).
* Uses the `api/authinfo` endpoint to dynamically populate the Authentication URL for all requests now.
* Handle `-AuthURL` with or without a path.
* Switch from using `-AuthPath` to `-AuthURL` to fix the actual issue in GitHub #1
* Add an `-AuthPath` parameter to `Connect-HaloAPI` for non-standard authentication routes.

## 2021-08-24 - Version 1.2.3

* Fix misnamed function invocation in `Get-HaloClient`.

## 2021-08-24 - Version 1.2.2

* Remove the attempt to load the `HaloLookup` class in `HaloAPI.psm1` as it's not used.

## 2021-08-23 - Version 1.2.1

* Adds missing classes which were erroneously excluded from the build script.

## 2021-08-22 - Version 1.2.0

* Changes to error handling for more descriptive and reliable error messages.
* Adds validation and dynamic completion classes for Lookups, Custom Button types and Scopes.
* Add Custom Buttons endpoint.

## 2021-08-12 - Version 1.1.0

* Change to output formats - now outputs the objects/results directly. No more `(Get-HaloAction).actions`.
* Add the first two `Remove-` commands.
* Leaner more efficient core.

## 2021-08-11 - Version 1.0.2

* Fix a bug with `Get-HaloAsset` when supplying the `AssetID` parameter.

## 2021-08-08 - Version 1.0.1

* Initial release of the HaloAPI PowerShell module.
  
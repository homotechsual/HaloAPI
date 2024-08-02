# Changelog

If you contributed one of these and there's no credit in the line PR to add it or let me know!

## 2024-08-01 - Version 1.22.1

* Fix multiple incorrect parameters and missing parameters for `Get-HaloRecurringInvoice`.

## 2024-07-11 - Version 1.22.0

* Add create, read, update and delete commandlets for View Columns.
* Add create, read, update and delete commandlets for View Filters.
* Add create, read, update and delete commandlets for View List Groups.
* Add create, read, update and delete commandlets for View Lists.
* Add create, read, update and delete commandlets for Change Approval Boards.
* Connect-HaloAPI now returns a boolean value representing the connection state.

## 2024-07-05 - Version 1.21.2

* Add `-IncludeInactive` parameter to `Get-HaloSoftwareLicenses` (by @jsanzdev)

## 2024-07-04 - Version 1.21.1

* Expose `Set-HaloTicketBatch`.

## 2024-07-04 - Version 1.21.0

* Fix `Remove-HaloActionBatch`, `Remove-HaloTicketBatch`, `Remove-HaloAgentBatch` and `Remove-HaloClientBatch`.
* Add dashboard commandlets (by Robbie @ Renada)
* Fix multiple unexposed commandlets.

## 2024-01-12 - Version 1.20.0

* Fix comment-based-help in QBO commandlet.
* Fix comment-based-help in Suppliers commandlet.
* Revert change to command name processing made in 1.18.0.

## 2024-01-12 - Version 1.19.0

* Expose missing commandlets for QBO, SQL and Suppliers.
* Add `Remove-HaloAppointment`.
* Add `Remove-HaloAsset`.
* Add `Remove-HaloSupplier`.
* Expand parameters for `Get-HaloAsset` to match updated API spec.

## 2024-01-04 - Version 1.18.0

* Add `PaymentStatuses` filter parameter to `Get-HaloInvoice`.
* Minor internal refactor of how the command name is extracted.

## 2023-12-19 - Version 1.17.0

* Add `-AsBase64` parameter to `Get-HaloAttachment` to allow fetching single attachments as base64 encoded strings.
* Add endpoints for QuickBooks Online. (By Mendy @ Rising Tide)
* Add suppliers commandlets. (By Mendy @ Rising Tide)
* Add `Invoke-HaloSQL` (By Mendy @ Rising Tide)

## 2023-11-17 - Version 1.16.0

* Refactor variables in `Invoke-HaloRequest` to avoid scope confusion.
* Now compatible with PowerShell 7.4.0.

## 2023-10-23 - Version 1.15.0

* Overhaul retry handling to increase delay between subsequent retries.
* Add new commandlets.
* Add KeyVault support directly to Connect commandlet.

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
  
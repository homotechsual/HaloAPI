# Changelog
* 2022-01-04

  Version 1.5.0
  ```
  New Feature: Added Workday functions
  ```

* 2021-11-11

  Version 1.4
  ```
  Fixed: Bug in Get-HaloAsset where some parameters were in the incorrect set
  Fixed: Bug in the token expiry calculation causing too many reconnects
  Fixed: Bug in authentication to trial instances.
  Fixed: Bug in billing templates.
  New Feature: Added Recurring invoice functions
  ```

* 2021-09-03

  Version 1.3.0-Beta5

  Fixes the authentication flow for trial instances. Starts adding pipeline support (Tickets/Actions currently).

* 2021-08-25

  Version 1.3.0-Beta4

  Uses the `api/authinfo` endpoint to dynamically populate the Authentication URL for all requests now.

* 2021-08-25

  Version 1.3.0-Beta3

  Handle `-AuthURL` with or without a path.

* 2021-08-25

  Version 1.3.0-Beta2

  Switch from using `-AuthPath` to `-AuthURL` to fix the actual issue in GitHub #1

* 2021-08-25

  Version 1.3.0-Beta1

  Add an `-AuthPath` parameter to Connect-HaloAPI for non-standard authentication routes.

* 2021-08-24

  Version 1.2.3

  Fix misnamed function invocation in `Get-HaloClient`.

* 2021-08-24

  Version 1.2.2

  Remove the attempt to load the `HaloLookup` class in HaloAPI.psm1 as it's not used.

* 2021-08-23

  Version 1.2.1

  Adds missing classes which were erroneously excluded from the build script.

* 2021-08-22

  Version 1.2.0
  
  Changes to error handling for more descriptive and reliable error messages.
  
  Adds validation and dynamic completion classes for Lookups, Custom Button types and Scopes.

  Add Custom Buttons endpoint.

* 2021-08-12

  Version 1.1.0
  
  Change to output formats - now outputs the objects/results directly. No more `(Get-HaloAction).actions`. Add the first two `Remove-` commands. Leaner more efficient core.

* 2021-08-11

  Version 1.0.2
  
  Fix a bug with `Get-HaloAsset` when supplying the `AssetID` parameter.

* 2021-08-08
  
  Version 1.0.1
  
  Initial release of the HaloAPI PowerShell module.
  
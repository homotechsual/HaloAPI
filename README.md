# HaloAPI - A [PowerShell](https://microsoft.com/powershell) module for [Halo Service Solutions](https://haloservicesolutions.com/) software

[![Homotechsual Discord](https://img.shields.io/discord/1075421628424523816?style=for-the-badge&logo=discord&logoColor=white&label=Homotechsual%20Discord)](https://discord.com/invite/NrCjh5ht7K)
[![HaloPSA Community Discord](https://img.shields.io/discord/1044558967545806940?style=for-the-badge&logo=discord&logoColor=white&label=HaloPSA%20Community%20Discord)](https://discord.com/invite/Y4R5duJD4z)
[![GitHub contributors](https://img.shields.io/github/contributors/homotechsual/haloapi?style=for-the-badge&logo=github)](https://github.com/homotechsual/haloapi/)
[![GitHub Release](https://img.shields.io/github/v/release/homotechsual/HaloAPI?style=for-the-badge&label=Release)](https://github.com/homotechsual/HaloAPI/releases/latest)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/homotechsual/HaloAPI/ci.yml?style=for-the-badge&label=CI)](https://github.com/homotechsual/HaloAPI/actions/workflows/ci.yml)
[![Codecov (with branch)](https://img.shields.io/codecov/c/github/homotechsual/HaloAPI/develop?style=for-the-badge)](https://app.codecov.io/gh/homotechsual/HaloAPI)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/HaloAPI?style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![License](https://img.shields.io/github/license/homotechsual/HaloAPI?style=for-the-badge)](https://mit.license.homotechsual.dev/)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/homotechsual?style=for-the-badge)](https://github.com/sponsors/homotechsual/)
[![Stable Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Stable+Release&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![Preview Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Preview+Release&include_prereleases&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)

## Who are we?

We are Mikey O'Toole ([@homotechsual](https://github.com/homotechsual)) and Luke Whitelock ([@LWhitelock](https://github.com/lwhitelock)) we are both directors for (separate) UK-based managed IT services providers who share a passion for automation and good quality MSP software tools.

## What is this?

This is the code for a [PowerShell](https://microsoft.com/powershell) module for the [Halo Service Solutions](https://usehalo.com/) series of software, including:

* [HaloPSA](https://halopsa.com)
* [HaloITSM](https://haloitsm.com/)
* [HaloServiceDesk](https://haloservicedesk.com/)

The module is written for [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-71?view=powershell-7.1). **It is not compatible with Windows PowerShell 5.1 and there are no current plans to change this**. This module is licensed under the [MIT](https://mit.license.homotechsual.dev/) license.

## What does it do?

HaloAPI provides a PowerShell wrapper around the Halo API, tested extensively against HaloPSA instances only (please test against HaloITSM or HaloServiceDesk instances and let us know how it works). The module can retrieve and send information to the Halo API.

## Where's the content?

Use the docs website for the most up-to-date generated command reference and development guidance. The docs publishing workflows sync HaloAPI content into the shared `homotechsualdocs` site structure.

## Code Coverage

Code coverage is collected in CI for the `Meta` and `Unit` suites using the standard test entrypoint in `DevOps/Quality/test.ps1`.

CI enforces a minimum 70% coverage threshold for the `Unit` suite.

Coverage artifacts are published on every CI run as:

* `code-coverage-meta-results` (`.artifacts/CodeCoverage.meta.xml`)
* `code-coverage-unit-results` (`.artifacts/CodeCoverage.unit.xml`)

View the latest run artifacts from the CI workflow:

<https://github.com/homotechsual/HaloAPI/actions/workflows/ci.yml>

## Installing

This module is published to the PowerShell Gallery and can be installed from within PowerShell with `Install-Module`

```PowerShell
Install-Module HaloAPI
```

## Getting Started

The first and probably most important requirement for this module is getting it connected to your Halo instance.

HaloAPI supports two ways of authenticating. Both need an API application in Halo, but the application is configured differently:

| | Client credentials (default) | Interactive (`-Interactive`) |
| --- | --- | --- |
| Best for | Unattended scripts, scheduled tasks, automation, CI | Hands-on use at a console, ad-hoc admin tasks |
| Halo **Authentication Method** | *Client ID and Secret (Services)* | *Authorisation Code (Native Application)* |
| Secret to store | Client ID **and** Client Secret | Client ID only (no secret) |
| Requests run as | The **Agent to login as** set on the application | The agent who signs in through the browser |
| Needs a browser | No | Yes, on the machine running PowerShell |
| Token renewal | Requests a new token with the secret | Refresh token, with a browser sign-in as fallback |

If you are scripting something that runs without you at the keyboard, use client credentials. If you want API calls to run with your own permissions (and show up as you in Halo), use `-Interactive`.

### Install the module

Install the HaloAPI PowerShell module on PowerShell 7.0 or above.

```PowerShell
Install-Module HaloAPI
```

### Option 1: Client credentials (unattended)

#### Creating the client credentials API application in Halo

1. In your Halo instance head to **Configuration** > **Integrations** > **Halo PSA API**  
This might be *Halo Service Desk API* or *Halo ITSM API*.

1. Click on **View Applications**  
All going well you should be at `config/integrations/api/applications`.

1. Click on **New** to add a new API application.

1. Enter the **Application Name**.  
For example *HaloAPI PS Module*.

1. Make sure **Active** is checked.

1. Set the **Authentication Method** to *Client ID and Secret (Services)*.

1. Store the **Client ID** and **Client Secret** securely.

1. Set the **Login Type** and **Agent to login as** appropriately.  
*This setting will determine who appears to be responsible for these API calls. You may want to create a dedicated agent user for this purpose.*

1. Select the **Permissions** tab.

1. Grant the application the permissions required for your purposes.  
*Generally speaking you want to limit the API to only the permissions it needs, to do the job you're scripting for.*

#### Connecting with client credentials

```PowerShell
Connect-HaloAPI -ClientID "a1234567-bcd8-9e01-2f34-56g7hijk89lm" -Tenant "demo" -URL "https://demo.halopsa.com" -ClientSecret "a1234567-bcd8-9e01-2f34-56g7hijk89lm-a1234567-bcd8-9e01-2f34-56g7hijk89lm" -Scopes "all"
```

* `-Tenant` is only needed for hosted Halo instances. `-Scopes` defaults to `all` and is limited by the permissions granted to the application.
* Avoid leaving the client secret in scripts or shell history. `Connect-HaloAPI` can read and save the URL, client ID and secret in Azure Key Vault using `-UseKeyVault`, `-SaveToKeyVault`, `-VaultName`, `-SecretName` and (for unattended Azure hosts) `-UseManagedIdentity`. See `Get-Help Connect-HaloAPI -Full`.

### Option 2: Interactive browser sign-in (`-Interactive`)

Interactive sign-in uses the OAuth authorisation code flow with PKCE. You sign in to Halo in your browser as yourself, so there is **no client secret** to create, store or leak, and every API call runs with your agent account's permissions.

#### Creating the interactive API application in Halo

1. Go to **Configuration** > **Integrations** > **Halo PSA API** > **View Applications** and click **New**, as above.

1. Enter an **Application Name**, for example *HaloAPI PS Module (Interactive)*, and make sure **Active** is checked.

1. Set the **Authentication Method** to *Authorisation Code (Native Application)*.

1. Add `http://localhost:8400/` as a **Redirect URI**.  
*It must match the `-RedirectURI` you connect with exactly, including the trailing slash. The default is `http://localhost:8400/`.*

1. Note the **Client ID**. There is no client secret for this application type.

1. Save the application.  
*What the module can do is limited by the signed-in agent's own permissions in Halo as well as the scopes you request.*

#### Connecting interactively

```PowerShell
Connect-HaloAPI -Interactive -URL "https://demo.halopsa.com" -ClientID "a1234567-bcd8-9e01-2f34-56g7hijk89lm" -Tenant "demo"
```

What happens next:

1. PowerShell starts a short-lived listener on the redirect URI (`localhost` only) and opens your default browser at the Halo sign-in page. If no browser opens, the URL is printed so you can open it yourself.
1. Sign in to Halo as normal (including any SSO or MFA your instance requires).
1. Halo redirects back to the local listener, the browser shows *Signed in to Halo*, and you can close the tab. The module exchanges the code for a token and the connection is ready.
1. As the token nears expiry the module renews it using the refresh token. If renewal is rejected or there is no refresh token, you are taken through the browser sign-in again. Parallel batch workers reuse the renewed token rather than prompting separately.

Interactive-only options:

| Parameter | Default | Purpose |
| --- | --- | --- |
| `-RedirectURI` | `http://localhost:8400/` | Address the local listener binds to. Must match a Redirect URI on the Halo application and end with `/`. Change it if port 8400 is in use. |
| `-LoginTimeout` | `300` | Seconds to wait for you to finish signing in before giving up. |
| `-Scopes` | `all` | Scopes to request, as with client credentials. |

`-Interactive` can't be combined with `-ClientSecret` or the Key Vault parameters; those belong to the client credentials flow.

#### Troubleshooting interactive sign-in

* **"Could not listen on ... for the Halo sign-in redirect"** - the port is in use or blocked. Pick another port, add it as a Redirect URI on the Halo application, and pass it with `-RedirectURI "http://localhost:8401/"`.
* **"RedirectURI must have a trailing slash"** - add the `/` to the end of the URI, both in Halo and in `-RedirectURI`.
* **Halo reports a redirect URI mismatch** - the Redirect URI on the application and `-RedirectURI` must be identical.
* **"Timed out ... waiting for the Halo sign-in to complete"** - finish the browser sign-in within `-LoginTimeout` seconds, or increase it.
* **Browser doesn't open (remote session, SSH, headless host)** - copy the printed URL into a browser on the same machine. The redirect goes to `localhost`, so the browser must be on the machine running PowerShell. For headless or unattended use, choose client credentials instead.
* **"The Halo sign-in response state did not match the request"** - the browser returned from a different or stale sign-in attempt. Run `Connect-HaloAPI -Interactive` again and use the newly opened tab.
* Use `-Verbose` to see which step is running. Debug output only contains metadata (no tokens or secrets).

## Local Live and E2E Testing

Run test suites through the quality script entrypoints in `DevOps/Quality`.

For local `Live` and `E2E` runs, use the Key Vault wrapper script. It loads the required environment variables from Azure Key Vault before invoking `DevOps/Quality/test.ps1`.

1. Sign in to Azure first:

    ```PowerShell
    Connect-AzAccount
    ```

1. Run the `Live` suite:

    ```PowerShell
    pwsh -NoProfile -File .\DevOps\Quality\Invoke-HaloLiveTests.ps1 -Suite Live -Verbosity Normal
    ```

1. Run both `Live` and `E2E` in one invocation:

    ```PowerShell
    pwsh -NoProfile -File .\DevOps\Quality\Invoke-HaloLiveTests.ps1 -Suite Live,E2E -Verbosity Normal
    ```

The wrapper expects these secrets in Key Vault (default vault name: `MSPsUK`):

* `HaloTestingURL`
* `HaloTestingClientID`
* `HaloTestingClientSecret`
* `HaloTestingTenant`

For non-live suites, use the standard test entrypoint directly:

```PowerShell
pwsh -NoProfile -File .\DevOps\Quality\test.ps1 -Suite Meta,Unit -Verbosity Normal
```

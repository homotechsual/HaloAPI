# HaloAPI - A [PowerShell](https://microsoft.com/powershell) module for [Halo Service Solutions](https://haloservicesolutions.com/) software

[![Azure DevOps Pipeline Status](https://img.shields.io/azure-devops/tests/MSPsUK/HaloAPI/4?style=for-the-badge)](https://dev.azure.com/MSPsUK/HaloAPI/_build?definitionId=4)
[![Azure DevOps Code Coverage](https://img.shields.io/azure-devops/coverage/MSPsUK/HaloAPI/4?style=for-the-badge)](https://dev.azure.com/MSPsUK/HaloAPI/_build?definitionId=4)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/HaloAPI?style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![License](https://img.shields.io/github/license/homotechsual/HaloAPI?style=for-the-badge)](https://haloapi.mit-license.org/)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/homotechsual?style=for-the-badge)](https://github.com/sponsors/homotechsual/)
[![Stable Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Stable+Release&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![Preview Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Preview+Release&include_prereleases&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)

## Who are we?

We are Mikey O'Toole ([@homotechsual](https://github.com/homotechsual)) and Luke Whitelock ([@LWhitelock](https://github.com/lwhitelock)) we are both directors for (separate) UK-based managed IT services providers who share a passion for automation and good quality MSP software tools.

## What is this?

This is the code for a [PowerShell](https://microsoft.com/powershell) module for the [Halo Service Solutions](https://haloservicesolutions.com/) series of software, including:

* [HaloPSA](https://halopsa.com)
* [HaloITSM](https://haloitsm.com/)
* [HaloServiceDesk](https://haloservicedesk.com/)

The module is written for [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-71?view=powershell-7.1). **It is not compatible with Windows PowerShell 5.1 and never will be.**. This module is licensed under the [MIT](https://haloapi.mit-license.org/) license.

## What does it do?

HaloAPI provides a PowerShell wrapper around the Halo API, tested extensively against HaloPSA instances only (please test against HaloITSM or HaloServiceDesk instances and let us know how it works). The module can retrieve and send information to the Halo API.

## Installing

This module is published to the PowerShell Gallery and can be installed from within PowerShell with `Install-Module`

```PowerShell
Install-Module HaloAPI
```

## Getting Started

The first and probably most important requirement for this module is getting it connected to your Halo instance.

### Creating an API application in Halo

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

### Connecting the PowerShell module to the API

1. Install the HaloAPI PowerShell module on PowerShell 7.0 or above.  

    ```PowerShell
    Install-Module HaloAPI
    ```

1. Connect to the Halo API with `Connect-HaloAPI`  

    ```PowerShell
    Connect-HaloAPI -ClientID "a1234567-bcd8-9e01-2f34-56g7hijk89lm" -Tenant "demo" -URL "https://demo.halopsa.com" -ClientSecret "a1234567-bcd8-9e01-2f34-56g7hijk89lm-a1234567-bcd8-9e01-2f34-56g7hijk89lm" -Scopes "all"
    ```

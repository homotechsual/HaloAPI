# HaloAPI - A [PowerShell](https://microsoft.com/powershell) module for [Halo Service Solutions](https://haloservicesolutions.com/) software

[![Azure DevOps Pipeline Status](https://img.shields.io/azure-devops/tests/MSPsUK/HaloAPI/4?style=for-the-badge)](https://dev.azure.com/MSPsUK/HaloAPI/_build?definitionId=4)
[![Azure DevOps Code Coverage](https://img.shields.io/azure-devops/coverage/MSPsUK/HaloAPI/4?style=for-the-badge)](https://dev.azure.com/MSPsUK/HaloAPI/_build?definitionId=4)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/HaloAPI?style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![License](https://img.shields.io/github/license/homotechsual/HaloAPI?style=for-the-badge)](https://haloapi.mit-license.org/)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/homotechsual?style=for-the-badge)](https://github.com/sponsors/homotechsual/)
[![Stable Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Stable+Release&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)
[![Preview Release](https://img.shields.io/powershellgallery/v/HaloAPI?label=Preview+Release&include_prereleases&style=for-the-badge)](https://www.powershellgallery.com/packages/HaloAPI/)

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
*Generally speaking you want to limit the API to only the permissions it needs to do the job you're scripting for.*

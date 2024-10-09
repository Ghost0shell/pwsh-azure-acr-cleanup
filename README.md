# pwsh-azure-acr-cleanup

## Description

This script intend to be used through Azure function. It cleans a given acr registry from images older than 30 days.


## Prerequisites

### Service Principal

Create an Azure service principal with contributor permissions on the targer Azure Container Registry
Keep the Client ID and Secret on your side.

### Variables

Set the mandatories variables below in your Azure function environment variables

TARGET_REGISTRY_RG : The resource group where the ACR is hosted
TARGET_REGISTRY : The name of the target registry

CLIENT_ID : The client (application) id of the previously created SP
CLIENT_SECRET : The secret of the previously created SP
TENANT_ID : Your tenant ID

### AZ Cli

Please kindly note that AZ cli is not available by design in windows AZ function. In order to be
able to use it, you need to put the AZ Cli binaries in the storage account used to store your function app.<br/>
Example : put it in your SA/data/CLI2 and declare in your profile.ps1 <br/>
```Set-Alias -Name az -Value "c:\home\data\CLI2\bin\az.cmd``` <br/>


## Rules

The script will delete tags older than 30 days, except "latest" tag, and wont proceed any deletion if there is only one tag for a given image.



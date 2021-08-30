# Deploy Azure Agents

This repository will deploy the Azure Loganalytics agents to a list of computers.

## Pre-requisites

Update ComputerNames.txt with a list of dns names of all of the deployment targets. It should be one computer name per line.

e.g. 

```
server1.domain.com
server2
desktop5.domain.com
```

Update Install-ServiceMap.ps1 so that the parameters have the correct workspace id and key from the target Loganalytics workspace.

e.g.

```powershell
[CmdletBinding()]
Param (
    [parameter(Mandatory = $false)]
    [string] $WorkspaceId = "tp83ea3d-37a2-fake-uid-ec81942941f9",
    [parameter(Mandatory = $false)]
    [string] $WorkspaceKey = "rgSwO87u6rPn_FAKE_KEY_JcsJiIgK4I2Hzas8qxY_FAKE_KEY_pD+1nLO_FAKE_KEY_=="
)
```

## Run

Execute the run.ps1 to deploy to the list of computers.
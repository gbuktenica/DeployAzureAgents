<#
.SYNOPSIS
    This script will install and configure dependencies for ServiceMap
.DESCRIPTION
    This script will install and configure: TLS 1.2, Microsoft Dependency Agent and, Microsoft Monitoring Agent.
.EXAMPLE
    .\Install-ServiceMap.ps1 -WorkspaceId 'tp83ea3d-37a2-fake-uid-ec81942941f9' -WorkspaceKey 'rgSwO87u6rPn_FAKE_KEY_JcsJiIgK4I2Hzas8qxY_FAKE_KEY_pD+1nLO_FAKE_KEY_=='
.OUTPUTS
    None
.NOTES
    License      : MIT License
    Copyright (c): 2021 Glen Buktenica
    Release      : v2.0.1 20210520
#>
[CmdletBinding()]
Param (
    [parameter(Mandatory = $false)]
    [string] $WorkspaceId = "EnterWorkSpace_ID_Here",
    [parameter(Mandatory = $false)]
    [string] $WorkspaceKey = "EnterWorkSpace_KEY_Here"
)

# Configure TLS 1.2  (supported and enabled by default in windows server 2012 R2 and higher)
if (-not (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client")) {
    Write-Output "Installing TLS 1.2"
    if (-not (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2")) {
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" | Out-Null
    }
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name  Enabled -Value 0x00000001 -Force -PropertyType DWord | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name DisabledByDefault -Value 0x00000000 -Force -PropertyType DWord | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name SchUseStrongCrypto  -Value 0x00000001 -Force -PropertyType DWord | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" -Name SchUseStrongCrypto  -Value 0x00000001 -Force -PropertyType DWord | Out-Null
} else {
    Write-Output "TLS 1.2 already installed"
}

# Install Microsoft Monitoring Agent
# Instructions for downloading the Monitoring Agent https://docs.microsoft.com/en-us/services-hub/health/mma-setup
if (-not (Get-Service -Name 'HealthService' -ErrorAction 'SilentlyContinue')) {
    $MMAFilePath = ".\MMASetup-AMD64.exe"

    If (-not(Test-Path $MMAFilePath -PathType Leaf)) {
        Write-Verbose "Downloading Microsoft Monitoring Agent"
        Invoke-WebRequest "https://aka.ms/MonitoringAgentWindows" -OutFile $MMAFilePath
    }

    Write-Output "Installing Microsoft Monitoring Agent"
    Start-Process -FilePath $MMAFilePath -Wait -ArgumentList '/C:"setup.exe /qn AcceptEndUserLicenseAgreement=1"'
} else {
    Write-Output "Microsoft Monitoring Agent already installed"
}

# Install Microsoft Dependency Agent (ServiceMap)
# Instructions for the Dependency Agent https://docs.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-enable-hybrid
if (-not (Get-Service -Name 'MicrosoftDependencyAgent' -ErrorAction 'SilentlyContinue')) {
    $MDAFilePath = ".\InstallDependencyAgent-Windows.exe"

    If (-not(Test-Path $MDAFilePath -PathType Leaf)) {
        Write-Verbose "Downloading Microsoft Dependency Agent"
        Invoke-WebRequest "https://aka.ms/dependencyagentwindows" -OutFile $MDAFilePath
    }

    Write-Output "Installing Microsoft Dependency Agent"
    Start-Process -FilePath $MDAFilePath -ArgumentList "/S" -Wait
} else {
    Write-Output "Microsoft Dependency Agent already installed"
}


# Configure Workspace(s)
If ($WorkspaceId -and $WorkspaceKey) {
    Write-Output "Adding Workspace"
    $mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma.AddCloudWorkspace($WorkspaceId, $WorkspaceKey)
    $mma.ReloadConfiguration()
} Else {
    Write-Output "skipping workspace configuration as ID or Key missing"
}

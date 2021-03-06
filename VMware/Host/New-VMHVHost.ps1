#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new host

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Name
    Specifies a name for the new host

.Parameter LocationName
    Specifies a datacenter name or folder name where you want to place the host

.Parameter Port
    Specifies the port on the host you want to use for the connection

.Parameter HostCredential
    Specifies a PSCredential object that contains credentials for authenticating with the virtual machine host
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [int32]$Port,
    [pscredential]$HostCredential
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @("Name","Id","PowerState","ConnectionState","IsStandalone","LicenseKey")
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:location = Get-Folder -Server $Script:vmServer -Name $LocationName -ErrorAction Stop
    if($null -eq $Script:location){
        throw "Location $($LocationName) not found"
    }

    if($null -ne $HostCredential){
        if($Port -gt 0){
            $null = Add-VMHost -Server $Script:vmServer -Name $Name -Location $Script:location -Credential $HostCredential -Port $Port -Force:$true -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Add-VMHost -Server $Script:vmServer -Name $Name -Location $Script:location -Credential $HostCredential -Force:$true -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        if($Port -gt 0){
            $null = Add-VMHost -Server $Script:vmServer -Name $Name -Location $Script:location -Port $Port -Force:$true -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Add-VMHost -Server $Script:vmServer -Name $Name -Location $Script:location -Force:$true -Confirm:$false -ErrorAction Stop            
        }
    }

    $Script:Output = Get-VMHost -Server $Script:vmServer -Name $Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}
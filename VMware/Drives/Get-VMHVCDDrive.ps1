#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves virtual CD drives

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Drives

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the virtual machine from which you want to retrieve virtual CD drives

.Parameter TemplateName
    Specifies the virtual machine template from which you want to retrieve virtual CD drives

.Parameter SnapshotName
    Specifies the snapshot from which you want to retrieve virtual CD drives

.Parameter DriveName
    Specifies the name of the CD drive you want to retrieve, is the parameter empty all cd drives retrieved
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]    
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$DriveName
)

Import-Module VMware.PowerCLI

try{
    if([System.String]::IsNullOrWhiteSpace($DriveName) -eq $true){
        $DriveName = "*"
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "Snapshot"){
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
        $snap = Get-Snapshot -Server $Script:vmServer -Name $SnapshotName -VM $vm -ErrorAction Stop
        $Script:Output = Get-CDDrive -Server $Script:vmServer -Snapshot $snap -Name $DriveName -ErrorAction Stop | Select-Object *
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Template"){
        $temp = Get-Template -Server $Script:vmServer -Name $TemplateName -ErrorAction Stop
        $Script:Output = Get-CDDrive -Server $Script:vmServer -Template $temp -Name $DriveName -ErrorAction Stop | Select-Object *
    }
    else {
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop        
        $Script:Output = Get-CDDrive -Server $Script:vmServer -VM $vm -Name $DriveName -ErrorAction Stop | Select-Object *
    }

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
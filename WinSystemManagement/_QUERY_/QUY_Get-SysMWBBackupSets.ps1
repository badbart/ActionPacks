#Requires -Version 5.1

<#
.SYNOPSIS
    Gets backups for a server from a location that you specify

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Backup

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:result
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:result = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-WBBackupSet | Select-Object @("BackupTime","BackupSetID")
            } -ErrorAction Stop
        }
        else {
            $Script:result = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                Get-WBBackupSet | Select-Object $Using:props
            } -ErrorAction Stop
        }
    }
    else {
        $Script:result = Get-WBBackupSet | Select-Object $Script:props
    }
    
    foreach($item in $Script:result)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.BackupSetID
            $SRXEnv.ResultList2 += $item.BackupTime # Display
        }
        else{
            Write-Output $item.BackupTime
        }
    }
}
catch{
    throw
}
finally{
}
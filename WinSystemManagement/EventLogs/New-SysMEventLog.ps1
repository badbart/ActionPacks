#Requires -Version 4.0

<#
.SYNOPSIS
    Creates a new event log and a new event source on the computer 

.DESCRIPTION
    When you create a new event log and a new event source, the system registers the new source for the new log, but the log is not created until the first entry is written to it

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/EventLogs

.Parameter LogName
    Specifies the event log

.Parameter SourceName
    Specifies the names of the event log sources, such as application programs that write to the event log

.Parameter ComputerName
    Specifies remote computer, the default is the local computer.

.Parameter CategoryResourceFile
    Specifies the path of the file that contains category strings for the source events

.Parameter MessageResourceFile
    Specifies the path of the file that contains message formatting strings for the source events

.Parameter ParameterResourceFile
    Specifies the path of the file that contains strings used for parameter substitutions in event descriptions
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LogName,
    [Parameter(Mandatory = $true)]
    [string]$SourceName,
    [string]$ComputerName,
    [string]$CategoryResourceFile,
    [string]$MessageResourceFile,
    [string]$ParameterResourceFile
)

try{
    [string[]]$Properties = @("Log","LogDisplayName","MaximumKilobytes","OverflowAction","MinimumRetentionDays")
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }   
    if(-not [System.String]::IsNullOrWhiteSpace($CategoryResourceFile)){
        if((-not [System.String]::IsNullOrWhiteSpace($MessageResourceFile)) -and `
            (-not [System.String]::IsNullOrWhiteSpace($ParameterResourceFile))){
                New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName -CategoryResourceFile $CategoryResourceFile `
                    -ParameterResourceFile $ParameterResourceFile -MessageResourceFile $MessageResourceFile -ErrorAction Stop 
        }    
        elseif(-not [System.String]::IsNullOrWhiteSpace($MessageResourceFile)){
            New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName `
                -CategoryResourceFile $CategoryResourceFile  -MessageResourceFile $MessageResourceFile -ErrorAction Stop 
        }
        elseif(-not [System.String]::IsNullOrWhiteSpace($ParameterResourceFile)){
            New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName `
                -ParameterResourceFile $ParameterResourceFile -CategoryResourceFile $CategoryResourceFile -ErrorAction Stop 
        }
        else {
            New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName `
                -CategoryResourceFile $CategoryResourceFile -ErrorAction Stop 
        }
    }
    elseif(-not [System.String]::IsNullOrWhiteSpace($MessageResourceFile)){
        if(-not [System.String]::IsNullOrWhiteSpace($ParameterResourceFile)){
            New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName `
                -ParameterResourceFile $ParameterResourceFile -MessageResourceFile $MessageResourceFile -ErrorAction Stop    
        }
        else {
            New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName -MessageResourceFile $MessageResourceFile -ErrorAction Stop    
        }
    }
    elseif(-not [System.String]::IsNullOrWhiteSpace($ParameterResourceFile)){
        New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName -ParameterResourceFile $ParameterResourceFile -ErrorAction Stop
    }
    else{   
        New-EventLog -ComputerName $ComputerName -Source $SourceName -LogName $LogName -ErrorAction Stop
    }    
    $Script:output = Get-EventLog -List -ComputerName $ComputerName | Where-Object -Property "Log" -eq $LogName  | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}
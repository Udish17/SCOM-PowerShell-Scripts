#This script is created by Microsoft Support Professional Udish Mudiar.
#The script takes a monitor and an instance as parameters and reset the health of the monitor (to healthy) for that instance only.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [String]$MonitorDisplayName,
    [Parameter(Mandatory=$True)]
    [String]$InstanceName
)

#$MonitorDisplayName="Francesco Service Monitor New"
#$InstanceName="SCORCH2016.nfs.lab"
 
Import-Module OperationsManager 


#Get the monitor.
#We will only check for unit monitors. Aggreate and Dependency should rollup automatically.
$Monitor=Get-SCOMMonitor -DisplayName $MonitorDisplayName | Where-Object {$_.XmlTag -eq "UnitMonitor"}
    
#Get the class ID to which the monitor is targeted
$ClassID=($monitor).Target.Id.Guid
 
#Get the instance to which the monitor is targeted. Only get Critical and Warning states
$Instance=Get-SCOMClass -id $classID | Get-SCOMClassInstance | Where-Object {($_.path -eq $InstanceName) -and {($_.healthstate -ne ‘Success’) -and ($_.healthstate -ne ‘Uninitialized’) -and ($_.IsAvailable -eq $true)} }
 
#Reset the state associated with this specific monitor for the specific instance
$Instance.ResetMonitoringState($Monitor)
 
  
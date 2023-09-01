# The script will get the reasons of all the SCX heartbeat alert of all the agents managed by a Resource Pool and export to CSV
# Author
# Udishman Mudiar (Udish)

 
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [String]$Path,
    [Parameter(Mandatory=$True)]
    [String]$ResourcePoolName
)

#$ResourcePoolName = "Unix/Linux Resource Pool"

$Objects = @()
$OpenHeartbeatAlerts = @()

Import-Module OperationsManager

$ResourcePool = Get-SCOMResourcePool -DisplayName $ResourcePoolName

$SCXAgentsManagedByResourcePool = Get-SCXAgent -ResourcePool $ResourcePool

$AllOpenHeartbeatAlerts = Get-SCOMAlert -Name "Heartbeat Failed" -ResolutionState 0

foreach($OpenHeartbeatAlert in $AllOpenHeartbeatAlerts)
{
    $SCXInstanceid = $OpenHeartbeatAlert.MonitoringObjectId.Guid
    $SCXInstance = Get-SCOMClassInstance -Id $SCXInstanceid

    foreach($SCXAgentManagedByResourcePool in $SCXAgentsManagedByResourcePool)
    {
        if($SCXAgentManagedByResourcePool.Name -eq $SCXInstance.DisplayName)
        {
            $OpenHeartbeatAlerts += $OpenHeartbeatAlert
        }
    }
}

foreach($OpenHeartbeatAlert in $OpenHeartbeatAlerts)
{
    #get the monitoring object
    $SCXInstanceid = $OpenHeartbeatAlert.MonitoringObjectId.Guid
    $SCXInstance = Get-SCOMClassInstance -Id $SCXInstanceid
    
    #get the error message from context which is an xml document
    [xml]$context = $OpenHeartbeatAlert.Context    
    $ErrorMessage = $context.DataItem.Context.DataItem.WsManData.ErrorMessage.WSManFault.Message

   
    $Object = [PSCustomObject]@{
        SCXAgent = $SCXInstance.DisplayName
        ErrorMessage = ($ErrorMessage | Out-String).Trim()
    }
    
    [PSCustomObject]$Objects += $Object
}

#$Objects | Out-GridView
#$Objects | fl * 
$Objects | Export-Csv -Path $Path\heartbeatreasondetails.csv


#script to test the primary and failover management server/gateway for a SINGLE agent
Import-Module OperationsManager
$Agents = Get-SCOMAgent -DNSHostName "agent.domain.com"
$Agents | Sort-Object | ForEach-Object 
{ 
    Write-Host ""; 
    "Agent :: " + $_.Name; 
    "–Primary MS :: " + ($_.GetPrimaryManagementServer()).ComputerName; 
    $failoverServers = $_.getFailoverManagementServers(); 
    foreach ($managementServer in $failoverServers) 
    { 
        "–Failover MS :: " + ($managementServer.ComputerName); 
    } 
} 
Write-Host ""; 

#script to test the primary and failover management server/gateway for the agents pointed to a specific management server/gateway
Import-Module OperationsManager
$agents=Get-SCOMAgent -ManagementServer (Get-SCOMManagementServer -Name "gateway.domain.com")
foreach ($agent1 in $agents)
{
    $Agents = Get-SCOMAgent -DNSHostName $agent1.DisplayName
    $Agents | Sort-Object | ForEach-Object 
    { 
        Write-Host ""; 
        "Agent :: " + $_.Name; 
        "–Primary MS :: " + ($_.GetPrimaryManagementServer()).ComputerName; 
        $failoverServers = $_.getFailoverManagementServers(); 
        foreach ($managementServer in $failoverServers) { 
        "–Failover MS :: " + ($managementServer.ComputerName); 
    } 
} 
Write-Host "";
}
 

#script to test the primary and failover management server/gateway for multiple agents
Import-Module OperationsManager
$agents=@("agent1.domain.com", "agent2.domain.com")
foreach ($agent1 in $agents)
{
    $Agents = Get-SCOMAgent -DNSHostName $agent1
    $Agents | Sort-Object | ForEach-Object  
    { 
        Write-Host ""; 
        "Agent :: " + $_.Name; 
        "–Primary MS :: " + ($_.GetPrimaryManagementServer()).ComputerName; 
        $failoverServers = $_.getFailoverManagementServers(); 
        foreach ($managementServer in $failoverServers) 
        { 
            "–Failover MS :: " + ($managementServer.ComputerName); 
        } 
    } 
Write-Host "";
}
 
 
 
#script to set the primary and failover management server/gateway for an agent
Import-Module OperationsManager
$primaryMS = Get-SCOMManagementServer -Name "<FQDN of primary server>" 
$failoverMS = Get-SCOMManagementServer -Name "<FQDN of 1st failover>","<FQDN of 2nd failover>",...,"<FQDN of nth failover>" 
$agent = Get-SCOMAgent -DNSHostName "agent.domain.com” 
Set-SCOMParentManagementServer -Agent $agent -PrimaryServer $primaryMS 
Set-SCOMParentManagementServer -Agent $agent -FailoverServer $failoverMS  
 
 
#script to set the primary and failover management server/gateway for all agents pointed to a management server/gateway
Import-Module OperationsManager
$agents=Get-SCOMAgent -ManagementServer (Get-SCOMManagementServer -Name "gateway.domain.com")
$agents1=$agents.displayname
$primaryMS = Get-SCOMManagementServer -Name "<FQDN of primary server>" 
$failoverMS = Get-SCOMManagementServer -Name "<FQDN of 1st failover>","<FQDN of 2nd failover>",...,"<FQDN of nth failover>" 
foreach($agent2 in $agents1)
{
    $agent = Get-SCOMAgent -DNSHostName $agent2       
    Write-host "Setting the primary for agent $agent2" -ForegroundColor Yellow
    Set-SCOMParentManagementServer -Agent $agent -PrimaryServer $primaryMS 
    Write-host "Setting the failover for agent $agent2" -ForegroundColor Cyan
    Set-SCOMParentManagementServer -agent $agent  -FailoverServer $failoverMS
} 
 
 
#script to set the primary and failover management server/gateway for multiple agents
Import-Module OperationsManager
$agents1=@("agent1.domain.com", "agent2.domain.com")
$primaryMS = Get-SCOMManagementServer -Name "<FQDN of primary server>" 
$failoverMS = Get-SCOMManagementServer -Name "<FQDN of 1st failover>","<FQDN of 2nd failover>",...,"<FQDN of nth failover>" 
foreach($agent2 in $agents1)
{
    $agent = Get-SCOMAgent -DNSHostName $agent2
    Write-host "Setting the primary for agent $agent2" -ForegroundColor Yellow
    Set-SCOMParentManagementServer -Agent $agent -PrimaryServer $primaryMS 
    Write-host "Setting the failover for agent $agent2" -ForegroundColor Cyan
    Set-SCOMParentManagementServer -agent $agent  -FailoverServer $failoverMS
} 
 
 
 
#script to set the primary and failover management server/gateway for multiple agents
Import-Module OperationsManager
$agents1=@("agent1.domain.com", "agent2.domain.com")
$primaryMS = Get-SCOMManagementServer -Name "<FQDN of primary server>" 
$failoverMS = Get-SCOMManagementServer -Name "<FQDN of 1st failover>","<FQDN of 2nd failover>",...,"<FQDN of nth failover>" 
foreach($agent2 in $agents1)
{
    $agent = Get-SCOMAgent -DNSHostName $agent2
    #$agent   
    Write-host "Setting the primary for agent $agent2" -ForegroundColor Yellow
    Set-SCOMParentManagementServer -Agent $agent -PrimaryServer $primaryMS 
    Write-host "Setting the failover for agent $agent2" -ForegroundColor Cyan
    Set-SCOMParentManagementServer -agent $agent  -FailoverServer $failoverMS
} 
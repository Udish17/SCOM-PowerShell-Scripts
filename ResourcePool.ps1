#This script is a collection of all the Resource Pool related cmdlets which I use to troubleshoot Resource Pool issues.
#First things first, import the operations manager modules to use the SCOM cmdlets
Import-Module OperationsManager

#Get all resource pools in the current Management Group
Get-SCOMResourcePool

#Get a specific resource pool
Get-SCOMResourcePool -DisplayName "All Management Servers Resource Pool"

#Get the members, observers and also whether default observer is enabled or not
Get-SCOMResourcePool | Select-Object Name, members, Observers, UseDefaultObserver

#Change membership type of a Resource Pool from "Automatic" to "Manual" 
Get-SCOMResourcePool -DisplayName “Notifications Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 0
Get-SCOMResourcePool –DisplayName “All Management Servers Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 0
Get-SCOMResourcePool –DisplayName “AD Assignment Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 0

#Change membership type of a Resource Pool from "Manual" to "Automatic" 
Get-SCOMResourcePool –DisplayName “Notifications Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 1
Get-SCOMResourcePool –DisplayName “All Management Servers Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 1
Get-SCOMResourcePool –DisplayName “AD Assignment Resource Pool” | Set-SCOMResourcePool –EnableAutomaticMembership 1

#To add or remove Management Servers or Gateways from a manual pool
$pool = Get-SCOMResourcePool -DisplayName "Your Pool Name"
$MS = Get-SCOMManagementServer -Name "YourMSorGW.domain.com"
$pool | Set-SCOMResourcePool -Member $MS -Action "Add" 
$pool | Set-SCOMResourcePool -Member $MS -Action "Remove"

#To add or remove Management Servers or Gateways as Observers only to a pool
$pool = Get-SCOMResourcePool -DisplayName "Your Pool Name"
$Observer = Get-SCOMManagementServer -Name "YourMSorGW.domain.com"
$pool | Set-SCOMResourcePool -Observer $Observer -Action "Add"
$pool | Set-SCOMResourcePool -Observer $Observer -Action "Remove"

#Get the members of each resource pool 
$ResourcePools=Get-SCOMResourcePool  # -DisplayName "All Management Servers Resource Pool"
 
foreach ($ResourcePool in $ResourcePools)
{
    $members=$ResourcePool | Select-Object Members
    $members1=$members.members
    $managementservers=$members1.displayname
    Write-Host $ResourcePool.DisplayName -ForegroundColor Cyan
    $managementservers
    Write-Host "---------------------------------------------------------------" -ForegroundColor Green 
} 

#Check the number of resource pools a management server/gateway is a part of
#For a single managementserver
$Member = Get-SCOMManagementServer -Name “FQDN”
$Pools = Get-SCOMResourcePool -Member $Member
$Member.DisplayName
$Pools.DisplayName
#For all management servers
$Members = Get-SCOMManagementServer
foreach ($member in $members)
{
    write-host “”
    $Pools = Get-SCOMResourcePool -Member $Member
    write-host “Management Server – “$Member.DisplayName -ForegroundColor Cyan
    $Pools.DisplayName
}



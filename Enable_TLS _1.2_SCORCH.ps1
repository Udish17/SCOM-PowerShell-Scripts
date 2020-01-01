#Author: Udishman (Udish) Mudiar
#Version : 1.0
#This script will check for pre-requisites to enable TLS 1.2.
#Check the Orchestrator version and verify if any orchestrator patching is required.
#Does not need to install the pre-requisites as SQL Native Client will be need provided the SCORCH infrastructure is TLS 1.2 supported.
#Check if the SQL version hosting SCORCH database is compatible with TLS 1.2
#Enable all TLS registires as per the article below.
#https://docs.microsoft.com/en-us/system-center/orchestrator/install-enable-tls?view=sc-orch-2019
#Reboot the machine for TLS to take effect.

#region LogtoFile
function LogToFile() 
{
    param (
        [Parameter(Mandatory=$true)][string]$message,    
        [validateset("InfoG", "InfoR", "Warning", "Error")][string]$messagetype
    )

    function Green
    {
        process { Write-Host $_ -ForegroundColor Green }
    }

    function Red
    {
        process { Write-Host $_ -ForegroundColor Red }
    }
    
    $date = Get-Date -Format g
    if($messagetype -eq "InfoG")
    {
        $output= "$message [$messagetype] [$date]"
        Write-Output $output | Green
        Start-Sleep 2
    }
    elseif($messagetype -eq "InfoR")
    {
        $output= "$message [$messagetype] [$date]"
        Write-Output $output | Red
        Start-Sleep 2
    }
    elseif($messagetype -eq "Warning")
    {
        $output= "$message [$messagetype] [$date]"
        Write-Warning $output
        Start-Sleep 2
    }
    elseif($messagetype -eq "Error")
    {
        $output= "$message [$messagetype] [$date]"
        Write-Error $output -ErrorAction Stop
        Start-Sleep 2
    }
}
#endregion

#region Get-SCORCHComponents
Function Get-SCORCHComponents()
{
    Write-host "------------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Checking for the SCORCH components installed on the machine. Only Management Server, Runbook Server and Runbook Desginer should have TLS 1.2 .." -ForegroundColor Cyan
    Start-Sleep 2
    $location=Read-Host "`nIs your SCORCH installed in the default location?(C:\Program Files (x86)) (Y/N)"
    if($location -eq "Y")
    {
        $SCORCH2012R2Path="C:\Program Files (x86)\Microsoft System Center 2012 R2\Orchestrator"
        $OtherSCORCHPath="C:\Program Files (x86)\Microsoft System Center\Orchestrator"
        if(Test-Path $SCORCH2012R2Path)
        {
            $SCORCHComponentsInstalled=Get-ChildItem -Path $SCORCH2012R2Path
            $path=$SCORCH2012R2Path
        }
        elseif(Test-Path $OtherSCORCHPath)
        {
            $SCORCHComponentsInstalled=Get-ChildItem -Path $OtherSCORCHPath
            $path=$OtherSCORCHPath
        }
        else 
        {
            LogToFile -message "`nNo SCORCH component found in default path. Exiting.." -messagetype "InfoR"
            Start-Sleep 2
            Exit
        }
    }
    else {
        $SCORCHPath=Read-Host "`nEnter your full SCORCH installation path. E.x: C:\Program Files (x86)\Microsoft System Center\Orchestrator"
        if(Test-Path $SCORCHPath)
        {
            $SCORCHComponentsInstalled=Get-ChildItem -Path $SCORCHPath
            $path=$SCORCHPath
        }
        else 
        {
            LogToFile -message "`nNo SCORCH component found in given path. Exiting.." -messagetype "InfoR"
            Start-Sleep 2
            Exit
        }
    }    
    
    $componentsfound=@()
    foreach($SCORCHComponentInstalled in $SCORCHComponentsInstalled)
    {
        if($SCORCHComponentInstalled.Name -eq "Management Server" )
        {
             if(Get-Item -Path "$path\management server\ManagementService.exe" -ErrorAction SilentlyContinue)
             {
                $componentsfound += $SCORCHComponentInstalled.Name 
             }
        }
        elseif($SCORCHComponentInstalled.Name -eq "Runbook Server")
        {
             if(Get-Item -Path "$path\runbook server\RunbookService.exe" -ErrorAction SilentlyContinue)
             {
                $componentsfound += $SCORCHComponentInstalled.Name 
             }
        } 
        elseif($SCORCHComponentInstalled.Name -eq "Runbook Designer" )
        {
             if(Get-Item -Path "$path\runbook designer\runbookDesigner.exe" -ErrorAction SilentlyContinue)
             {
                $componentsfound += $SCORCHComponentInstalled.Name 
             }
        }          
    }
    
    if($componentsfound -ne $null)
    {
        for($i=0;$i -lt $componentsfound.Count; $i++)
        {
            Write-host "`nPassed: $($componentsfound["$i"]) is found" -ForegroundColor Green           
        }  
        Write-Host "--------------------------------------------------------------------------------------------------------------------------"      
    }
    else
    {
        LogToFile -message "`nNo Orchestrator Components found in the machine $(hostname). Exiting.. " -messagetype "InfoR"
        Start-Sleep 2
        Exit
    }

    Get-SCORCHVersion
}
#endregion 

#region Get-FileVersion
Function Get-FileVersion($filepath)
{
    try {
        $VersionInfo = (Get-Item $filepath).VersionInfo
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        LogToFile -Message $ErrorMessage -messagetype "Error"
    }
    
    $FileVersion = ("{0}.{1}.{2}.{3}" -f $VersionInfo.FileMajorPart, 
    $VersionInfo.FileMinorPart, 
    $VersionInfo.FileBuildPart, 
    $VersionInfo.FilePrivatePart)
    Get-SCORCHVersionList($FileVersion)
}
#endregion

#region Get-SCORCHVersion
Function Get-SCORCHVersion()
{
    foreach($component in $componentsfound)
    {
        #The logic here is to check the version of the component and if any of the component is found that the other components are not checked assuming we have the same patch for each component.
        #The script is not to validate whether proper patching is been done.
        $SCORCH2012R2Path="C:\Program Files (x86)\Microsoft System Center 2012 R2\Orchestrator"
        $OtherSCORCHPath="C:\Program Files (x86)\Microsoft System Center\Orchestrator"
        if($component -eq "Management Server")
        {
            if(Test-Path $SCORCH2012R2Path)
            {
               $SCORCHMSFilePath="C:\Program Files (x86)\Microsoft System Center 2012 R2\Orchestrator\Management Server\ManagementService.exe"
               Get-FileVersion($SCORCHMSFilePath)
               break;                
            }
            elseif(Test-Path $OtherSCORCHPath)
            {
                $SCORCHMSFilePath="C:\Program Files (x86)\Microsoft System Center\Orchestrator\Management Server\ManagementService.exe"
                Get-FileVersion($SCORCHMSFilePath)
                break;                 
            }
        }
        if($component -eq "Runbook Server")
        {
            if(Test-Path $SCORCH2012R2Path)
            {
               $SCORCHRBSFilePath="C:\Program Files (x86)\Microsoft System Center 2012 R2\Orchestrator\Management Server\runbookservice.exe"
               Get-FileVersion($SCORCHMSFilePath)
               break;                
            }
            elseif(Test-Path $OtherSCORCHPath)
            {
                $SCORCHRBSFilePath="C:\Program Files (x86)\Microsoft System Center\Orchestrator\runbook server\runbookservice.exe"
                Get-FileVersion($SCORCHRBSFilePath)
                break;                 
            }
        }
        if($component -eq "Runbook Designer")
        {
            
            if(Test-Path $SCORCH2012R2Path)
            {
               $SCORCHRBDFilePath="C:\Program Files (x86)\Microsoft System Center 2012 R2\Orchestrator\Management Server\runbookdesigner.exe"
               Get-FileVersion($SCORCHMSFilePath)
               break;                
            }
            elseif(Test-Path $OtherSCORCHPath)
            {
                $SCORCHRBDFilePath="C:\Program Files (x86)\Microsoft System Center\Orchestrator\runbook designer\runbookdesigner.exe"
                Get-FileVersion($SCORCHRBDFilePath)
                break;                 
            }
        }
     }    
}
#endregion

#region Get-SCORCHVersionList
Function Get-SCORCHVersionList($version)
{
    Write-Host "Checking for TLS 1.2 compatible SCORCH version .." -ForegroundColor Cyan
    Start-Sleep 2
    $versionlookuptables=@{SCORCH2019="10.19.40.0";SCORCH1801="7.4.145.0";SCORCH1807="7.4.188.0";SCORCH2016UR4="7.3.185.0";SCORCH2016UR5="7.3.273.0";SCORCH2016UR6="7.3.285.0";SCORCH2016UR7="7.3.310.0";SCORCH2016UR8="7.3.327.0";SCORCH2012R2UR14="7.2.239.0"}
    $versionlookuptables=$versionlookuptables.GetEnumerator() | Sort-Object Name
    #$versionlookuptables.gettype()
    foreach($versionlookuptable in $versionlookuptables)
    {  
        if($versionlookuptable.value -eq $version)
            {              
                $compatibleversion="Matched"
                LogToFile  -message "`nPassed: SCORCH version is compatible with TLS 1.2. Current version is $($versionlookuptable.name)" -messagetype "InfoG"
                Start-Sleep 2   
            }     
    }
  
    if(!$compatibleversion)
    {
            LogToFile -message "`nFailed: SCORCH version is not compatible with TLS 1.2. Exiting .." -messagetype "InfoR"
            Start-Sleep 2
            Exit
    }
}
#endregion

#region Get-DotNetVersion
Function Get-DotNetVersion()
{
    Write-host "--------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Checking .Net Framework Version is 4.6 or later .." -ForegroundColor Cyan
    Start-Sleep 2
       $Lookups = ConvertFrom-Csv 'Version|Release
    4.5|378389
    4.5.1|378675
    4.5.1|378758
    4.5.2|379893
    4.6|393295
    4.6|393297
    4.6.1|394254
    4.6.1|394271
    4.6.2|394802
    4.6.2|394806
    4.7|460798
    4.7|460805
    4.7.1|461308
    4.7.1|461310
    4.7.2|461814
    4.8|528049
    ' -Delimiter "|"

    try {
        $value=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        LogToFile -message ".Net Registry not found" -messagetype "InfoR"
        LogToFile -Message $ErrorMessage -messagetype "Error"
    }
    
    $value=$value.Release
    foreach($lookup in $lookups)
    {   
       if($value -eq $lookup.release) 
       {            
            $DotNetversion=$lookup.version
       }
    }

    if($DotNetversion -ne $Null)
    {
        
       LogToFile -message "`nPassed: .Net version installed is greater than 4.6. Current version: $($lookup.version)" -messagetype "InfoG"
        Start-Sleep 2
    }
    else
    {
        LogToFile -message "Failed: .Net version is less than 4.6. Exiting script.." -messagetype "InfoR"
        Start-Sleep 2
    }
}
#endregion

#region Check-PreRequisitesSoftware
Function Check-PreRequisitesSoftware()
{
    Write-host "--------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Checking if SQL Native Client 2012 or later is installed .." -ForegroundColor Cyan
    Start-Sleep 2
    try {
        $SQLNativeClient=(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SQLNCLI11").InstalledVersion
    }
    catch {
        LogToFile -message "SQL Native Client Registry not found" -messagetype "InfoR"
        LogToFile -Message $ErrorMessage -messagetype "Error"
    }
    

    If($SQLNativeClient)
    {
        if($SQLNativeClient -ge 11.0)
        {
            
            LogToFile -message "`nPassed: SQL Server 2012 Native client 11.0 or later is installed." -messagetype "InfoG"
            Start-Sleep 2
        }
    }
    else
    {
        Write-host "--------------------------------------------------------------------------------------------------------------------------"
        LogToFile -message "Warning: SQL Native Client 2012 is not installed" -messagetype "Warning"
        Start-Sleep 2
    }
}
#endregion

#region Check-SQLVersion
Function Get-SQLVersion(){

    Write-host "--------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Checking if SQL instance hosting Orchestrator database in TLS 1.2 compatible.. `n" -ForegroundColor Cyan
    Start-Sleep 2
    Function SQLQueryExecution()
    {
        try{
                #Getting the SQL version by running a query against the SCORCH SQL instance
                $dataSource = Read-Host "Enter the SQL Instance name hosting the SCORCH database e.g: SQL\Instance"
                $database = Read-Host "Enter the SCORCH database name e.g: Orchestrator"
                $connectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"

                $connection = New-Object System.Data.SqlClient.SqlConnection
                $connection.ConnectionString = $connectionString

                $connection.Open()

                $query = "SELECT SERVERPROPERTY('ProductVersion') AS 'Version'"

                $command = $connection.CreateCommand()
                $command.CommandText = $query

                $result = $command.ExecuteReader()

                $global:table = new-object "System.Data.DataTable"
                $table.Load($result)
                $connection.Close()                                
           }
        catch{
                $ErrorMessage = $_.Exception.Message  
                LogToFile -message $ErrorMessage -messagetype "Error"                            
            }             
    }
        
    #Calling SQL query to get the version
    SQLQueryExecution                   
    if($table -eq $null)
    {
        LogToFile -message "Unable to fetch SQL version. Exiting script.." -messagetype "InfoR"
        Start-Sleep 2
        Exit
    }
    else 
    {
        $splitvalue=$table.version.split('.')
        $MajorVersion=$splitvalue[0]
        $MinorVersion=$splitvalue[2]
    
        #Checking the SQL version TLS compatibility according to the below article
        #https://support.microsoft.com/en-in/help/3135244/tls-1-2-support-for-microsoft-sql-server
        if($MajorVersion -ge 13)
        {
            Logtofile -message "`nPassed: SQL version is greater than or equal to 2016 and supports TLS 1.2 out-of-box." -messagetype "InfoG"
            Start-Sleep 2       
        }
        elseif($MajorVersion -eq 12)
        {
            if(4439 -ge $MinorVersion -le 4522)
            {
                Logtofile -message "`nPassed: SQL version is 2014 SP1 CU5 or higher and supports TLS 1.2" -messagetype "InfoG"    
                Start-Sleep 2        
            }
            elseif(4219 -ge $MinorVersion -le 4237)
            {
                Logtofile -message "`nPassed: SQL version is 2014 SP1 GDR or higher and supports TLS 1.2" -messagetype "InfoG" 
                Start-Sleep 2            
            }
            elseif(2564 -ge $MinorVersion -le 2569)
            {
                Logtofile -message "`nPassed: SQL version is 2014 RTM or higher and supports TLS 1.2" -messagetype "InfoG"    
                Start-Sleep 2        
            }
            elseif($MinorVersion -eq 2271)
            {
                Logtofile -message "`nPassed: SQL version is 2014 RTM GDR and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2            
            }
        }
        elseif($MajorVersion -eq 11)
        {
            if(6216 -ge $MinorVersion -le 6615)
            {
                Logtofile -message "`nPassed: SQL version is 2012 SP3 GDR and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(6518 -ge $MinorVersion -le 6598)
            {
                Logtofile -message "`nPassed: SQL version is 2012 SP3 CU and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(5352 -ge $MinorVersion -le 5388)
            {
                Logtofile -message "`nPassed: SQL version is 2012 SP2 GDR and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2            
            }
            elseif(5644 -ge $MinorVersion -le 5678)
            {
                Logtofile -message "`nPassed: SQL version is 2012 SP2 CU and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2            
            }
        }
        elseif($MajorVersion -eq 10)
        {
            if(6542 -ge $MinorVersion -le 6560)
            {
                Logtofile -message "`nPassed: SQL version is 2008 R2 SP3 (x86/x64 only) and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(4046 -ge $MinorVersion -le 4047)
            {
                Logtofile -message "`nPassed: SQL version is 2008 R2 SP2 GDR (IA-64 only) and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(4343 -ge $MinorVersion -le 4344)
            {
                Logtofile -message "`nPassed: SQL version is 2008 R2 SP2 CU (IA-64 only) and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(6547 -ge $MinorVersion -le 6556)
            {
                Logtofile -message "`nPassed: SQL version is 2008 SP4 and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
            elseif(5544 -ge $MinorVersion -le 5545)
            {
                Logtofile -message "`nPassed: SQL version is 2008 SP3 GDR (IA-64 only) and supports TLS 1.2" -messagetype "InfoG" 
                Start-Sleep 2            
            }
            elseif(5894 -ge $MinorVersion -le 5896)
            {
                Logtofile -message "`nPassed: SQL version is 2008 SP3 CU (IA-64 only) and supports TLS 1.2" -messagetype "InfoG"
                Start-Sleep 2             
            }
        } 
        else {
            LogToFile -message "`n Failed: SQL version is not TLS 1.2 compatible. Exiting.." -messagetype "InfoR"
            Start-Sleep 2
            Exit
        }   
    }
    
}
#endregion

#region Enable-TLS1.2
Function Enable-TLS1.2()
{
    Write-host "--------------------------------------------------------------------------------------------------------------------------"
    $temp=Read-Host "Do you want to enable TLS 1.2? (Y/N)"
    if($temp -eq "N")
    {
        LogToFile -message "Exiting Script.." -messagetype "InfoR"
        Start-Sleep 2
        Exit
    }
    else {
            Write-Host "`nEnabling TLS 1.2 registries.." -ForegroundColor Cyan
            Start-Sleep 2
            
            Write-Host "`nBacking up TLS registries before modifying them. The Path is"  -ForegroundColor Yellow
            
            try {
                New-Item -ItemType Directory -path (Get-Location).Path -Name "Registrybackup_($(Get-Date -Format MM-dd-yyyy_HH_mm_ss))" | Out-Null
            }
            catch {
                 LogToFile -message "Unable to create registry backup folder" -messagetype "InfoR"
                 LogToFile -Message $ErrorMessage -messagetype "Error"`
            }                      
            $PSPath=(Get-ChildItem -Path (Get-Location).Path -Directory -Filter registry* | Sort-Object -Descending | Select-Object -first 1).fullname
            Write-Host $pspath
            Reg export HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols $pspath\Protocols.reg
            Reg export HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 $pspath\v4030319.reg
            Reg export HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319 $pspath\WOW6432Nodev4030319.reg
            Reg export HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 $pspath\v2050727.reg
            Reg export HKLM\Software\Wow6432Node\Microsoft\.NETFramework\v2.0.50727 $pspath\WOW6432Nodev2050727.reg

            #Copied this section from the official TLS1.2 documentation
            ##https://docs.microsoft.com/en-us/system-center/orchestrator/install-enable-tls?view=sc-orch-2019
            $ProtocolList       = @("SSL 2.0","SSL 3.0","TLS 1.0", "TLS 1.1", "TLS 1.2")
            $ProtocolSubKeyList = @("Client", "Server")
            $DisabledByDefault = "DisabledByDefault"
            $Enabled = "Enabled"
            $registryPath = "HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\"

            foreach($Protocol in $ProtocolList)
            {
            foreach($key in $ProtocolSubKeyList)
                {		
                $currentRegPath = $registryPath + $Protocol + "\" + $key
                #Write-Host " Current Registry Path $currentRegPath"

                if(!(Test-Path $currentRegPath))
                {
                    New-Item -Path $currentRegPath -Force | out-Null			
                }
                if($Protocol -eq "TLS 1.2")
                {
                    New-ItemProperty -Path $currentRegPath -Name $DisabledByDefault -Value "0" -PropertyType DWORD -Force | Out-Null
                    New-ItemProperty -Path $currentRegPath -Name $Enabled -Value "1" -PropertyType DWORD -Force | Out-Null

                }
                else
                {
                    New-ItemProperty -Path $currentRegPath -Name $DisabledByDefault -Value "1" -PropertyType DWORD -Force | Out-Null
                    New-ItemProperty -Path $currentRegPath -Name $Enabled -Value "0" -PropertyType DWORD -Force | Out-Null
                }
            }
            }


            #Write-host "--------------------------------------------------------------------------------------------------------------------------"
            Write-Host "`nTighten up the .NET Framework to use only TLS 1.2.." -ForegroundColor Cyan
            Start-Sleep 2

            #Harden to use only TLS 1.2
            # Tighten up the .NET Framework
            $NetRegistryPath = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
            If (!(Test-Path $NetRegistryPath))
            {
                New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SchUseStrongCrypto" -Value "1" -PropertyType DWORD -Force | Out-Null

            $NetRegistryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
            If (!(Test-Path $NetRegistryPath))
            {
            New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SchUseStrongCrypto" -Value "1" -PropertyType DWORD -Force | Out-Null


            #Write-host "--------------------------------------------------------------------------------------------------------------------------"
            Write-Host "`nEnabling registries for Intergration Packs (IPs) to use TLS 1.2.." -ForegroundColor Cyan
            Start-Sleep 2

            #registries change to enable Intergration Packs (IPs) to use TLS 1.2
            $NetRegistryPath = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727"
            If (!(Test-Path $NetRegistryPath))
            {
            New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SystemDefaultTlsVersions" -Value "1" -PropertyType DWORD -Force | Out-Null

            $NetRegistryPath = "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework\v2.0.50727"
            If (!(Test-Path $NetRegistryPath))
            {
            New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SystemDefaultTlsVersions" -Value "1" -PropertyType DWORD -Force | Out-Null

            $NetRegistryPath = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
            If (!(Test-Path $NetRegistryPath))
            {
            New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SystemDefaultTlsVersions" -Value "1" -PropertyType DWORD -Force | Out-Null

            $NetRegistryPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"
            If (!(Test-Path $NetRegistryPath))
            {
            New-Item -Path $NetRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $NetRegistryPath -Name "SystemDefaultTlsVersions" -Value "1" -PropertyType DWORD -Force | Out-Null

            #Checking if all the registries and the values are correct
            $Tempvar1=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client").DisabledByDefault
            $Tempvar2=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client").Enabled
            $Tempvar3=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client").DisabledByDefault
            $Tempvar4=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client").Enabled
            $Tempvar5=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client").DisabledByDefault
            $Tempvar6=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client").Enabled
            $Tempvar7=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client").DisabledByDefault
            $Tempvar8=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client").Enabled
            $Tempvar9=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client").DisabledByDefault
            $Tempvar10=(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client").Enabled
            $Tempvar11=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319").SchUseStrongCrypto
            $Tempvar12=(Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319").SchUseStrongCrypto
            $Tempvar13=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727").SystemDefaultTlsVersions
            $Tempvar14=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319").SystemDefaultTlsVersions
            $Tempvar15=(Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727").SystemDefaultTlsVersions
            $Tempvar16=(Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319").SystemDefaultTlsVersions

            if($Tempvar1 -eq 1 -and $Tempvar2 -eq 0  -and $Tempvar3 -eq 1 -and $Tempvar4 -eq 0 -and $Tempvar5 -eq 1 -and $Tempvar6 -eq 0 -and $Tempvar7 -eq 1 -and $Tempvar8 -eq 0 -and $Tempvar9 -eq 0 -and $Tempvar10 -eq 1 -and $Tempvar11 -eq 1 -and $Tempvar12 -eq 1 -and $Tempvar13 -eq 1 -and $Tempvar14 -eq 1 -and $Tempvar15 -eq 1 -and $Tempvar16 -eq 1)
            {
                LogToFile -message "`nPassed: All TLS registires are created and values are correct." -messagetype "InfoG"
                Write-host "--------------------------------------------------------------------------------------------------------------------------"
                Start-Sleep 2
                Reboot-Server
            }
            else
            {
                LogToFile -message "`nFailed: All TLS registires are rither not created or values are working. Exiting .." -messagetype "InfoR"
                Write-host "--------------------------------------------------------------------------------------------------------------------------"
                Start-Sleep 2
                Exit
            }        
        }  
}
#endregion

#region Reboot-Server
Function Reboot-Server()
{
    $a = new-object -comobject wscript.shell 
    $ConsoleAnswer = $a.popup("REBOOT this server NOW?",0,"REBOOT?",4)
    IF($ConsoleAnswer -eq 6)
    {
      Write-host "Reboot was selected.  Rebooting server NOW."
      Start-Sleep 2
      Restart-Computer
    }
    ELSE
    {
      LogToFile -message `n"You chose not to reboot.  We must REBOOT the server before settings will take effect." -messagetype "InfoR"
      Start-Sleep 5
      Exit
    }
}
#endregion

#region Main
Function Main()
{
    Write-Host "Starting script to check if all the pre-requisites to enable TLS 1.2 are passed and enabling TLS 1.2 for SCORCH .." -ForegroundColor Magenta
    Start-Sleep 2
    Get-SCORCHComponents
    Get-DotNetVersion
    Check-PreRequisitesSoftware
    Get-SQLVersion
    Enable-TLS1.2  
}

#Script calling starts here
Main
#endregion


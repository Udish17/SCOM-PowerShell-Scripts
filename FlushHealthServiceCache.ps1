

$installdir=(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup').installdirectory

Write-Host "Stopping Health Service" -ForegroundColor Cyan
Stop-Service HealthService
$cachefolder=$installdir + "Health Service State"
$date=get-date -format yyyy-MM-ddTHH-mm-ss-ff
Write-Host "Renaming Health Service Cache folder" -ForegroundColor Cyan
$renamedfolder=$cachefolder + $date
Start-Sleep 3
Rename-Item $cachefolder $renamedfolder
Write-Host "starting Health Service" -ForegroundColor Cyan
Start-Service HealthService
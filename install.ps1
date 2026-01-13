# Node Watchdog Installer

$scriptPath = "$env:LOCALAPPDATA\Temp\node-watchdog.ps1"
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\NodeWatchdog.lnk"

Write-Host "Installing Node Watchdog..." -ForegroundColor Cyan

# Copy script
Copy-Item ".\node-watchdog.ps1" $scriptPath -Force
Write-Host "[OK] Copied script to $scriptPath" -ForegroundColor Green

# Create startup shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($startupPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-WindowStyle Hidden -File $scriptPath"
$Shortcut.WindowStyle = 7
$Shortcut.Save()
Write-Host "[OK] Created startup shortcut" -ForegroundColor Green

# Start now
Start-Process powershell -ArgumentList "-WindowStyle Hidden -File $scriptPath" -WindowStyle Hidden
Write-Host "[OK] Watchdog started" -ForegroundColor Green

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Log file: $env:LOCALAPPDATA\Temp\node-watchdog.log"

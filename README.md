# Node.js Memory Watchdog

Monitors Node.js processes and auto-kills any that exceed a memory threshold. Prevents system crashes from memory leaks (e.g., Next.js dev server leaking to 160GB+).

## What it does

- Checks all `node.exe` processes every 30 seconds
- Kills any process exceeding 8GB (configurable)
- Logs what was killed with full details (PID, memory, command line, parent process)
- Shows Windows toast notification when a process is killed
- Runs silently in background

## Install

```powershell
# Clone
git clone https://github.com/mediar-ai/node-watchdog.git
cd node-watchdog

# Run install script
.\install.ps1
```

## Manual Install

1. Copy `node-watchdog.ps1` to `%LOCALAPPDATA%\Temp\`

2. Create startup shortcut:
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\NodeWatchdog.lnk")
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-WindowStyle Hidden -File $env:LOCALAPPDATA\Temp\node-watchdog.ps1"
$Shortcut.WindowStyle = 7
$Shortcut.Save()
```

3. Start manually:
```powershell
Start-Process powershell -ArgumentList "-WindowStyle Hidden -File $env:LOCALAPPDATA\Temp\node-watchdog.ps1" -WindowStyle Hidden
```

## Configuration

Edit `node-watchdog.ps1` to change:

```powershell
$threshold = 8GB    # Memory limit before kill
$interval = 30      # Check interval in seconds
```

## Logs

```
%LOCALAPPDATA%\Temp\node-watchdog.log
```

Example log entry when a process is killed:
```
========== KILLED: 2026-01-09 02:15:33 ==========
PID: 32956
Memory: 8.2 GB (exceeded 8GB threshold)
Started: 1/8/2026 6:30:00 PM
Running for: 7.8 hours
Parent: Cursor (PID 12345)
CommandLine: "C:\Program Files\nodejs\node.exe" ...next\dist\server...
=======================================================
```

## Why

Node.js processes (especially Next.js dev server, TypeScript server) can leak memory over time. Without intervention, they can consume 100GB+ and crash the entire system. This watchdog kills them early and logs the culprit so you can investigate.

## License

MIT

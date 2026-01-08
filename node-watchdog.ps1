# Auto-kill node processes that exceed threshold
# Prevents overnight crashes and logs what was killed

$threshold = 8GB  # Kill before it reaches 160GB
$logFile = "$env:LOCALAPPDATA\Temp\node-watchdog.log"
$interval = 30  # Check every 30 seconds

Add-Content $logFile "$(Get-Date) - Watchdog started (threshold: $([math]::Round($threshold/1GB,0))GB)"

while ($true) {
    Get-Process node -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.WorkingSet64 -gt $threshold) {
            # Capture info BEFORE killing
            $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue
            $parent = Get-Process -Id $cim.ParentProcessId -ErrorAction SilentlyContinue
            $memGB = [math]::Round($_.WorkingSet64/1GB, 2)
            
            $entry = @"

========== KILLED: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==========
PID: $($_.Id)
Memory: $memGB GB (exceeded $([math]::Round($threshold/1GB,0))GB threshold)
Started: $($_.StartTime)
Running for: $([math]::Round(((Get-Date) - $_.StartTime).TotalHours, 1)) hours
Parent: $($parent.Name) (PID $($cim.ParentProcessId))
CommandLine: $($cim.CommandLine)
=======================================================
"@
            # Kill it
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            
            # Log what happened
            Add-Content $logFile $entry
            
            # Show toast notification (Windows 10/11)
            [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
            $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
            $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
            $xml.GetElementsByTagName("text")[0].AppendChild($xml.CreateTextNode("Node Memory Leak Killed")) | Out-Null
            $xml.GetElementsByTagName("text")[1].AppendChild($xml.CreateTextNode("PID $($_.Id) killed at $memGB GB")) | Out-Null
            $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Node Watchdog").Show($toast)
        }
    }
    Start-Sleep -Seconds $interval
}

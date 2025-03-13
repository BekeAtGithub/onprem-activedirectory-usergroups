# Define log export path
$logPath = "C:\Logs"

# Check if the directory exists; if not, create it
if (!(Test-Path $logPath)) { 
    New-Item -ItemType Directory -Path $logPath
}

Write-Host "Log directory created at $logPath"

# Export logs as .evtx files (Full logs for in-depth analysis)
wevtutil epl Application "$logPath\Application.evtx"  # Export Application logs
wevtutil epl System "$logPath\System.evtx"            # Export System logs
wevtutil epl Setup "$logPath\Setup.evtx"              # Export Setup logs
wevtutil epl Security "$logPath\Security.evtx"        # Export Security logs
wevtutil epl ForwardedEvents "$logPath\ForwardedEvents.evtx"  # Export Forwarded logs

Write-Host "Event logs exported as .evtx files"

# Export logs to CSV (For human-readable analysis)
Get-WinEvent -LogName Application | Select-Object TimeCreated,Id,LevelDisplayName,Message | Export-Csv -NoTypeInformation -Path "$logPath\Application.csv"
Get-WinEvent -LogName System | Select-Object TimeCreated,Id,LevelDisplayName,Message | Export-Csv -NoTypeInformation -Path "$logPath\System.csv"
Get-WinEvent -LogName Setup | Select-Object TimeCreated,Id,LevelDisplayName,Message | Export-Csv -NoTypeInformation -Path "$logPath\Setup.csv"
Get-WinEvent -LogName Security | Select-Object TimeCreated,Id,LevelDisplayName,Message | Export-Csv -NoTypeInformation -Path "$logPath\Security.csv"
Get-WinEvent -LogName ForwardedEvents | Select-Object TimeCreated,Id,LevelDisplayName,Message | Export-Csv -NoTypeInformation -Path "$logPath\ForwardedEvents.csv"

Write-Host "Event logs exported as CSV files"

# Compress the logs into a single zip file
$zipFilePath = "$logPath\EventLogs.zip"
Compress-Archive -Path "$logPath\*" -DestinationPath $zipFilePath -Force

Write-Host "Logs compressed into $zipFilePath"

# Check for high CPU usage processes
$cpuThreshold = 10  # Set CPU usage threshold (Change this value as needed)
$highCpuProcesses = Get-Process | Sort-Object CPU -Descending | Where-Object { $_.CPU -gt $cpuThreshold } | Select-Object ProcessName, Id, CPU

# Save high CPU processes to a file
$cpuLogFile = "$logPath\HighCPUProcesses.csv"
$highCpuProcesses | Export-Csv -NoTypeInformation -Path $cpuLogFile

Write-Host "High CPU usage processes saved to: $cpuLogFile"

# Display CPU-heavy processes in the console
if ($highCpuProcesses) {
    Write-Host " High CPU Usage Detected "
    $highCpuProcesses | Format-Table -AutoSize
} else {
    Write-Host " No high CPU usage processes detected."
}

# OPTIONAL: Copy the logs to another location or upload to a server
# Uncomment and modify if needed
# Copy-Item -Path $zipFilePath -Destination "\\NetworkPath\LogsBackup" -Force
# Invoke-WebRequest -Uri "http://yourserver/upload" -Method Post -InFile $zipFilePath

Write-Host "Log export and performance check completed successfully! "

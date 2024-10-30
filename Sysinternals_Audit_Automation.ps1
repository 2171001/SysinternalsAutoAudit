# Define paths for logs and tools
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logDir = "C:\SysinternalsAuditLogs"
$sysinternalsDir = "C:\SysinternalsSuite"
$sysmonConfig = "$sysinternalsDir\sysmonconfig.xml"
$sysmonLogEvtx = "$logDir\SysmonLog-$timestamp.evtx"
$sysmonLogCsv = "$logDir\SysmonLog-$timestamp.csv"
$procmonLog = "$logDir\ProcmonLog-$timestamp.PML"
$autorunsLog = "$logDir\AutorunsLog-$timestamp.csv"
$procExpLog = "$logDir\ProcExpLog-$timestamp.txt"

# Create log directory if it doesn't exist
if (-Not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory
}

# Function to print status messages
function Write-Log {
    param([string]$message)
    Write-Host "[INFO] $message"
}

# Function to read and print CSV content
function Print-Csv {
    param([string]$filePath)
    if (Test-Path $filePath) {
        Write-Log "Displaying contents of ${filePath}:"
        Import-Csv $filePath | Format-Table -AutoSize
    } else {
        Write-Log "File ${filePath} not found!"
    }
}

Write-Log "Starting system audit using Sysinternals tools..."

# Check for Sysmon
if (Test-Path "$sysinternalsDir\sysmon.exe") {
    Write-Log "Installing and starting Sysmon..."
    Start-Process -FilePath "$sysinternalsDir\sysmon.exe" -ArgumentList "-accepteula -i $sysmonConfig" -Wait
} else {
    Write-Log "Sysmon executable not found!"
}

# Check for Process Monitor
if (Test-Path "$sysinternalsDir\Procmon.exe") {
    Write-Log "Starting Process Monitor..."
    Start-Process -FilePath "$sysinternalsDir\Procmon.exe" -ArgumentList "/Backingfile $procmonLog /Minimized /Quiet" -Wait
    Write-Log "Process Monitor is running and logging."
} else {
    Write-Log "Process Monitor executable not found!"
}

# Check for Autoruns
if (Test-Path "$sysinternalsDir\autorunsc.exe") {
    Write-Log "Running Autoruns to capture startup entries..."
    Start-Process -FilePath "$sysinternalsDir\autorunsc.exe" -ArgumentList "/accepteula /a * /c /nobanner /o $autorunsLog" -Wait
    Write-Log "Autoruns log saved to $autorunsLog."
    
    # Display Autoruns CSV output
    Print-Csv -filePath $autorunsLog
} else {
    Write-Log "Autoruns executable not found!"
}

# Use tasklist to capture running processes instead of Process Explorer
$procExpLog = "$logDir\ProcExpLog-$timestamp.txt"
Write-Log "Capturing running processes using tasklist..."
tasklist /FO CSV > $procExpLog
Write-Log "Running processes saved to $procExpLog."

# Stop Process Monitor
Write-Log "Stopping Process Monitor and saving log..."
Stop-Process -Name Procmon -ErrorAction SilentlyContinue
Write-Log "Process Monitor log saved to $procmonLog."

# Display Process Monitor log (since it's binary, just print info)
if (Test-Path $procmonLog) {
    Write-Log "Process Monitor log saved to $procmonLog."
} else {
    Write-Log "Process Monitor log not found!"
}

# Export Sysmon logs to alternative formats
Write-Log "Saving Sysmon events to log file..."
if (Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -ErrorAction SilentlyContinue) {
    Write-Log "Sysmon log found, exporting events..."
    
    # Attempt to export in EVTX format
    try {
        Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Export-Clixml -Path $sysmonLogEvtx
        Write-Log "Sysmon log saved to $sysmonLogEvtx."
    } catch {
        Write-Log "Failed to save Sysmon log as EVTX. Exporting as CSV instead..."
        
        # Export to CSV if EVTX fails
        Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Export-Csv -Path $sysmonLogCsv -NoTypeInformation
        Write-Log "Sysmon log saved to $sysmonLogCsv."
    }
    
    # Display Sysmon CSV output
    Print-Csv -filePath $sysmonLogCsv
} else {
    Write-Log "Sysmon event log not found!"
}

# Cleanup Sysmon
if (Test-Path "$sysinternalsDir\sysmon.exe") {
    Write-Log "Uninstalling Sysmon..."
    Start-Process -FilePath "$sysinternalsDir\sysmon.exe" -ArgumentList "-u" -Wait
} else {
    Write-Log "Sysmon executable not found!"
}

Write-Log "System audit completed successfully!"
# SysinternalsAutoAudit
Emphasizes automation in Sysinternals auditing.

# Sysinternals Audit Automation
This PowerShell script automates the process of auditing system activities using Sysinternals tools, specifically Sysmon, Process Monitor, and Autoruns. It captures logs of system events and processes, saving them in designated directories for further analysis.

## Prerequisites
- Windows operating system
- Sysinternals Suite installed ([Download here](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite))
- Administrative privileges to run the script

## Script Overview
1. **Setup**: Defines paths for logs, Sysinternals tools, and configuration files.
2. **Logging**: Creates a log directory if it doesn't exist.
3. **Sysmon**: Installs and starts Sysmon for monitoring system events.
4. **Process Monitor**: Starts Process Monitor to capture process activities.
5. **Autoruns**: Executes Autoruns to capture startup entries and outputs them to a CSV file.
6. **Running Processes**: Captures a list of currently running processes using `tasklist`.
7. **Sysmon Logs**: Exports Sysmon event logs to both EVTX and CSV formats.
8. **Cleanup**: Uninstalls Sysmon upon completion of the audit.

## Usage
1. Open PowerShell as an administrator.
2. Navigate to the directory where the script is saved.
3. Run the script:
   ```powershell
   .\Sysinternals_Audit_Automation.ps1
   ```
## Output
The script generates the following log files in the C:\SysinternalsAuditLogs directory:

ProcmonLog-YYYYMMDD-HHMMSS.PML: Process Monitor log file.
AutorunsLog-YYYYMMDD-HHMMSS.csv: Autoruns output of startup entries.
ProcExpLog-YYYYMMDD-HHMMSS.txt: List of running processes.

## Notes
Ensure that Sysmon is configured appropriately by editing the sysmonconfig.xml file as needed.
The script may take some time to run, depending on system performance and log sizes.


Feel free to modify any section to fit your specific needs or preferences!

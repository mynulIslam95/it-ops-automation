# Stopped service — print spooler down on nf-ws01

Fictional ticket NF-1048.

## Symptoms
User cannot print. Device Manager is healthy. Event Viewer Application log shows spooler stopped.

## Checks
```powershell
Get-Service Spooler
Get-WinEvent -FilterHashtable @{LogName='System'; ID=7036} -MaxEvents 20 |
  Where-Object { $_.Message -match 'Spooler' }
Test-NetConnection -ComputerName nf-prn01 -Port 9100
```

## Cause
Print Spooler (`Spooler`) was Stopped after a driver install. Startup type still Automatic.

## Fix
```powershell
Start-Service Spooler
Set-Service Spooler -StartupType Automatic
Get-Service Spooler
```

## Verification
`Status` is Running. A test page prints. User confirmed. Ticket closed.

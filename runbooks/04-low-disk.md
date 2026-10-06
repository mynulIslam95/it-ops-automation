# Low disk space — C: on nf-ws01 below 10% free

Fictional ticket NF-1055.

## Symptoms
Outlook and Windows Update fail. Explorer shows a red bar on C:.

## Checks
```powershell
Get-PSDrive C
Get-ChildItem $env:TEMP -ErrorAction SilentlyContinue | Measure-Object Length -Sum
vssadmin list shadows
```
```bash
df -h /
du -xh /var /tmp /home | sort -h | tail
```

## Cause
Old Windows Update cache and a 4 GB copy of logs in `C:\Temp\support-dump`.

## Fix
Remove the dump after confirming it is not needed. Empty TEMP. Do not delete user Documents.
```powershell
Remove-Item C:\Temp\support-dump -Recurse -Force
Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
Get-PSDrive C
```

## Verification
Free space above 15%. Outlook opens. Ticket closed with the bytes freed recorded.

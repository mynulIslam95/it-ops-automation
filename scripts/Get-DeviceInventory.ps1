<#
.SYNOPSIS
  Collect local workstation facts into CSV. No passwords, no personal files.

.EXAMPLE
  .\Get-DeviceInventory.ps1
  .\Get-DeviceInventory.ps1 -OutputPath .\evidence\device-inventory.csv
#>
[CmdletBinding()]
param(
  [string]$OutputPath = (Join-Path $PSScriptRoot "..\evidence\device-inventory.csv")
)

$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$net = Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike "127.*" -and $_.PrefixOrigin -ne "WellKnown" } |
  Select-Object -First 1

$row = [pscustomobject]@{
  CollectedAt     = (Get-Date).ToString("s")
  Hostname        = $env:COMPUTERNAME
  DomainOrWorkgroup = $cs.Domain
  Manufacturer    = $cs.Manufacturer
  Model           = $cs.Model
  OS              = $os.Caption
  OSVersion       = $os.Version
  LastBoot        = $os.LastBootUpTime.ToString("s")
  TotalMemoryGB   = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
  CFreeGB         = if ($disk) { [math]::Round($disk.FreeSpace / 1GB, 2) } else { $null }
  IPv4            = $net.IPAddress
  LoggedOnUser    = $env:USERNAME
}

$dir = Split-Path -Parent $OutputPath
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$row | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
Write-Host "Wrote $OutputPath"
Get-Content $OutputPath
exit 0

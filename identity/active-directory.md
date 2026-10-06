# Active Directory lab — nf-dc01

Fictional domain `northfield.lab`. This is a Windows Server evaluation VM, not Entra ID and not a production forest.

## What the domain does
- OU `Northfield`
- Global group `NF-Office`
- Three synthetic users: Anna Weber, Jamal Khan, Sara Mueller
- Workstations domain-join to `northfield.lab`
- A basic GPO: password length 12, screen lock 15 minutes, Windows Update from WSUS later if you add it

## Build
1. Install Windows Server evaluation. Confirm the current Microsoft evaluation terms.
2. `Install-WindowsFeature AD-Domain-Services -IncludeManagementTools`
3. `Install-ADDSForest -DomainName northfield.lab`
4. From this repo: `.\identity\New-NorthfieldAD.ps1`
5. Domain-join `nf-ws01`. Sign in as `NORTHFIELD\aweber`.

A local Windows account on a laptop is not this demonstration. If the VM is off, the users and GPO are not live; keep the script and this file as the source of truth and drop sanitized `Get-ADUser` output into `evidence/ad/` when the VM is up.

## Group Policy
Create GPO `NF-Baseline` linked to OU Northfield:
- Computer Configuration → Windows Settings → Security Settings → Account Policies → Password Policy: minimum 12 characters
- User Configuration → Policies → Administrative Templates → Control Panel → Personalization: screen saver timeout 900 seconds

```powershell
Get-GPO -Name "NF-Baseline"
Get-GPResultantSetOfPolicy -Computer nf-ws01 -User aweber -ReportType Html -Path .\evidence\ad\rsop-aweber.html
```

## Verification
- `Get-ADUser -Filter * -SearchBase "OU=Northfield,DC=northfield,DC=lab"`
- Domain join: `Systeminfo | findstr /B /C:"Domain"`
- User can change password at first logon

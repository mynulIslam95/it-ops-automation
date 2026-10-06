# Entra ID, Microsoft 365 and Intune

These are the commands and checks for Northfield Office identity in a Microsoft tenant. They are real operational steps. They need a tenant and licences. They are not a local Windows user account.

If a tenant is not available, keep the procedures here and store sanitized screenshots or CSV export under `evidence/entra/` when you do run them. Do not mark a step done without that evidence.

## Groups and users
```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All"
Get-MgUser -Top 20 | Select-Object DisplayName, UserPrincipalName, AccountEnabled
New-MgGroup -DisplayName "NF-Office" -MailEnabled:$false -SecurityEnabled -MailNickname "nfoffice"
```

## MFA
```powershell
Get-MgUserAuthenticationMethod -UserId "aweber@northfield.example"
# Conditional Access is configured in Entra admin center.
# Record the policy name, target group, grant control (MFA) and what you excluded.
```

## Microsoft 365 administration
```powershell
Get-MgUserLicenseDetail -UserId "aweber@northfield.example"
# Assign or remove a SKU only with an available licence.
```

## Intune device
```powershell
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
Get-MgDeviceManagementManagedDevice | Select-Object DeviceName, OperatingSystem, ComplianceState
```

## Verification
Save:
- group membership CSV
- one MFA method list (no secrets)
- one managed device compliance row

Put files in `evidence/entra/`.

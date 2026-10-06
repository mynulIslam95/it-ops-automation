# Failed sign-in — a.weber locked out after password change

Fictional ticket NF-1060. Simulation only. No real credentials.

## Symptoms
User reports "username or password is incorrect" after a planned password change. Phone sign-in also fails.

## Checks
```powershell
# Local workstation (not AD)
net user a.weber
Get-LocalUser a.weber | Format-List *
# Lab AD (when nf-dc01 is online)
Get-ADUser a.weber -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt, PasswordLastSet
Search-ADAccount -LockedOut
```

## Cause
Cached logon on nf-ws01 used the old password. AD showed `LockedOut = True` after five bad attempts.

## Fix
Unlock the account. User signs in with the new password on the domain. Cached logon updates.
```powershell
Unlock-ADAccount -Identity a.weber
Get-ADUser a.weber -Properties LockedOut
```
If the lab is local SAM only:
```powershell
net user a.weber /active:yes
```

## Verification
Interactive logon succeeds. `LockedOut` is False. User opens the intranet. Ticket closed.

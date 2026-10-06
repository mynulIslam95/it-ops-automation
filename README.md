# it-ops-automation

Support and systems work for a fictional office: **Northfield Office**. Windows workstation, Ubuntu host, Active Directory, Entra/M365/Intune procedures, Ansible, scripts and five closed tickets. Names and files are synthetic.

A reader should be able to reproduce the Ubuntu side from this README, run both scripts, restore a backup, and follow each runbook including the verification step.

## Layout

```
scripts/Get-DeviceInventory.ps1   Windows facts to CSV (no passwords, no personal files)
scripts/health-check.sh           Linux health; exit 1 on failed gates
scripts/backup-folder.sh
scripts/restore-folder.sh
ansible/playbook.yml              packages, share, firewall, health script
identity/New-NorthfieldAD.ps1     OU, group, three users
identity/active-directory.md
identity/entra-m365-intune.md
runbooks/                         five tickets, each with verification
docs/environment.md               hosts, diagram, DNS/DHCP/IP/ports/HTTP checks
fixtures/office-share/            files used for backup and restore
evidence/                         sample output
tests/test_scripts.sh
```

## Ubuntu / WSL2

```bash
# Ubuntu 22.04 VM or WSL2. Windows stays the workstation.
sudo apt update
sudo apt install -y curl vim htop ufw openssh-server
sudo addgroup office
sudo adduser smueller
sudo usermod -aG office smueller
chmod +x scripts/*.sh tests/test_scripts.sh
./scripts/health-check.sh
```

Practise on that host: users, groups, `chmod`/`chown`, `ps`, `systemctl`, `apt`, SSH keys, `journalctl`.

## Windows

```powershell
Set-ExecutionPolicy -Scope Process RemoteSigned
.\scripts\Get-DeviceInventory.ps1
Get-Service | Where-Object Status -eq Running | Select-Object -First 15
Get-WinEvent -LogName System -MaxEvents 10
ipconfig /all
Test-NetConnection 1.1.1.1 -Port 443
```

Event Viewer, services and those network commands are what the runbooks use.

## Scripts

PowerShell writes hostname, OS, memory, C: free space, IPv4. It does not walk Documents or collect secrets.

```text
# example: evidence/device-inventory.sample.csv
Hostname,NF-WS01
CFreeGB,82.4
```

Bash health check prints disk, memory, failed systemd units and listeners. Non-zero exit when a disk is at or above 90% or a unit has failed.

```bash
./scripts/health-check.sh
echo $?
```

## Backup and restore

```bash
./scripts/backup-folder.sh
# prints the archive path
./scripts/restore-folder.sh evidence/office-share-*.tar.gz evidence/restored
test -f evidence/restored/office-share/welcome.txt
```

Sample transcript: `evidence/restore.sample.txt`.

## Tickets

| ID | Runbook | Verification in the file |
| --- | --- | --- |
| NF-1042 | [DNS failure](runbooks/01-dns-failure.md) | `nslookup` returns an A record |
| NF-1048 | [Stopped service](runbooks/02-stopped-service.md) | Spooler Running |
| NF-1051 | [Permission failure](runbooks/03-permission-failure.md) | user can `touch` the share |
| NF-1055 | [Low disk](runbooks/04-low-disk.md) | free space above 15% |
| NF-1060 | [Failed sign-in](runbooks/05-failed-signin.md) | account unlocked, logon works |

## Ansible

```bash
cp ansible/inventory.example.ini ansible/inventory.ini
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

The playbook installs packages, creates group `office`, `/srv/office-share` mode 2770, UFW SSH, and copies `health-check.sh`.

## Active Directory

`identity/New-NorthfieldAD.ps1` and `identity/active-directory.md` are the AD work: forest `northfield.lab`, OU, group, users, domain join, GPO `NF-Baseline`. Needs a Windows Server evaluation VM. Check current evaluation terms. A local SAM user is not this.

Sanitized `Get-ADUser` output belongs in `evidence/ad/` after you run the script on nf-dc01.

## Entra, Microsoft 365, Intune

`identity/entra-m365-intune.md` is the tenant work: groups, MFA methods, licences, managed devices. Needs a tenant and licences. Put CSV or screenshots in `evidence/entra/` when you run the commands.

## Tests

```bash
./tests/test_scripts.sh
```

Runs health-check, backup and restore on this machine.

## What this is not
Lab work, not production on-call. Fictional tickets, not ServiceNow. Entra steps need a tenant before they have live evidence.

# Environment

Fictional company: **Northfield Office**. All names and addresses are synthetic.

```mermaid
flowchart LR
  subgraph workstation [nf-ws01 Windows]
    PS[PowerShell inventory]
    EV[Event Viewer]
  end
  subgraph linux [nf-lx01 Ubuntu]
    Bash[health-check.sh]
    Share[/srv/office-share]
    Ansible[Ansible playbook]
  end
  subgraph identity [identity]
    AD[nf-dc01 AD DS]
    Entra[Entra tenant when licensed]
  end
  workstation -->|DNS 10.20.0.10| DNS[lab DNS]
  workstation --> AD
  linux --> AD
  workstation -.->|optional| Entra
```

## Hosts
| Name | Role | Notes |
| --- | --- | --- |
| nf-ws01 | Windows workstation | WSL2 Ubuntu is acceptable for Linux scripts |
| nf-lx01 | Ubuntu 22.04 VM or WSL2 | users, groups, SSH, services, logs |
| nf-dc01 | Windows Server evaluation | Active Directory. Check evaluation terms |

Limits: this is a lab. It is not production on-call. GitHub Issues is not ServiceNow.

## Network checks used in tickets
```powershell
ipconfig /all
Get-NetIPConfiguration
Test-NetConnection 10.20.0.10 -Port 53
Test-NetConnection intranet.northfield.example -Port 443
```
```bash
ip -br a
ss -tln
dig +short intranet.northfield.example
curl -I http://127.0.0.1
journalctl -u ssh --since today
```

DNS names the lab. DHCP is the local adapter lease. Ports are confirmed with `Test-NetConnection` / `ss`, not only named.

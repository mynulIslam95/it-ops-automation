# DNS failure — nf-ws01 cannot resolve intranet.northfield.example

Fictional ticket NF-1042. Synthetic names only.

## Symptoms
User a.weber cannot open `https://intranet.northfield.example`. Ping to 8.8.8.8 works. Browser shows "server not found".

## Checks
```powershell
ipconfig /all
nslookup intranet.northfield.example
nslookup intranet.northfield.example 10.20.0.10
Resolve-DnsName intranet.northfield.example -ErrorAction SilentlyContinue
Get-DnsClientServerAddress -AddressFamily IPv4
```
On Linux:
```bash
resolvectl status
dig intranet.northfield.example
dig @10.20.0.10 intranet.northfield.example
```

## Cause
Workstation DNS pointed at a public resolver. Internal names are only on `10.20.0.10` (lab DNS).

## Fix
Set the adapter DNS to `10.20.0.10`, flush cache, retry.
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.20.0.10
ipconfig /flushdns
nslookup intranet.northfield.example
```

## Verification
`nslookup` returns an A record. Browser loads the page. Ticket closed after the user confirmed.

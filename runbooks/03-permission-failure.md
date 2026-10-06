# Permission failure — share write denied for s.mueller

Fictional ticket NF-1051.

## Symptoms
User can read `\\nf-lx01\office-share` but cannot save a file. Error: Access is denied.

## Checks
```bash
# on nf-lx01
getent passwd smueller
id smueller
ls -ld /srv/office-share
namei -l /srv/office-share
sudo -u smueller touch /srv/office-share/probe.txt
```

## Cause
Folder owned by `root:office`, mode `750`. User is not in group `office`.

## Fix
```bash
sudo usermod -aG office smueller
sudo chmod 2770 /srv/office-share
# user must log off and on so the new group applies
id smueller
sudo -u smueller touch /srv/office-share/probe.txt
```

## Verification
`probe.txt` exists. User saved a real file after re-login. Probe file removed. Ticket closed.

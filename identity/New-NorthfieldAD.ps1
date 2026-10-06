#Requires -Modules ActiveDirectory
<#
  Lab Active Directory on nf-dc01 (Windows Server evaluation).
  Synthetic users only. Run as a domain admin in the lab.
  Check current Microsoft evaluation terms before you install the ISO.
#>
$OU = "OU=Northfield,DC=northfield,DC=lab"
$Users = @(
  @{ Sam = "aweber"; Name = "Anna Weber"; Dept = "Finance" }
  @{ Sam = "jkhan";  Name = "Jamal Khan"; Dept = "Operations" }
  @{ Sam = "smueller"; Name = "Sara Mueller"; Dept = "Support" }
)

if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Northfield'" -ErrorAction SilentlyContinue)) {
  New-ADOrganizationalUnit -Name "Northfield" -Path "DC=northfield,DC=lab"
}

if (-not (Get-ADGroup -Filter "SamAccountName -eq 'NF-Office'" -ErrorAction SilentlyContinue)) {
  New-ADGroup -Name "NF-Office" -GroupScope Global -Path $OU
}

foreach ($u in $Users) {
  $upn = "$($u.Sam)@northfield.lab"
  if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue)) {
    New-ADUser -Name $u.Name -SamAccountName $u.Sam -UserPrincipalName $upn `
      -Path $OU -Department $u.Dept -Enabled $true `
      -AccountPassword (ConvertTo-SecureString "ChangeMe-LabOnly-1" -AsPlainText -Force) `
      -ChangePasswordAtLogon $true
  }
  Add-ADGroupMember -Identity "NF-Office" -Members $u.Sam -ErrorAction SilentlyContinue
}

Get-ADUser -Filter * -SearchBase $OU | Select-Object SamAccountName, Enabled, DistinguishedName
Get-ADGroupMember NF-Office | Select-Object SamAccountName

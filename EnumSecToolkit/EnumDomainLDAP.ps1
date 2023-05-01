function EnumDomainLDAP() {
<#
.SYNOPSIS
This function enumerates various Active Directory objects, including users with Service Principal Names (SPN), users and computers with constrained and unconstrained delegation, trusts, and domain computers with DNSHostName and IP address. The results can be displayed in the console or exported to a CSV file.

.PARAMETER Domain
Specifies the target Active Directory domain.

.PARAMETER ExportResults
If present, exports the enumeration results to a CSV file.

.PARAMETER OutputDirectory
Specifies the output directory for the exported CSV file. Defaults to the current directory.

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$Domain,
    [string]$OutputFile
)

function addContent {
    param(
        [Parameter(ValueFromPipeline)]$i,
        [string]$color
        )

    $b = $i | Out-String -Stream
    $b -split [Environment]::NewLine | ForEach-Object {
            if ($OutputFile) { Add-Content -Path $OutputFile -Value $_ -Encoding Ascii; }
            if ($color) { Write-Host $_ -ForegroundColor $color }
            else { $_ }
        }
}

Write-Warning "This script requires ADModule!"

# Get the DC
$DC = Get-ADDomainController -Server $Domain | Select-Object HostName,IPv4Address

# Enumerate users with SPN
Write-Verbose "Enumerating users with Service Principal Names (SPN)..."
$spnUsers = Get-ADUser -Filter "servicePrincipalName -like '*'" -Properties servicePrincipalName -server $Domain | Select-Object SamAccountName, servicePrincipalName

# Enumerate users with DoNotRequirePreAuth
Write-Verbose "Enumerating users with DoNotRequirePreAuth enabled.."
$asrepUsers = Get-ADUser -Filter {DoesNotRequirePreAuth -eq $True} -Properties DoesNotRequirePreAuth,pwdlastset -server $Domain | Select-Object SamAccountName,@{Name='PwdLastSet';Expression={[DateTime]::FromFileTime($_.pwdlastset).ToString()}}

# Enumerate users and computers with constrained delegation
Write-Verbose "Enumerating users and computers with constrained delegation..."
$constrainedDelegation = Get-ADObject -Filter {msDS-AllowedToDelegateTo -ne "$null"} -Properties msDS-AllowedToDelegateTo, msDS-AllowedToActOnBehalfOfOtherIdentity -server $Domain | Select-Object Name, msDS-AllowedToDelegateTo, msDS-AllowedToActOnBehalfOfOtherIdentity

# Enumerate users and computers with unconstrained delegation
Write-Verbose "Enumerating users and computers with unconstrained delegation..."
$unconstrainedDelegation = Get-ADObject -Filter {msDS-AllowedToActOnBehalfOfOtherIdentity -ne "$null" -and msDS-AllowedToDelegateTo -eq "$null"} -Properties msDS-AllowedToActOnBehalfOfOtherIdentity -server $Domain | Select-Object Name, msDS-AllowedToActOnBehalfOfOtherIdentity

# Enumerate trusts
Write-Verbose "Enumerating trusts..."
$trusts = Get-ADTrust -Filter * -server $Domain | Select-Object Name, TrustType, Direction, SourceDomain, TargetDomain

# Enumerate domain computers with DNSHostName and IP address
Write-Verbose "Enumerating domain computers with DNSHostName and IP address..."
$computers = Get-ADComputer -Filter * -Properties DNSHostName, IPv4Address -server $Domain | Select-Object Name, DNSHostName, IPv4Address

# Check if machine is AzureJoined
Write-Verbose "Enumerating if the machine is AzureAD joined.."
$azureadjoined = dsregcmd.exe /status | Select-String "AzureADJoined"
if ($azureadjoined -match "NO") {
    $azureadjoined = "Machine is AzureAD Joined: FALSE"
}
else {
    $azureadjoined = "Machine is AzureAD Joined: TRUE"
}

# Find potential computers which have ADConnector or the MSOL user
Write-Verbose "Enumerating MSOL user and computers which might have AzureAD Connect"
$MSOLUser = Get-ADUser -Filter * -server $Domain | ?{$_.DistinguishedName -match "MSOL"}
$AzureTargets = Get-ADComputer -Filter * -Server $Domain | Where-Object { $_.Name -match 'ADConnect|Azure|Az' }

# Get the domain password policy
Write-Verbose "Getting domain password policy.."
$passpol = Get-ADDefaultDomainPasswordPolicy -Server $Domain | select MinPasswordLength,MaxPasswordAge,LockoutThreshold,LockoutDuration,LockoutObservationWindow,ComplexityEnabled

# Enumerate Certificate templates which have Client Authentication and SupplyInTheRequest templates
Write-Verbose "Enumerating vulnerable templates.."
$templates = Get-ADobject -Filter { ObjectClass -eq "PKIcertificateTemplate" } -SearchBase (Get-ADRootDSE -Server techcorp.local).ConfigurationNamingContext -prop * | ?{$_.pKIExtendedKeyUsage -contains "1.3.6.1.5.5.7.3.2" -and $_.'mspki-certificate-name-flag' -band 0x00000001 -eq '1'} | Select Name,pKIExtendedKeyUsage, mspki-certificate-name-flag, @{ Name = "SupplyInRequest" ; Expression = { $_.'mspki-certificate-name-flag' -band 0x00000001 } }

# Enumerate whether the CA allows to supply alternative name
Write-Verbose "Enumerating CA configuration.."
if ((certutil.exe -getreg "policy\editFlags") -contains "EDITF_ATTRIBUTESUBJECALTNAME2") {
    $SANCAConfig = @("SubjectAltName CA Configuration: ", 'TRUE')
}
else {
    $SANCAConfig = @("SubjectAltName CA Configuration: ", 'FALSE')
}

# Enumerate Shares
$pcs = $computers.dnshostname
$shares = @()
$shareaccess = $false

foreach ($pc in $pcs) {
    $temp = net view "\\$pc" | Select-String -Pattern '^([A-Za-z0-9]+)\s+Disk' | ForEach-Object { $_.Matches.Groups[1].Value }
    $shares += ,@($pc, $temp)
}

$finalShares = "Share Access on $Domain : `n`n"

foreach ($entry in $shares) {
    $computer = $entry[0]
    $shareList = $entry[1]

    foreach ($shareName in $shareList) {
        $sharePath = "\\$computer\$shareName"
        if ((Test-Path $sharePath -ErrorAction SilentlyContinue)) {
            if (!$shareaccess) {
                $shareaccess = $true
            }
            $temp =  "ACCESS ALLOWED on Share $sharePath"
            $finalShares += $temp + "`n"
        }
    }
}

# Output results to console or file
    
Write-Verbose "Displaying results in console..."

"[+] Domain Controller: " | addContent -color 'Green'
$DC | Out-String | addContent

"[+] Password Policy: " | addContent -color 'Green'
$passpol | Out-String | addContent

if ($trusts) {
    "[+] Domain Trusts: " | addContent -color 'Green'
    $trusts | Out-String | addContent
}

"[+] Users with SPN: " | addContent -color 'Green'
$spnUsers | Out-String | addContent
if ($asrepUsers) {
    "`n[+] Users with DoNotRequirePreAuth enabled: `n" | addContent -color Green
    $asrepUsers | Out-String | addContent
}
if ($unconstrainedDelegation) {
    "[+] Potential Unconstrained Delegation: " | addContent 'Green'
    $unconstrainedDelegation | Out-String | addContent
}

"[+] AzureAD details: `n" | addContent -color 'Green'
$azureadjoined | Out-String | addContent

$MSOLUser | Out-String | addContent
$AzureTargets | Out-String | addContent

"`n[+] Domain Computers list: " | addContent -color 'Green'
$computers | Out-String | addContent 

if ($templates) {
    "[+] Potential Vulnerable Templates: " | addContent -color 'Green'
    $templates | Out-String | addContent
}

if ($SANCAConfig -match "TRUE") {
    "`n[+] CA Server Vulnerabilities: `n" | addContent -color 'Green'
    $SANCAConfig | Out-String | addContent
}
else {
    "[-] CA Server does not have SubjectAltName configured" | addContent -color 'Red'
}

if ($shareaccess) {
    "`n[+] Found accessible shares`n" | addContent -color 'Green'
    $finalShares | Out-String | addContent 
}
}


function enumDomainWMI () {

    $OutputFile = "C:\users\public\EnumerationResults.txt"

    # Gather information about the domain
    Write-Host -ForegroundColor Green "[+] Gathering info about the domain"
    Add-Content $OutputFile "=== Domain Info ==="
    Get-CimInstance -Namespace root/directory/ldap -ClassName ds_domain | select -ExpandProperty ds_dc | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the domain controller
    Write-Host -ForegroundColor Green "[+] Gathering info about the domain controller"
    Add-Content $OutputFile "`n=== Domain Controller Info ==="
    Get-CimInstance -Namespace root/directory/ldap -ClassName ds_computer | Where-Object {$_.ds_UserAccountControl -eq 532480} | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the domain password policy
    Write-Host -ForegroundColor Green "[+] Gathering info about the domain password policy"
    Add-Content $OutputFile "`n=== Domain Password Policy Info ==="
    Get-CimInstance -Namespace root/directory/ldap -ClassName ds_domain | select DS_lockoutDuration, DS_lockoutObservationWindow, DS_lockoutThreshold, DS_maxPwdAge, DS_minPwdAge, DS_minPwdLength, DS_pwdHistoryLength, DS_pwdProperties | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the shadow copy
    Write-Host -ForegroundColor Green "[+] Gathering info about the shadow copy"
    Add-Content $OutputFile "`n=== Shadow Copy Info ==="
    Get-CimInstance -ClassName Win32_ShadowCopy | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the domain users
    Write-Host -ForegroundColor Green "[+] Gathering info about the domain users"
    Add-Content $OutputFile "`n=== Domain User Info ==="
    Get-CimInstance -ClassName Win32_UserAccount | select name | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the groups in the domain and get their SID
    Write-Host -ForegroundColor Green "[+] Gathering info about the groups in the domain and get the group SID"
    Add-Content $OutputFile "`n=== Domain Group Info ==="
    Get-CimInstance -ClassName win32_groupuser | Where-Object {$_.PartComponent.Path -match $User } | Out-File $OutputFile -Append -Encoding ascii
    
    # Gather information about the domain computers
    Write-Host -ForegroundColor Green "[+] Gathering info about the domain computers"
    Add-Content $OutputFile "`n=== Domain Computer Info ==="
    Get-CimInstance -Namespace root/directory/ldap -ClassName ds_computer | select DS_sAMAccountName, DS_operatingSystem, DS_operatingSystemVersion, DS_isCriticalSystemObject, DS_distinguishedName, DS_dNSHostName | Out-File $OutputFile -Append -Encoding ascii

    # Gather information about the groups that a user has membership
    Write-Host -ForegroundColor Green "[+] Gathering info about the groups that a user has membership"
    Add-Content $OutputFile "`n=== Group Membership Info ==="

    $User = Read-Host "Please enter a username in order to discover the group that they are part of"
    $groups = Get-CimInstance -ClassName win32_groupuser | Where-Object {$_.PartComponent -match $User} | Foreach-Object {[ciminstance]$_.GroupComponent}
    if ($groups) {
        Add-Content $OutputFile "The user $User is a member of the following groups:`n"
        foreach ($group in $groups) {
            Add-Content $OutputFile "Group Name: $($group.Name)" -Encoding ascii
            Add-Content $OutputFile "Group Description: $($group.Description)" -Encoding ascii
            Add-Content $OutputFile "Group SID: $($group.SID)" -Encoding ascii
            Add-Content $OutputFile "------------------" -Encoding ascii
        }
    } else {
        Add-Content $OutputFile "The user $User is not a member of any group" -Encoding ascii
    }

# Gather information about groups in another domain
Add-Content $OutputFile "`n=== Group Info for Another Domain ===" -Encoding ascii
$Domain = Read-Host "Please insert the domain name you would like to perform group enumeration"
$groups = Get-CimInstance -ClassName win32_groupindomain | Where-Object {$_.GroupComponent -match $Domain} | Foreach-Object {[wmi]$_.PartComponent}
if ($groups) {
    Add-Content $OutputFile "The following groups are available in the $Domain domain:`n"
    foreach ($group in $groups) {
        Add-Content $OutputFile "Group Name: $($group.Name)" -Encoding ascii
        Add-Content $OutputFile "Group Description: $($group.Description)" -Encoding ascii
        Add-Content $OutputFile "Group SID: $($group.SID)" -Encoding ascii
        Add-Content $OutputFile "------------------"
    }
} else {
    Add-Content $OutputFile "There are no groups available in the $Domain domain" -Encoding ascii
}
}
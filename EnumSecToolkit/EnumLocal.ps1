function EnumLocal () {
    param(
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

    "[+] System Information (Look for vulnerablilities with the OS Version)" | addContent -color "Green"
    systeminfo | Out-String | addContent


    # Enum AV
    $antivirusProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct

    if ($antivirusProducts -ne $null) {
        "`n[+] Installed Antivirus Products:`n" | addContent -color "red"

        foreach ($product in $antivirusProducts) {
            $displayName = $product.displayName
            $pathToSignedProductExe = $product.pathToSignedProductExe
            $pathToSignedReportingExe = $product.pathToSignedReportingExe
            $productState = $product.productState

            "Name: $displayName"  | addContent
            "Path to Product Executable: $pathToSignedProductExe"  | addContent
            "Path to Reporting Executable: $pathToSignedReportingExe"  | addContent
            "Product State: $productState"  | addContent
            Write-Host "" 
        }
    } else {
        "`n[-] No antivirus products found.`n" | addContent -color "Green"
    }

    $wmi = [wmiclass]"root\default:StdRegProv"

    # Define the registry key and value name
    $registryKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    $hklm = 2147483650

    # Get the subkeys and values under the specified registry key
    $subKeys = $wmi.EnumKey($hklm, $registryKey)
    $values = $wmi.EnumValues($hklm, $registryKey)

    # Display the results
    "`n[*] Audit Policies (If empty - none found): `n" | addContent -color "Yellow"
    if ($subKeys.sNames -ne $null) {
        "Subkeys:" | addContent
        $subKeys.sNames  | addContent
    }

    if ($values.sNames -ne $null) {
        "Values:" | addContent
        for ($i = 0; $i -lt $values.sNames.Count; $i++) {
            $valueName = $values.sNames[$i]
            $valueType = $values.Types[$i]
            $valueData = $wmi.GetStringValue($hklm, $registryKey, $valueName)
            "$($valueName) : $($valueData.sValue)"  | addContent
        }
    }

    # LAPS
    # Define the registry key and value name
    $registryKey = "SOFTWARE\Policies\Microsoft Services\AdmPwd"
    $valueName = "AdmPwdEnabled"

    # Get the value data for the specified registry value
    $valueData = $wmi.GetDWORDValue($hklm, $registryKey, $valueName)

    # Display the result
    if ($valueData.uValue -ne $null) {
        "`n[-] LAPS has been detected" | addContent -color "Yellow"
        "Value: $($valueName)"  | addContent
        "Data: $($valueData.uValue)"  | addContent


    } else {
        "`n[+] No LAPS detected" | addContent -color Green
    }

    # Find AppLocker Policies
    $applocker = Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections

    if ($applocker) {
        "`n[+] Found Applocker rules`n" | addContent -color red
        $applocker | addContent
    }
    else {
        "`n[-] No Applocker rules were found`n" | addContent -color 'Green'
    }

    # PPL
    # Define the registry key and value name
    $registryKey = "SYSTEM\CurrentControlSet\Control\LSA"
    $valueName = "RunAsPPL"

    # Get the value data for the specified registry value
    $valueData = $wmi.GetDWORDValue($hklm, $registryKey, $valueName)

    # Display the result
    if ($valueData.uValue -ne $null) {
        "`n[*] Potentially RunAsPPL Detected`n" | addContent -color 'Yellow'
        "If 1 or 2 - PPL is active" | addContent
        "Value: $($valueName)" | addContent
        "Data: $($valueData.uValue)" | addContent
    } else {
        "`n[+] No RunAsPPL Detected`n" | addContent -color Green
    }

    # Installed Programs
    "`n[+] Installed Programs`n" | addcontent -color Green
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, Publisher, InstallDate, Version | ?{$_.displayName -ne $null}  | addContent

    $localgroups = Get-WmiObject -ClassName Win32_Group | Where-Object {$_.LocalAccount -eq $true}
        if ($localgroups) {
            "`n[+] The following local groups are available on the system:`n" | addcontent -color 'green'
            foreach ($group in $localgroups) {
                "Group Name: $($group.Name)" | addContent
                "Group Description: $($group.Description)" | addContent 
                "Group SID: $($group.SID)" | addContent
                "------------------" | addContent 
            }
        } else {
            "[-] There are no local groups available on the system" | addContent -color 'Red'
        }

    # Local users
    $localusers = Get-WmiObject -ClassName Win32_UserAccount | Where-Object {$_.LocalAccount -eq $true}
    if ($localusers) {
        "`n[+] The following local users are available on the system:`n" | addcontent -color 'Green'
        foreach ($user in $localusers) {
            "User Name: $($user.Name)`nUser Description: $($user.Description)`nUser SID: $($user.SID)`n------------------" | addContent
        }
    } else {
        "There are no local users available on the system" | addContent
    }

    "`n[+] Getting environment variables`n" | addContent -color 'Green'
    Get-Wmiobject -ClassName Win32_Environment | Select -Property Name, VariableValue | Out-String | addContent


    "`n[+] Listing System Shares`n" | addContent -color 'Green'
    Get-WmiObject -ClassName Win32_Share | select Name,Path  | addContent

    "`n[*] Checking Privileges`n" | addContent -color Yellow
    # Enumerating SeImpersonate | SeDebug privileges
    $priv = whoami /priv
    $i = 6
    for ($i; $i -lt $priv.count; $i++) {
        if ($priv[$i] -match "SeImpersonate|SeDebug|SeBackup|SeTcb|SeCreateToken|SeTakeOwnership|SeLoadDriver") {
            "[+] Found dangerous privilege: `n" | addContent -color 'Green'
            $priv[$i] | addContent
        }
    }

    Write-Host "`n[*] Enumerating vulnerable services" | addContent -color 'Green'
    # allowed to edit binpath of folder
    $services = Get-WmiObject -Class Win32_Service
    foreach ($service in $services) {
        if ($service.PathName -and $service.PathName -notmatch "^C:\\windows\\system32") {
            $binaryPath = (Split-Path -Path $service.PathName).Trim('"')
            $acl = $null
            $acl = (Get-Acl -Path $binaryPath -ErrorAction SilentlyContinue).Access | Where-Object {
                ($_.FileSystemRights -match "(FullControl|Modify|Write)") -and
                ($_.IdentityReference -match "(Everyone|Authenticated Users|Todos|Usuarios|$($env:username))")
            }
            if ($acl) {
                "    [!] You can edit the service $($service.name) bin path: $($service.PathName)" | addContent -color Green 
            }
        }
    }

    # unquoted path
    $services = Get-WmiObject -Class Win32_Service
    foreach ($service in $services) {
        if ($service.PathName -and $service.PathName -notmatch "^C:\\windows\\system32" -and $service.PathName -notmatch '^"') {
            $binaryPath = Split-Path -Path $service.PathName
            if ($binaryPath -match "[A-Z][ ][A-Z]") {
                "`n    [*] Discovered service '$($service.Name)' with an unquoted path." | addContent -color 'Yellow'
                "    $($service.PathName)" | addContent
                $acl = $null
                $acl = (Get-Acl -Path $binaryPath).Access | Where-Object {
                    ($_.FileSystemRights -match "(FullControl|Modify|Write)") -and
                    ($_.IdentityReference -match "(Everyone|Authenticated Users|Todos|$($env:username))")
                }
                if ($acl) {
                    "`n    [!] The service can be leveraged to escalate privileges" | addcontent -color 'Green'
                    foreach ($entry in $acl) {
                        "    $($entry.IdentityReference.Value)" | addContent
                    }
                }
                else {
                    "`n [-] The service likely cannot be used for escalation" | addContent -color Red
                }

                "`n" | addContent
            }
        }
    }

    # SAM backups
    "`n[*] Checking for backup SAM files`n" | addContent -color 'Yellow'
    $paths = @(
    "$($env:windir)\repair\SAM",
    "$($env:windir)\System32\config\RegBack\SAM",
    "$($env:windir)\System32\config\SAM",
    "$($env:windir)\repair\SYSTEM",
    "$($env:windir)\System32\config\SYSTEM",
    "$($env:windir)\System32\config\RegBack\SYSTEM"
    )

    foreach ($path in $paths) {
        if (Test-Path $path -ErrorAction SilentlyContinue) {
            "$path exists." | addContent -color 'Green'
        }
    }

    # app cmd
    "`n[*] Checking for AppCmd.exe`n" | addContent -color Yellow
    $path = "$($env:systemroot)\system32\inetsrv\appcmd.exe"
    if (Test-Path $path) {
        "$path exists." | addContent -color 'Green'
    }


    # Check for AlwaysInstallElevated registry key
    $regKeys = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE").GetSubKeyNames() |
        ForEach-Object { [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\\$_") } |
        Where-Object { $_.OpenSubKey("Policies") -and $_.OpenSubKey("Policies").GetSubKeyNames() -contains "Microsoft" } |
        ForEach-Object { $_.OpenSubKey("Policies\\Microsoft") } |
        Where-Object { $_.OpenSubKey("Windows") -and $_.OpenSubKey("Windows").GetSubKeyNames() -contains "Installer" } |
        ForEach-Object { $_.OpenSubKey("Windows\\Installer") } |
        Where-Object { $_.GetValueNames() -contains "AlwaysInstallElevated" } | 
        ForEach-Object { $_.GetValue("AlwaysInstallElevated") }
    if ($regKeys) {
        $regKeys = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated: ' + $regKeys 
        "[+] Potential AlwaysInstallElevated registry value found:" | addContent -color 'Green'
        $regKeys  | Format-Table -AutoSize | addContent
    } else {
        "[-] No potential AlwaysInstallElevated registry value found." | addContent -color 'Red'
    }

    # Check for CMDKey
    "`n[*] Saved Credentials`n" | addContent -color 'yellow'
    "To use: runas /savedcred /user:<name> powershell.exe`n" | addContent
    cmdkey /list  | Out-String | addContent

    # Sess hijack oppurtinities
    "`n[*] Sess Hijack oppurtinities`n" | addContent -color 'Yellow'
    quser | Out-String | addContent

    # Wifi Passwords
    "`n[*] Trying to find saved Wifi creds`n" | addContent -color 'Yellow'
    $wlanProfiles = netsh wlan show profiles | Select-String -Pattern "Profile"
    foreach ($profile in $wlanProfiles) {
        $profileName = ($profile -split ": ")[1]
        $wlanProfileDetails = netsh wlan show profiles name=$profileName key=clear | Select-String -Pattern "SSID|Cipher|Content" | Where-Object { $_ -notmatch "Number" }
        $wlanProfileDetails  | addContent
        "" | addContent
    }

    "[*] Checking for potential DLL hijacking oppurtinities" | addcontent
    # Potential DLL hijack
    $processes = Get-WmiObject -Class Win32_Process
    foreach ($process in $processes) {
        $executablePath = $process.ExecutablePath
        if ($executablePath -and $executablePath -notmatch "system32") {
            $acl = $null
            $folderPath = Split-Path -Path $executablePath
            $acl = (Get-Acl -Path $folderPath -ErrorAction SilentlyContinue).Access | Where-Object {
                ($_.FileSystemRights -match "(FullControl|Modify|Write)") -and
                ($_.IdentityReference -match "(Everyone|Authenticated Users|Todos|$($env:username))")
            }
            if ($acl) {
                "`n    [!] Found potential DLL hijacking for process:  $($process.ExecutablePath)" | addcontent -color 'Green'
            }
        }
    }

    # users folder for potential cloud credentials
    $filesToSearch = @(
    ".aws",
    "credentials",
    "gcloud",
    "credentials.db",
    "legacy_credentials",
    "access_tokens.db",
    ".azure",
    "accessTokens.json",
    "azureProfile.json"
)

    $usersFolder = Join-Path -Path $env:SystemDrive -ChildPath "Users"
    $docsAndSettingsFolder = Join-Path -Path $env:windir -ChildPath "..\Documents and Settings"

    function Search-Files ($path, $files) {
        (Get-ChildItem -Path $path -Include $files -Recurse -ErrorAction SilentlyContinue -Force).FullName  | addContent
    }

    "`n[*] Searching for cloud creds in $usersFolder`n" | addcontent -color 'Yellow'
    Search-Files -path $usersFolder -files $filesToSearch

    Write-Host "`n[*]Searching for cloud creds in $docsAndSettingsFolder`n" -ForegroundColor Yellow
    Search-Files -path $docsAndSettingsFolder -files $filesToSearch

    # GPP passwords
    $filesToSearch = @(
    "Groups.xml",
    "Services.xml",
    "Scheduledtasks.xml",
    "DataSources.xml",
    "Printers.xml",
    "Drives.xml"
    )

    $groupPolicyHistoryFolder = Join-Path -Path $env:SystemDrive -ChildPath "Microsoft\Group Policy\history"
    $allUsersAppDataFolder = Join-Path -Path $env:windir -ChildPath "..\Documents and Settings\All Users\Application Data\Microsoft\Group Policy\history"

    Write-Host "`n[*] Searching for GPPP passwords in $groupPolicyHistoryFolder`n" -ForegroundColor Yellow
    Search-Files -path $groupPolicyHistoryFolder -files $filesToSearch

    Write-Host "`n[*] Searching for GPPP in $allUsersAppDataFolder`n" -ForegroundColor Yellow
    Search-Files -path $allUsersAppDataFolder -files $filesToSearch

    # MCAFEE sitexml
    $filesToSearch = "SiteList.xml"

    $programFilesFolder = $env:ProgramFiles
    $programFilesX86Folder = ${env:ProgramFiles(x86)}
    $docsAndSettingsFolder = Join-Path -Path $env:windir -ChildPath "..\Documents and Settings"
    $usersFolder = Join-Path -Path $env:windir -ChildPath "..\Users"

    Write-Host "`n[*] Searching for SiteList.xml file for MCAfee`n" -ForegroundColor Yellow
    Search-Files -path $programFilesFolder -files $filesToSearch
    Search-Files -path $programFilesX86Folder -files $filesToSearch
    Search-Files -path $docsAndSettingsFolder -files $filesToSearch
    Search-Files -path $usersFolder -files $filesToSearch

    if (Test-Path "C:\transcripts\") {
        "[+] Found C:\Transcripts folder" | addContent -color 'Green'
    }
    else {
        "[-] No C:\transcripts folder" | addContent -color 'Red'
    }

    # Check for Unattend files
    "`n[*] Searching for files with credentials, unattend, etc`n This can take a few minutes.." | addContent -color 'Yellow'

$filesToSearch = @(
    '^vnc\.ini$', '^ultravnc\.ini$',
    '^web\.config$',
    '^php\.ini$', '^httpd\.conf$', '^httpd-xampp\.conf$', '^my\.ini$', '^my\.cnf$',
    '^SiteList\.xml$',
    '^ConsoleHost_history\.txt$',
    '.*\.gpg$',
    '.*\.pgp$',
    '.*config.*\.php$',
    'elasticsearch\.y.*ml$',
    'kibana\.y.*ml$',
    '.*\.p12$',
    '.*\.der$',
    '.*\.csr$',
    '.*\.cer$',
    '^known_hosts$',
    '^id_rsa$',
    '^id_dsa$',
    '.*\.ovpn$',
    '^anaconda-ks\.cfg$',
    '^hostapd\.conf$',
    '^rsyncd\.conf$',
    '^cesi\.conf',
    '^supervisord\.conf$',
    '^tomcat-users\.xml$',
    '.*\.kdbx$',
    '^KeePass\.config$',
    '^FreeSSHDservice\.ini$',
    '^access\.log$',
    '^error\.log$',
    '^server\.xml$',
    '^setupinfo$',
    '^setupinfo\.bak$',
    '^key3\.db$',
    '^key4\.db$',
    '^places\.sqlite$',
    '^Login Data$',
    '^Cookies$',
    '^Bookmarks$',
    '^History$',
    '^TypedURLsTime$',
    '^TypedURLs$', 
    '^sysprep\.inf$', 
    '^sysprep\.xml$', 
    '^unattended\.xml$', 
    '^unattend\.xml$', 
    '^unattend\.txt$',
    '.*\.keytab$'
    )


    Get-ChildItem -Path 'C:\users\' -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
        $fileName = $_.Name
        $matched = $false
        foreach ($pattern in $filesToSearch) {
            if ($fileName -match $pattern) {
                $matched = $true
                break
            }
        }
        $matched
    } | Select-Object -ExpandProperty FullName | addContent

}


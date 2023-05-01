$outputfile = $null
if (!$outputfile) {
    $outputfile = (Get-Location).Path + "\"
}
function Show-Menu {

    Clear-Host
    $banner = '4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4pWX4paR4paR4paI4paI4pWX4paI4paI4pWX4paR4paR4paR4paI4paI4pWX4paI4paI4paI4pWX4paR4paR4paR4paI4paI4paI4pWX4p
    aR4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWX4paR4paI4paI4paI4paI4paI4pWX4paR4paI4paI4paI4paI4paI4paI4paI4paI4pWX4paR4paI4paI4paI4paI
    4paI4pWX4paR4paR4paI4paI4paI4paI4paI4pWX4paR4paI4paI4pWX4paR4paR4paR4paR4paR4paI4paI4pWX4paR4paR4paI4paI4pWX4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4p
    aI4pWXDQrilojilojilZTilZDilZDilZDilZDilZ3ilojilojilojilojilZfilpHilojilojilZHilojilojilZHilpHilpHilpHilojilojilZHilojilojilojilojilZfilpHilojilojiloji
    lojilZHilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZfilZrilZDilZDilojilojilZTilZDilZDilZ3ilojilojilZ
    TilZDilZDilojilojilZfilojilojilZTilZDilZDilojilojilZfilojilojilZHilpHilpHilpHilpHilpHilojilojilZHilpHilojilojilZTilZ3ilojilojilZHilZrilZDilZDilojiloji
    lZTilZDilZDilZ0NCuKWiOKWiOKWiOKWiOKWiOKVl+KWkeKWkeKWiOKWiOKVlOKWiOKWiOKVl+KWiOKWiOKVkeKWiOKWiOKVkeKWkeKWkeKWkeKWiOKWiOKVkeKWiOKWiOKVlOKWiOKWiOKWiOKWiO
    KVlOKWiOKWiOKVkeKVmuKWiOKWiOKWiOKWiOKWiOKVl+KWkeKWiOKWiOKWiOKWiOKWiOKVl+KWkeKWkeKWiOKWiOKVkeKWkeKWkeKVmuKVkOKVneKWkeKWkeKWkeKWiOKWiOKVkeKWkeKWkeKWkeKW
    iOKWiOKVkeKWkeKWkeKWiOKWiOKVkeKWiOKWiOKVkeKWkeKWkeKWiOKWiOKVkeKWiOKWiOKVkeKWkeKWkeKWkeKWkeKWkeKWiOKWiOKWiOKWiOKWiOKVkOKVneKWkeKWiOKWiOKVkeKWkeKWkeKWke
    KWiOKWiOKVkeKWkeKWkeKWkQ0K4paI4paI4pWU4pWQ4pWQ4pWd4paR4paR4paI4paI4pWR4pWa4paI4paI4paI4paI4pWR4paI4paI4pWR4paR4paR4paR4paI4paI4pWR4paI4paI4pWR4pWa4paI
    4paI4pWU4pWd4paI4paI4pWR4paR4pWa4pWQ4pWQ4pWQ4paI4paI4pWX4paI4paI4pWU4pWQ4pWQ4pWd4paR4paR4paI4paI4pWR4paR4paR4paI4paI4pWX4paR4paR4paR4paI4paI4pWR4paR4p
    aR4paR4paI4paI4pWR4paR4paR4paI4paI4pWR4paI4paI4pWR4paR4paR4paI4paI4pWR4paI4paI4pWR4paR4paR4paR4paR4paR4paI4paI4pWU4pWQ4paI4paI4pWX4paR4paI4paI4pWR4paR
    4paR4paR4paI4paI4pWR4paR4paR4paRDQrilojilojilojilojilojilojilojilZfilojilojilZHilpHilZrilojilojilojilZHilZrilojilojilojilojilojilojilZTilZ3ilojilojilZ
    HilpHilZrilZDilZ3ilpHilojilojilZHilojilojilojilojilojilojilZTilZ3ilojilojilojilojilojilojilojilZfilZrilojilojilojilojilojilZTilZ3ilpHilpHilpHilojiloji
    lZHilpHilpHilpHilZrilojilojilojilojilojilZTilZ3ilZrilojilojilojilojilojilZTilZ3ilojilojilojilojilojilojilojilZfilojilojilZHilpHilZrilojilojilZfilojilo
    jilZHilpHilpHilpHilojilojilZHilpHilpHilpENCuKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVneKWkeKWkeKVmuKVkOKVkOKVneKWkeKVmuKVkOKVkOKVkOKVkOKVkOKVneKWkeKV
    muKVkOKVneKWkeKWkeKWkeKWkeKWkeKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVneKWkeKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKWkeKVmuKVkOKVkOKVkOKVkOKVneKWkeKWkeKWkeKWke
    KVmuKVkOKVneKWkeKWkeKWkeKWkeKVmuKVkOKVkOKVkOKVkOKVneKWkeKWkeKVmuKVkOKVkOKVkOKVkOKVneKWkeKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVneKWkeKWkeKVmuKVkOKV
    neKVmuKVkOKVneKWkeKWkeKWkeKVmuKVkOKVneKWkeKWkeKWkQ=='
    $banner = [System.Convert]::FromBase64String($banner)
    $banner = [System.Text.Encoding]::UTF8.GetString($banner)
    Write-host "`n"
    Write-Host "================================================" -ForegroundColor DarkCyan
    Write-host "`n"
    Write-Host $banner -ForegroundColor DarkCyan
    Write-host "`n Authors: Matan Bahar and Yehuda Smirnov`n Version: 0.2 beta`n Only for educational purposes`n" -ForegroundColor Gray
    Write-Host "================ EnumSecToolKit ================" -ForegroundColor DarkCyan
    Write-host "`nOutput set to: $outputfile`n" -ForegroundColor Yellow
    Write-Host '1: Run Script EnumDomainLDAP.ps1'
    Write-Host '2: Run Script EnumDomainWMI.ps1'
    Write-Host '3: Run Script EnumLocal.ps1'
    Write-Host '4: Run Script ACLFinder.ps1'
    Write-Host '5: Run Script EnumSQL.ps1'
    Write-Host '6: Run Script EnumLocalAdminAccess.ps1'
    Write-host "`n==== Modules to load ===="
    Write-Host '7: Run Script LoadADModule.ps1'
    Write-Host '8: Run Script LoadSQLServerModule.ps1'
    Write-Host ''
    Write-Host 'S: Set output folder'
    Write-Host 'Q: Quit'
    Write-Host ''
}

function Test-WriteAccess () {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )

    try {
        $tmpFile = Join-Path $FolderPath ([System.IO.Path]::GetRandomFileName())
        $null = New-Item -ItemType File -Path $tmpFile -ErrorAction Stop
        Remove-Item -Path $tmpFile -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function ListenForC () {
    $messageTemp = $true
    do {
        if ($messageTemp) {
            Write-Host "Press C to continue.."
            $messageTemp = $false
        }
        $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } while ($keyInfo.VirtualKeyCode -ne 67)  # 67 is the VirtualKeyCode for the 'C' key

    Write-Host "Continuing execution..."
    Start-Sleep(2)
}

while ($true) {
    Show-Menu
    $Userinput = Read-Host 'Please make a selection'
    switch ($Userinput) {
        '1' {
            Write-Host 'Executing Script EnumDomainLDAP.ps1'
            . .\EnumDomainLDAP.ps1
            $outputfileTemp = $outputfile + "EnumDomainLDAP_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
            EnumDomainLDAP -verbose -OutputFile $outputfileTemp
            ListenForC
        }
        '2' {
            Write-Host 'Executing EnumDomainWMI.ps1'
            . .\EnumDomainWMI.ps1
            enumDomainWMI
            ListenForC
        }
        '3' {
            Write-Host 'Executing EnumLocal.ps1'
            pwd
            . .\EnumLocal.ps1
            $outputfileTemp = $outputfile + "EnumLocal_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
            EnumLocal -OutputFile $outputfileTemp
            ListenForC
        }
        '4' {
            Write-Host "Executing ACLFinder.ps1"
            Write-Host "If you want to search ACLs for a specific user, enter his name (eg. StudentUser1).`nIf you want to search all ACLs, leave empty"
            $outputfileTemp = $outputfile + "ACLFinder_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
            . .\ACLFinder.ps1
            $username = Read-Host
            if ($username) {
                ACLFinder -username $username -OutputFile $outputfileTemp
            }
            else {
                ACLFinder -OutputFile $outputfileTemp
            }
            ListenForC
        }
        '5' {
            Write-Host "Executing EnumSQL.ps1"
            $outputfileTemp = $outputfile + "EnumSQL_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
            . .\EnumSQL.ps1
            EnumSQL -verbose -outputfile $outputfileTemp
            ListenForC
        }
        '6' {
            Write-Host "Executing EnumLocalAdmin.ps1..`n"
            $outputfileTemp = $outputfile + "EnumLocalAdmin_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
            . .\EnumLocalAdmin.ps1
            $method = Read-Host "[*] Choose a method to use:`n1 - WMI, 2 - DCOM, 3 - PSRemoting, 4 - RPC"
            $t = Read-Host "[*] Choose:`n1 - Find computers using Domain Name, 2 - Provide path to file with computers"
            if ($t -eq '1') {
                $b = Read-Host "[*] Insert domain name"
                enumLocalAdmin -domain $b -outputfile $outputfileTemp -method $method
                ListenForC
            }
            elseif ($t -eq '2') {
                $b = Read-Host "`nInsert path to computerfile list.."
                enumLocalAdmin -pcFileList $b -outputfile $outputfileTemp -method $method
                ListenForC
            }
            else {
                Write-Host "[-] Bad prompt, returning to menu.." -ForegroundColor Red
                ListenForC
            }
        }
        '7' {
            Write-Host 'Executing LoadADModule.ps1'
            . .\LoadADModule.ps1
            LoadADModule
            ListenForC
        }
        '8' {
            Write-Host "Executing LoadSQLServerModule.ps1"
            . .\LoadSQLServer.ps1
            LoadSQLServerModule
            ListenForC
        }
        'S' {
            Write-Host "Enter the path you would like to save output to:"
            $outputfile = Read-Host 
            while ($true) {
                if ((Test-Path $outputfile) -and (Test-WriteAccess -FolderPath $outputfile)) {
                    Write-Host "[+] Set path to $outputfile" -ForegroundColor Green
                    $outputfile += "\"
                    ListenForC
                    break
                }
                else {
                    Write-Host "Invalid path, either it does not exist or you do not have write permissions.`nEnter a path to save output to."
                    $outputfile = Read-Host
                }
            }
        }
        'Q' {
            return
        }
        default {
            Write-Host 'Invalid selection, please try again.'
            Start-Sleep -Seconds 1
        }
    }
}

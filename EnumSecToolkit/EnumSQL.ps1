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

function EnumSQL () {
    [CmdletBinding()]
    Param(
        [string]$outputfile
    )



    $continueLoop = $true
    while ($continueLoop) {
        Show-MenuSQL
        $Userinput = Read-Host 'Please make a selection'
        switch ($Userinput) {
            '1' {
                Write-Output 'Broadcasting UDP to find SQL instances..'
                enumSQLUDPBroadcast
                $continueLoop = $false
            }
            '2' {
                Write-Output 'Provide a file containing full DnsHostName of machines with 1433 open'
                enumSQLFromFile
                $continueLoop = $false
            }
            'Q' {
                return
            }
            default {
                Write-Output 'Invalid selection, please try again.'
                Start-Sleep -Seconds 1
            }
        }
    }
}
function Show-MenuSQL () {
    Clear-Host
    Write-Output "`n`n ==== EnumSQL.ps1 ===`n`n"
    Write-Output '1: Broadcast UDP to find SQL Instances (Noisy but effective)'
    Write-Output '2: Provide a list of DNSHostNames with port 1433 open'
    Write-Output 'Q: Quit'
}

function enumSQLUDPBroadcast () {
    [CmdletBinding()]
    Param(
        [string]$outputfile
    )
    # Enumerate SQL instances
    Write-Verbose "Enumerating SQL instances.."
    $instances = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()

    
    # Checking there instances available
    if (!$instances) {
        "[-] No SQL Instances were found." | addContent -color 'Red'
        return $null
    }

    # Checkikng access to SQL instances
    Write-Verbose "Checking access to SQL instances.."
    $accessibleInstances = ''
    foreach ($ins in $instances) {

        if ([string]::IsNullOrEmpty($ins.InstanceName)) {
            Write-Verbose "Something did not go as expected.. Got a list of instances but seems an instnaceName is not set on the instance itself.. Skipping to the next iteration"
            continue
        }

        $serverName = $ins.ServerName
        $instanceName = $ins.InstanceName
        $connectionString = "Server=$serverName\$instanceName;Integrated Security=True;"

        Try {
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $connectionString
            $connection.Open()
            "Connected successfully to the SQL Server instance $serverName\$instanceName" | addContent -color 'Green'
            $accessibleInstances += "$serverName\$instanceName`n"

        }
        Catch {
            "Failed to connect to the SQL Server instance $serverName\$instanceName" | addcontent -color 'Red'
            "Error: $_" | addcontent -color 'Red'
        }
        Finally {
            if ($null -ne $connection) {
                $connection.Close()
                }
        }
    }

    # Printing results

    "`n[+] Discovered SQL Instances`n" | addcontent -color 'Green'
    $instances | addContent

    if ($accessibleInstances) {
        "`n[+] Accessible instances:`n" | addcontent -color 'Green'
        $accessibleInstances | addcontent
    }

}

function enumSQLFromFile() {
    [CmdletBinding()]
    Param(
        [string]$outputfile
    )
    
    # Getting the file with computers with port 1443
    function Get-FilePath {
        $filePath = $null

        while (!$filePath) {
            $filePath = Read-Host "Please enter the file path or press Q to quit"
            if ($filePath -eq "Q") { return $null }
            if (!(Test-Path $filePath)) {
                Write-Warning "[*] The specified file does not exist. Please try again."
                $filePath = $null
            }
        }

        return $filePath
    }

    $filePath = Get-FilePath
    $fileContent = get-content -Path $filePath

    # Checkikng access to SQL instances
    Write-Verbose "Checking access to SQL instances.."
    $accessibleInstances = ''
    foreach ($serverName in $fileContent) {

        $connectionString = "Server=$serverName,1433;Integrated Security=True;"

        Try {
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $connectionString
            $connection.Open()
            "Connected successfully to the SQL Server $serverName on port 1433" | addcontent -color 'Green'
            $accessibleInstances += "$serverName | Port 1433`n"

        }
        Catch {
            "Failed to connect to the SQL Server $serverName on port 1433" | addcontent -color 'Red'
            "Error: $_" | addcontent -color 'Red'
        }
        Finally {
            if ($null -ne $connection) {
                $connection.Close()
                }
        }
    }

    # Printing results

    if ($accessibleInstances) {
        "`n[+] Accessible instances:`n" | addcontent -color 'Green'
        $accessibleInstances | addcontent
    }

}
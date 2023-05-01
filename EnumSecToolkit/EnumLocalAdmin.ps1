function enumLocalAdmin () {
    <#
     .SYNOPSIS
     This function finds local adm access. 
 
     .PARAMETER Domain
     Specifies the target AD domain.
 
     .PARAMETER Method
     Method to check: 1 - via WMI, 2 - Via DCOM, 3 - Via PSRemoting, 4 - Via RPC
 
     .PARAMETER pcFileList
     Provide a file containing a list of computers
 
     #>
    param (
        [Parameter()]
        [string]$OutputFile,
        [string]$method,
        [string]$domain,
        $pcFileList
    )
 
    # Declare some helper functions
    function Test-ComputerNamesFile {
        param(
            [string]$FilePath
        )
     
        if (!(Test-Path -Path $FilePath -PathType Leaf)) {
            Write-Host "The specified path is not a valid file." -ForegroundColor "Red"
            return $false
        }
     
        $content = Get-Content -Path $FilePath
     
        $validComputerNameRegex = '^[a-zA-Z0-9.-]+$'
     
        foreach ($line in $content) {
            if (-not ($line -match $validComputerNameRegex)) {
                Write-Host "The file contains an invalid computer name: $line" -ForegroundColor "Red"
                return $false
            }
        }
     
        return $true
    }
 
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
 
    # Check either no domain or file list provided or both
    if ((!$domain -and !$pcFileList) -or ($domain -and $pcFileList)) {
        Write-Host "Please provide either a domain name or a list of computers." -ForegroundColor "Red"
        return
    }
    # check that a method was provided
    if (!$method) {
        Write-Host "Please provide a -method" -ForegroundColor "red"
        return
    }
 
    # check the validy of the file containing machine names
    if ($pcFileList) { 
        if (!(Test-ComputerNamesFile -FilePath $pcFileList)) {
            return
        }
    }
 
    # Get computer list from domain if needed
    if ($domain) {
        # Load required .NET assemblies
        Add-Type -AssemblyName System.DirectoryServices
         
        # Set LDAP path
        $ldapPath = "LDAP://$domain"
         
        # Create DirectorySearcher object
        $root = New-Object System.DirectoryServices.DirectoryEntry($ldapPath)
        $searcher = New-Object System.DirectoryServices.DirectorySearcher($root)
         
        # Set searcher properties
        $searcher.PageSize = 100
        $searcher.Filter = "(&(objectCategory=computer)(objectClass=top))"
         
        # Retrieve all computer objects
        try {
            $computers = $searcher.FindAll()
        }
        catch {
            Write-Host "[-] No computers found from the domain specified.." -ForegroundColor Red
            throw
            return
        }
        $pcFileList = @()
        foreach ($c in $computers) {
            $pcFileList += $c.Properties['name']
        }
    }
    else {
        $pcFileList = Get-Content -Path "$pcFileList"
    }

 
    # The actual script begins
    switch ($method) {
        # Using WMI
        '1' {
            $resultTrue = ''
            $resultFalse = ''
                
            foreach ($c in $pcFileList) {
            
                # skip localhost
                if ($c -contains (hostname)) { continue }

                # try connecting to remote machine
                try {
                    $OSInfo = $null
                    Write-Verbose "Testing $c"
                    $OSInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $c -ErrorAction Stop
                    
                    # if successful
                    if ($OSInfo) {
                        $resultTrue += "$c"
                    }
                }
                catch {
                    $resultFalse += "$c"
                }
            }
         
            if ($resultTrue) {
                "`n[+] Discovered local admin using WMI: `n" | addContent -color 'green'
                $resultTrue | out-string | addContent
            }
            else {
                "`n[-] No local admin access using WMI." | addContent -color 'red'
                "`n[*] Tested computers:" | addcontent -color 'Yellow'
                $resultFalse | addcontent
            }
        }
        # Using DCOM
        '2' {
            $sessoptions = New-CimSessionOption -Protocol Dcom
            $resultTrue = ''
            $resultFalse = ''

            foreach ($c in $pcFileList) {

                if (($c -contains (hostname))) { continue }

                try {
                    
                    $sess = $null
                    $sess = New-CimSession -ComputerName $c -SessionOption $sessoptions -ErrorAction Stop
                    
                    # if successful
                    if ($sess) {
                        $resultTrue += "$c"
                    }
                }
                catch {
                    $resultFalse += "$c"    
                }
            }

            if ($resultTrue) {
                "`n[+] Discovered local admin using DCOM: `n" | addContent -color 'green'
                $resultTrue | out-string | addContent
            }
            else {
                "`n[-] No local admin access using DCOM." | addContent -color 'red'
                "`n[*] Tested computers:" | addcontent -color 'Yellow'
                $resultFalse | addcontent
            }
        }
        # Using PSRemoting
        '3' {
            $resultTrue = ''
            $resultFalse = ''

            foreach ($c in $pcFileList) {

                if (($C -contains (hostname))) { continue }

                $testCmd = $null
                $testCmd = New-PSSession -ComputerName $c -ErrorAction SilentlyContinue

                if ($testCmd) {
                    $resultTrue += "$c"
                }
                else {
                    $resultFalse += "$c"    
                }

            }

            if ($resultTrue) {
                "`n[+] Discovered local admin using PS Remoting: `n" | addContent -color 'green'
                $resultTrue | out-string | addContent
            }
            else {
                "`n[-] No local admin access using PS Remoting." | addContent -color 'red'
                "`n[*] Tested computers:" | addcontent -color 'Yellow'
                $resultFalse | addcontent
            }
            
        }
        # Using RPC
        '4' {
            $resultTrue = ''
            $resultFalse = ''

            foreach ($c in $pcFileList) {

                if (($C -contains (hostname))) { continue }

                try {
                    $reghive = 2147483650
                    $regkeypath = ''
                    $subkey = $null
                    
                    $remotereg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($reghive, $c)
                    $subkey = $remotereg.OpenSubKey($remotereg)
                    $resultTrue += "$c"   
                }
                catch {
                    $resultFalse += "$c"
                }
            }

            if ($resultTrue) {
                "`n[+] Discovered local admin using RPC (Registry): `n" | addContent -color 'green'
                $resultTrue | out-string | addContent
            }
            else {
                "`n[-] No local admin access using RPC (Registry)." | addContent -color 'red'
                "`n[*] Tested computers:" | addcontent -color 'Yellow'
                $resultFalse | addcontent
            }
        }
        default {
            Write-Host "[-] Bad method.." -ForegroundColor Red
        }
    }
}
Function ACLFinder {
    <#
    .SYNOPSIS
    ACLFinder finds interesting ACLs in the domain which have GenericAll, GenericWrite, all extended rights, etc. 

    Author: Yehuda Smirnov

    .PARAMETER Username
    Optional, if specified, will enumerate ACLs for the specific user.

    .EXAMPLE
    Enumerate ACLs for user.
    ACLFinder -Username StudentUser52
    .EXAMPLE
    Enumerate ACLs for all users on all AD objects which SID are higher than 1000
    ACLFinder

    #>
    param (
        [string]$Username,
        [string]$OutputFile
    )

    if ($Username)
    {
        $filter = groupWrapper $Username
    }
    else
    {
        $filter = getFilterGT1000
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
    Write-Warning "This script requires ADModule!"

    $objects = Get-ADObject -Filter *

    foreach ($object in $objects) {
        $acl = Get-ACL -Path ("AD:" + $object.DistinguishedName)

        if ($Username)
        {
            $access = $acl.Access | Where-Object {($_.IdentityReference -match "$filter") -and ($_.ActiveDirectoryRights -match "GenericAll|Write|Create|Delete" -or $_.ActiveDirectoryRights -match "ExtendedRight") -and ($_.IdentityReference -notlike "*NT AUTHORITY*")}
        }
        else
        {
            $access = $acl.Access | Where-Object {($_.IdentityReference -match "$filter") -and ($_.ActiveDirectoryRights -match "GenericAll|Write|Create|Delete" -or $_.ActiveDirectoryRights -match "ExtendedRight")}
        }

        if ($access) {
            $formattedOutput = $object | Format-List DistinguishedName, @{Name="Owner";Expression={$Access.IdentityReference}}, @{Name="Permissions";Expression={$access.ActiveDirectoryRights}} | Out-String
            $formattedOutput | addContent

        }
    }
}

    # Get all the groups that the user is a member of, including nested groups
    function Get-ADPrincipalGroupMembershipRecursive ($SamAccountName) {
	    $groups = @(Get-ADPrincipalGroupMembership -Identity $SamAccountName | select -expandproperty distinguishedname)
        $Name = ($groups -split ',')[0]
        $GroupName = $Name -replace "CN=", ""

        if ($GroupName) 
        {
            $GroupName
        }
	    if ($groups.count -gt 0)
	    {
		    foreach ($group in $groups)
		    {
			    Get-ADPrincipalGroupMembershipRecursive $group
		    }
	    }
    }

    # Wrapper function to build the filter
    function groupWrapper ($SamAccountName) 
    {
        $input = Get-ADPrincipalGroupMembershipRecursive ($SamAccountName)
        $input+= $SamAccountName
        $Output = $input -join "|"
        $Output
    }

    # get the filter for AD objects with SID greather than 1000
    function getFilterGT1000 ()
    {
        $SID = (Get-ADDomain).DomainSID
        $final = "$SID" + "-1000"
        $input = (Get-ADObject -Filter {objectsid -gt $final}).Name
        $output = $input -join "|"
        $output
     
    }

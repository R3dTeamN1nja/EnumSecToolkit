# EnumSecToolkit
<img src="https://i.ibb.co/TMZx1dF/Screenshot-2023-05-01-110047.png" alt="Menu" border="0"></a>

## Overview

EnumSecToolkit is a PowerShell-based toolkit for enumerating various security aspects of Windows and Active Directory environments. This toolkit combines a set of scripts to gather information about domains, local systems, ACLs, and SQL servers, and aims to simplify the enumeration process.
## Usage

To run the EnumSecToolkit, navigate to the EnumSecToolkit folder and execute the `menu.ps1` script in PowerShell.

`.\menu.ps1`

The menu script will display a list of available scripts, their descriptions, and the option to load required modules. Users can choose an option by entering the corresponding number or character.

## Scripts

1. `EnumDomainLDAP.ps1` - Enumerates the domain using the LDAP protocol.
2. `EnumDomainWMI.ps1` - Enumerates the domain using the WMI protocol - **Work in Progress**
3. `EnumLocal.ps1` - Enumerate the local system.
4. `ACLFinder.ps1` - Searches and enumerates ACLs (Access Control Lists) for a specific user or all users.
5. `EnumSQL.ps1` - Enumerates SQL Server instances and gathers information.
6. `EnumLocalAdmin.ps1` - Enumerates local administrator access using various methods (WMI, DCOM, PSRemoting, RPC).

### Modules to load

7. `LoadADModule.ps1` - Loads the Active Directory PowerShell module.
8. `LoadSQLServer.ps1` - Loads the SQL Server PowerShell module.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any improvements, bug fixes, or suggestions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Authors: [Matan Bahar](https://www.linkedin.com/in/matan-bahar-66460a1b0/) and [Yehuda Smirnov](https://www.linkedin.com/in/yehuda-smirnov/)
- Version: 0.2 beta

## Proof of Concept


<div align="center">
  <a href="https://www.youtube.com/watch?v=-zt96xFgiKw">
    <img src="https://img.youtube.com/vi/-zt96xFgiKw/0.jpg" alt="IMAGE_DESCRIPTION">
  </a>
</div>

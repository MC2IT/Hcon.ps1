# HCON for PowerShell
Parse [HCON](https://four.htmx.org/docs/hcon-guide) (htmx Configuration Object Notation) in [PowerShell](https://learn.microsoft.com/en-us/powershell).
	
## Quick start
Install the latest version of **HCON for PowerShell**
with [PSResourceGet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.psresourceget) package manager:

```shell
Install-PSResource Mc2it.Hcon
```

For detailed instructions, see the [installation guide](Installation.md).

## Usage
This module provides the `ConvertFrom-Hcon` cmdlet, which allows you to convert a [HCON-formatted string](https://four.htmx.org/docs/hcon-guide) to a hash table:

```powershell
# Using a HCON-formatted string...
$hcon = "FirstName:Cédric LastName:Belin Company:MC2IT IsDeveloper"
$hcon | ConvertFrom-Hcon | Write-Output

# Using a JSON-formatted string...
$json = '{"FirstName": "Cédric", "LastName": "Belin", "Company": "MC2IT", "IsDeveloper": true}'
$json | ConvertFrom-Hcon | Write-Output
```

<#
.SYNOPSIS
	Converts the specified HCON-formatted string to a hash table.
#>
using module Mc2it.Hcon

# Using a HCON-formatted string...
$hcon = "FirstName:Cédric LastName:Belin Company:MC2IT IsDeveloper"
$hcon | ConvertFrom-Hcon | Write-Output

# Using a JSON-formatted string...
$json = '{"FirstName": "Cédric", "LastName": "Belin", "Company": "MC2IT", "IsDeveloper": true}'
$json | ConvertFrom-Hcon | Write-Output

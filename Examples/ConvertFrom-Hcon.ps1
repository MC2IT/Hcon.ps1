<#
.SYNOPSIS
	Converts the specified HCON-formatted string to a hash table.
#>
using module Mc2it.Hcon

$hcon = "innerHTML swap:200ms settle:100ms"
$hashtable = $hcon | ConvertFrom-Hcon
Write-Output $hashtable

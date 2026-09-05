<#
.SYNOPSIS
	Converts a HCON-formatted string to a custom object or hash table.
.INPUTS
	The HCON string to convert to a custom object or hash table.
.OUTPUTS
	The custom object or hash table corresponding to the specified HCON string.
#>
function ConvertFrom-Hcon {
	[CmdletBinding()]
	[OutputType([hashtable])]
	[OutputType([psobject])]
	param (
		# The HCON string to convert to a custom object or hash table.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $InputObject,

		# Value indicating whether to convert the HCON to a hash table.
		[switch] $AsHashtable
	)

	process {
		# TODO
	}
}

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

<#
.SYNOPSIS
	Deep-merges a source (HCON string or hash table) into a target.
.OUTPUTS
	The target.
#>
function Merge-Hcon {
	param (
		# TODO
		[object] $Source,

		# TODO
		[object] $Target
	)

	# TODO
}

<#
.SYNOPSIS
	Splits an HCON-aware string at top-level commas.
	Commas inside `[]`, `()`, `<.../>`, `"..."`, `'...'` are preserved.
.INPUTS
	The HCON string to split.
.OUTPUTS
	TODO
#>
function Split-Hcon {
	param (
		# The HCON string to split.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $InputObject
	)

	process {
		$InputObject -split ",(?![^\[]*\])(?![^(]*\))(?![^<]*\/>)(?=(?:[^""']|""[^""]*""|'[^']*')*$)"
	}
}

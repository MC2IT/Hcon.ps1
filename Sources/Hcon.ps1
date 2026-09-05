using namespace System.Diagnostics.CodeAnalysis
using namespace System.Text.RegularExpressions

<#
.SYNOPSIS
	Converts a HCON-formatted string to a hash table.
.INPUTS
	The HCON-formatted string to convert.
.OUTPUTS
	The hash table corresponding to the specified HCON-formatted string.
#>
function ConvertFrom-Hcon {
	[CmdletBinding()]
	[OutputType([hashtable])]
	[SuppressMessage("PSAvoidUsingEmptyCatchBlock", "")]
	param (
		# The HCON-formatted string to convert.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $InputObject
	)

	begin {
		$getGroupValue = { param ([Match] $match, [int] $index) $value = $match.Groups[$index]?.Value; $value ? $value : $null }
		$hconPattern = "(?:""([^""]+)""|'([^']+)'|([^\s,:]+))(?:\s*:\s*(?:""([^""]*)""|'([^']*)'|<((?:[^/]|\/(?!>))+)\/>|([^\s,]+)))?(?=\s|,|$)"
	}

	process {
		$hcon = $InputObject.Trim()
		if (-not $hcon) { return @{} }
		if ($hcon -like "{*") { return ConvertFrom-Json $hcon -AsHashtable -Depth 10 }

		$result = @{}
		foreach ($match in [regex]::Matches($hcon, $hconPattern)) {
			$doubleQuotedKey = & $getGroupValue $match 1 # "key"
			$singleQuotedKey = & $getGroupValue $match 2 # 'key'
			$bareKey = & $getGroupValue $match 3 # key
			$doubleQuotedValue = & $getGroupValue $match 4 # "value"
			$singleQuotedValue = & $getGroupValue $match 5 # 'value'
			$hyperscriptValue = & $getGroupValue $match 6 # <value/>
			$bareValue = & $getGroupValue $match 7 # value

			$key = $doubleQuotedKey ?? $singleQuotedKey ?? $bareKey
			$value = ($doubleQuotedValue ?? $singleQuotedValue ?? $hyperscriptValue ?? $bareValue ?? "true").Trim()
			try { $value = ConvertFrom-Json $value -AsHashtable -Depth 10 -ErrorAction Stop } catch {}

			if ($bareKey -notlike "*.*") { Merge-Hcon @{ $key = $value } $result }
			else {
				$pair = $value
				$segments = $key -split "\."
				for ($index = $segments.Count - 1; $index -ge 0; $index--) { $pair = @{ $segments[$index] = $pair } }
				Merge-Hcon $pair $result
			}
		}

		$result
	}
}

<#
.SYNOPSIS
	Deep-merges a source hash table into a target hash table.
.INPUTS
	The source hash table.
.OUTPUTS
	The target hash table.
#>
function Merge-Hcon {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The source hash table.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[hashtable] $Source,

		# The target hash table.
		[Parameter(Mandatory, Position = 2)]
		[hashtable] $Target
	)

	process {
		foreach ($key in $Source.Keys) {
			$value = $Source[$key]
			if (($value -is [hashtable]) -and ($Target[$key] -is [hashtable])) { Merge-Hcon $value $Target[$key] }
			else { $Target[$key] = $value }
		}
	}
}

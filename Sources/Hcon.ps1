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
		[string] $InputObject,

		# The maximum depth the HCON input is allowed to have.
		[ValidateRange("Positive")]
		[int] $Depth = 1024
	)

	begin {
		$hconPattern = "(?:""([^""]+)""|'([^']+)'|([^\s,:]+))(?:\s*:\s*(?:""([^""]*)""|'([^']*)'|<((?:[^/]|\/(?!>))+)\/>|([^\s,]+)))?(?=\s|,|$)"
		$getGroup = { param ([Match] $match, [int] $index)
			$value = $match.Groups[$index].Value
			$value.Length ? $value : $null
		}
	}

	process {
		$hcon = $InputObject.Trim()
		if (-not $hcon) { return @{} }
		if ($hcon -like "{*") { return ConvertFrom-Json $hcon -AsHashtable -Depth $Depth }

		$result = @{}
		foreach ($match in [regex]::Matches($hcon, $hconPattern)) {
			$doubleQuotedKey = & $getGroup $match 1 # "key"
			$singleQuotedKey = & $getGroup $match 2 # 'key'
			$bareKey = & $getGroup $match 3 # key
			$doubleQuotedValue = & $getGroup $match 4 # "value"
			$singleQuotedValue = & $getGroup $match 5 # 'value'
			$hyperscriptValue = & $getGroup $match 6 # <value/>
			$bareValue = & $getGroup $match 7 # value

			$key = $doubleQuotedKey ?? $singleQuotedKey ?? $bareKey
			$value = ($doubleQuotedValue ?? $singleQuotedValue ?? $hyperscriptValue ?? $bareValue ?? "true").Trim()
			try { $value = ConvertFrom-Json $value -AsHashtable -Depth $Depth -ErrorAction Stop } catch {}

			if ($bareKey -notlike "*.*") { Merge-Hashtable @{ $key = $value } $result }
			else {
				$pair = $value
				$segments = $key -split "\."
				for ($index = $segments.Count - 1; $index -ge 0; $index--) { $pair = @{ $segments[$index] = $pair } }
				Merge-Hashtable $pair $result
			}
		}

		return $result
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
function Merge-Hashtable {
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
			if (($value -is [hashtable]) -and ($Target[$key] -is [hashtable])) { Merge-Hashtable $value $Target[$key] }
			else { $Target[$key] = $value }
		}
	}
}

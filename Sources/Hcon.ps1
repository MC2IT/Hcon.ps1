using namespace System.Diagnostics.CodeAnalysis
using namespace System.Management.Automation
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
	[OutputType([System.Management.Automation.OrderedHashtable])]
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
		# The pattern used to tokenize HCON-formatted strings.
		$hconPattern = "(?:""([^""]+)""|'([^']+)'|([^\s,:]+))(?:\s*:\s*(?:""([^""]*)""|'([^']*)'|<((?:[^/]|\/(?!>))+)\/>|([^\s,]+)))?(?=\s|,|$)"

		# Gets the value of the capturing group with the specified index in a given regular expression match.
		$getMatchGroup = { param ([Match] $match, [int] $index)
			$value = $match.Groups[$index].Value
			$value.Length ? $value : $null
		}
	}

	process {
		$hcon = $InputObject.Trim()
		if (-not $hcon) { return [OrderedHashtable]::new() }
		if ($hcon -like "{*") { return ConvertFrom-Json $hcon -AsHashtable -Depth $Depth }

		$target = [OrderedHashtable]::new()
		foreach ($match in [regex]::Matches($hcon, $hconPattern)) {
			$doubleQuotedKey = & $getMatchGroup $match 1 # "key"
			$singleQuotedKey = & $getMatchGroup $match 2 # 'key'
			$bareKey = & $getMatchGroup $match 3 # key
			$doubleQuotedValue = & $getMatchGroup $match 4 # "value"
			$singleQuotedValue = & $getMatchGroup $match 5 # 'value'
			$hyperscriptValue = & $getMatchGroup $match 6 # <value/>
			$bareValue = & $getMatchGroup $match 7 # value

			$key = $doubleQuotedKey ?? $singleQuotedKey ?? $bareKey
			$value = ($doubleQuotedValue ?? $singleQuotedValue ?? $hyperscriptValue ?? $bareValue ?? "true").Trim()
			try { $value = ConvertFrom-Json $value -AsHashtable -Depth $Depth -ErrorAction Stop } catch {}

			if ($bareKey -notlike "*.*") {
				$hashtable = [OrderedHashtable]::new()
				$hashtable[$key] = $value
				Merge-HconHashtable $hashtable $target
			}
			else {
				$source = $value
				$segments = $key -split "\."
				foreach ($index in ($segments.Count - 1)..0) {
					$hashtable = [OrderedHashtable]::new()
					$hashtable[$segments[$index]] = $source
					$source = $hashtable
				}

				Merge-HconHashtable $source $target
			}
		}

		return $target
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
function Merge-HconHashtable {
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
			if (($value -is [hashtable]) -and ($Target[$key] -is [hashtable])) { Merge-HconHashtable $value $Target[$key] }
			else { $Target[$key] = $value }
		}
	}
}

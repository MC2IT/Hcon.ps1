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
		[regex]::Matches($hcon, $hconPattern) | ForEach-Object {
			$doubleQuotedKey = & $getMatchGroup $_ 1 # "key"
			$singleQuotedKey = & $getMatchGroup $_ 2 # 'key'
			$bareKey = & $getMatchGroup $_ 3 # key
			$doubleQuotedValue = & $getMatchGroup $_ 4 # "value"
			$singleQuotedValue = & $getMatchGroup $_ 5 # 'value'
			$hyperscriptValue = & $getMatchGroup $_ 6 # <value/>
			$bareValue = & $getMatchGroup $_ 7 # value

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
				($segments.Count - 1)..0 | ForEach-Object {
					$hashtable = [OrderedHashtable]::new()
					$hashtable[$segments[$_]] = $source
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
		$Source.Keys | ForEach-Object {
			$value = $Source[$_]
			if (($value -is [hashtable]) -and ($Target[$_] -is [hashtable])) { Merge-HconHashtable $value $Target[$_] }
			else { $Target[$_] = $value }
		}
	}
}

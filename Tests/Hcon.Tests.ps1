using module ../Hcon.psd1

<#
.SYNOPSIS
	Tests the features of the `ConvertFrom-Hcon` cmdlet.
#>
Describe "ConvertFrom-Hcon" {
	It "should return a hash table representing the parsed HCON-formatted string" -ForEach @(
		@{ Hcon = " "; Expected = @{} }
		@{ Hcon = '{"foo": 1}'; Expected = @{ foo = 1 } }
		@{ Hcon = "foo:1 bar:true"; Expected = @{ foo = 1; bar = $true } }
		@{ Hcon = "sse.mode:once"; Expected = @{ sse = @{ mode = "once" } } }
		@{ Hcon = "innerHTML, swap:200ms, settle:100ms"; Expected = @{ innerHTML = $true; swap = "200ms"; settle = "100ms" } }
		@{ Hcon = "click delay:500ms throttle:1s"; Expected = @{ click = $true; delay = "500ms"; throttle = "1s" } }
		@{ Hcon = 'credentials:"include", timeout:5000'; Expected = @{ credentials = "include"; timeout = 5000 } }
		@{ Hcon = "token:'abc' retry:3"; Expected = @{ token = "abc"; retry = 3 } }
	) {
		Should-BeEquivalent $expected (ConvertFrom-Hcon $hcon)
	}
}

<#
.SYNOPSIS
	Tests the features of the `Merge-Hcon` cmdlet.
#>
Describe "Merge-Hcon" {
	BeforeAll { . "$PSScriptRoot/../Sources/Hcon.ps1" }

	It "TODO" {
		# TODO
	}
}

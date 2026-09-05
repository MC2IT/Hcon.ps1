using module ../Hcon.psd1

<#
.SYNOPSIS
	Tests the features of the `ConvertFrom-Hcon` cmdlet.
#>
Describe "ConvertFrom-Hcon" {
	# TODO
}

<#
.SYNOPSIS
	Tests the features of the `Merge-Hcon` cmdlet.
#>
Describe "Merge-Hcon" {
	BeforeAll { . "$PSScriptRoot/../Sources/Hcon.ps1" }

	# TODO
}

<#
.SYNOPSIS
	Tests the features of the `Split-Hcon` cmdlet.
#>
Describe "Split-Hcon" {
	BeforeAll { . "$PSScriptRoot/../Sources/Hcon.ps1" }

	# TODO
	It "TODO" -ForEach @(
		@{ Hcon = "a:1, b:2"; Expected = "a:1", " b:2" }
		@{ Hcon = "from:'.a, .b', click"; Expected = "from:'.a, .b'", " click" }
	) {
		Should-BeCollection $expected (Split-Hcon $hcon)
	}
}

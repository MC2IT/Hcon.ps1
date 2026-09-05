@{
	ModuleVersion = "1.0.0"
	PowerShellVersion = "7.6"
	RootModule = "Sources/Main.psm1"

	Author = "MC2IT <dev@mc2it.com>"
	CompanyName = "MC2IT"
	Copyright = "© MC2IT"
	Description = "Parse HCON (htmx Configuration Object Notation) in PowerShell."
	GUID = "45b55757-d920-4ffd-b6c0-0783a692b10b"

	AliasesToExport = @()
	CmdletsToExport = @()
	FunctionsToExport = , "ConvertFrom-Hcon"
	VariablesToExport = @()

	PrivateData = @{
		PSData = @{
			LicenseUri = "https://github.com/MC2IT/Hcon.ps1/blob/main/License.md"
			ProjectUri = "https://github.com/MC2IT/Hcon.ps1"
			ReleaseNotes = "https://github.com/MC2IT/Hcon.ps1/releases"
			Tags = "configuration", "hcon", "htmx", "json", "parser"
		}
	}
}

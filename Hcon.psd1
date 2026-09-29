@{
	ModuleVersion = "1.0.0"
	PowerShellVersion = "7.6"
	RootModule = "Binaries/Mc2it.Hcon.dll"

	Author = "MC2IT <dev@mc2it.com>"
	CompanyName = "MC2IT"
	Copyright = "© MC2IT"
	Description = "Parse HCON (htmx Configuration Object Notation) in PowerShell."
	GUID = "45b55757-d920-4ffd-b6c0-0783a692b10b"

	AliasesToExport = @()
	CmdletsToExport = , "ConvertFrom-Hcon"
	FunctionsToExport = @()
	VariablesToExport = @()

	RequiredModules = @(
		@{ ModuleName = "Belin.FSharp"; ModuleVersion = "10.1.401" }
	)

	PrivateData = @{
		PSData = @{
			LicenseUri = "https://github.com/MC2IT/Hcon.ps1/blob/main/License.md"
			ProjectUri = "https://github.com/MC2IT/Hcon.ps1"
			ReleaseNotes = "https://github.com/MC2IT/Hcon.ps1/releases"
			Tags = "configuration", "hcon", "htmx", "json", "parser"
		}
	}
}

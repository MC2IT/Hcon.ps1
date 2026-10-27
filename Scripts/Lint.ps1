using module PSScriptAnalyzer
using module ./Tools.psm1

Write-Information "Performing the static analysis of source code..."
$PSScriptRoot, "Sources", "Tests" | Invoke-ScriptAnalyzer -Recurse
Test-ModuleManifest (Get-Manifest) | Out-Null

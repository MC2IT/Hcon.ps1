using module ./Tools.psm1
& "$PSScriptRoot/Default.ps1"

Write-Information "Publishing the package..."
$version = (Import-PowerShellDataFile Hcon.psd1).ModuleVersion
New-GitTag "v$version"
Publish-PSGalleryModule

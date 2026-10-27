using module ./Tools.psm1
& "$PSScriptRoot/Default.ps1"

Write-Information "Tagging the repository..."
$version = Get-Version
git tag "v$version"
git push origin "v$version"

Write-Information "Publishing the package..."
$manifest = Get-Manifest

$output = "Temp/PSModule"
New-Item $output -ItemType Directory | Out-Null
Copy-Item *.md $output
Copy-Item $manifest $output/Mc2it.$($manifest.Name)
Copy-Item Sources $output -Recurse

$output = "Temp/PSGallery"
New-Item $output -ItemType Directory | Out-Null
Compress-PSResource Temp/PSModule $output

$apiKey = $Env:PSGALLERY_API_KEY
Get-ChildItem $output -File -Filter *.nupkg
| ForEach-Object { Publish-PSResource -ApiKey $apiKey -NupkgPath $_ -Repository PSGallery }

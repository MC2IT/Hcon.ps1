#!/usr/bin/env pwsh
param (
	# The name of the cmdlet to run.
	[Parameter(Mandatory, Position = 1)]
	[ArgumentCompleter({
		param ([string] $commandName, [string] $parameterName, [string] $wordToComplete)
		$module = Import-PowerShellDataFile "$PSScriptRoot/Hcon.psd1"
		$cmdlets = $module.CmdletsToExport + $module.FunctionsToExport
		$cmdlets -like "$wordToComplete*"
	})]
	[ValidateScript({
		$module = Import-PowerShellDataFile "$PSScriptRoot/Hcon.psd1"
		$cmdlets = $module.CmdletsToExport + $module.FunctionsToExport
		$cmdlets -contains $_
	}, ErrorMessage = "The specified command does not exist.")]
	[string] $Command,

	# The parameters of the cmdlet to run.
	[Parameter(Position = 2, ValueFromRemainingArguments)]
	[string[]] $Parameters = @()
)

$scriptBlock = {
	param ([string] $scriptRoot, [string] $command, [string[]] $parameters)
	$ErrorActionPreference = "Stop"
	$PSNativeCommandUseErrorActionPreference = $true

	Import-Module "$scriptRoot/Hcon.psd1"
	$argumentList = $parameters | ForEach-Object { $_ -like "* *" ? "'$_'" : $_ }
	Invoke-Expression "$command $($argumentList -join " ")"
}

pwsh -Command $scriptBlock -args $PSScriptRoot, $Command, $Parameters

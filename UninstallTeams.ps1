<#PSScriptInfo

.VERSION 0.0.6

.GUID 75abbb52-e359-4945-81f6-3fdb711239a9

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Microsoft Teams remove uninstall delete erase

.PROJECTURI https://github.com/asheroto/UninstallTeams

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Fixed typo and confirmed directory existance before removal.
[Version 0.0.3] - Added support for Uninstall registry key.
[Version 0.0.4] - Added to GitHub.
[Version 0.0.5] - Fixed signature.
[Version 0.0.6] - Fixed various bugs.

#>

<#
.SYNOPSIS
    Uninstalls Microsoft Teams and removes the Teams directory for a user. Usage: UninstallTeams
.DESCRIPTION
    Uninstalls Microsoft Teams and removes the Teams directory for a user. Usage: UninstallTeams
.EXAMPLE
    UninstallTeams.ps1
.NOTES
    Version      : 0.0.6
    Created by   : asheroto
.LINK
    Project Site: https://github.com/asheroto/UninstallTeams
#>

#Requires -RunAsAdministrator

function getUninstallString($match) {
	return (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -like "*$match*" }).UninstallString
}

$TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update.exe')

try {
	Write-Output "Stopping Teams process..."
	Stop-Process -Name "*teams*" -Force -ErrorAction SilentlyContinue

	Write-Output "Uninstalling Teams process"
	if ([System.IO.File]::Exists($TeamsUpdateExePath)) {
		# Uninstall app
		$proc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru
		$proc.WaitForExit()
	}

	Write-Output "Deleting Teams directory"
	if ([System.IO.Directory]::Exists($TeamsPath)) {
		Remove-Item $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
	}

	Write-Output "Deleting Teams uninstall registry key"
	# Uninstall from Uninstall registry key UninstallString
	$us = getUninstallString("Teams");
	if ($us.Length -gt 0) {
		$us = ($us.Replace("/I", "/uninstall ") + " /quiet").Replace("  ", " ")
		$FilePath = ($us.Substring(0, $us.IndexOf(".exe") + 4).Trim())
		$ProcessArgs = ($us.Substring($us.IndexOf(".exe") + 5).Trim().replace("  ", " "))
		$proc = Start-Process -FilePath $FilePath -Args $ProcessArgs -PassThru
		$proc.WaitForExit()
	}

	Write-Output "Restart computer to complete uninstall"
} catch {
	Write-Output "Uninstall failed with exception $_.exception.message"
	exit 1
}

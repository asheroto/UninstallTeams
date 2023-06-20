<#PSScriptInfo
.VERSION 1.0.3
.GUID 75abbb52-e359-4945-81f6-3fdb711239a9
.AUTHOR asherto
.COMPANYNAME asheroto
.TAGS PowerShell, Microsoft Teams, remove, uninstall, delete, erase
.PROJECTURI https://github.com/asheroto/UninstallTeams
.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Fixed typo and confirmed directory existence before removal.
[Version 0.0.3] - Added support for Uninstall registry key.
[Version 0.0.4] - Added to GitHub.
[Version 0.0.5] - Fixed signature.
[Version 0.0.6] - Fixed various bugs.
[Version 0.0.7] - Added removal AppxPackage.
[Version 0.0.8] - Added removal of startup entries.
[Version 1.0.0] - Added ability to optionally disable Chat widget (Win+C) which will reinstall Teams. Major refactor of code.
[Version 1.0.1] - Added URL to -CheckForUpdates function when script is out of date.
[Version 1.0.2] - Improve description.
[Version 1.0.3] - Fixed bug with -Version.
#>

<#
.SYNOPSIS
Uninstalls Microsoft Teams and removes the Teams directory for a user.

.DESCRIPTION
Uninstalls Microsoft Teams and removes the Teams directory for a user.

The script stops the Teams process, uninstalls Teams from the AppData directory, removes the Teams AppxPackage, deletes the Teams directory, uninstalls Teams from the Uninstall registry key, and removes Teams from the startup registry key.

You can also adjust the status of the Chat widget (Win+C) by enabling, disabling, or unsetting (default / effectively enabling).

.PARAMETER DisableChatWidget
Disables the Chat widget (Win+C) for Microsoft Teams.

.PARAMETER EnableChatWidget
Enables the Chat widget (Win+C) for Microsoft Teams.

.PARAMETER UnsetChatWidget
Removes the Chat widget key, effectively enabling it since that is the default.

.PARAMETER AllUsers
Applies the Chat widget setting to all user profiles on the machine.

.EXAMPLE
UninstallTeams.ps1 -DisableChatWidget
Disables the Chat widget (Win+C) for Microsoft Teams.

.EXAMPLE
UninstallTeams.ps1 -EnableChatWidget
Enables the Chat widget (Win+C) for Microsoft Teams.

.EXAMPLE
UninstallTeams.ps1 -UnsetChatWidget
Removes the Chat widget key, effectively enabling it since that is the default.

.EXAMPLE
UninstallTeams.ps1 -DisableChatWidget -AllUsers
Disables the Chat widget (Win+C) for Microsoft Teams for all user profiles on the machine.

.EXAMPLE
UninstallTeams.ps1 -EnableChatWidget -AllUsers
Enables the Chat widget (Win+C) for Microsoft Teams for all user profiles on the machine.

.EXAMPLE
UninstallTeams.ps1 -UnsetChatWidget -AllUsers
Removes the Chat widget key, effectively enabling it since that is the default, for all user profiles on the machine.

.NOTES
Version  : 1.0.3
Created by   : asheroto

.LINK
Project Site: https://github.com/asheroto/UninstallTeams

#>

#Requires -RunAsAdministrator

param (
	[switch]$EnableChatWidget,
	[switch]$DisableChatWidget,
	[switch]$UnsetChatWidget,
	[switch]$AllUsers,
	[switch]$Version,
	[switch]$Help,
	[switch]$CheckForUpdates
)

# Version
$CurrentVersion = '1.0.3'

# Check if -Version is specified
if ($Version.IsPresent) {
	$CurrentVersion
	exit 0
}

function Get-ChatWidgetStatus {
	param (
		[switch]$AllUsers
	)

	if ($AllUsers) {
		$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
	} else {
		$RegistryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
	}

	if (Test-Path $RegistryPath) {
		$ChatIconValue = (Get-ItemProperty -Path $RegistryPath -Name "ChatIcon" -ErrorAction SilentlyContinue).ChatIcon
		if ($ChatIconValue -eq $null) {
			return "Not Set"
		} elseif ($ChatIconValue -eq 1) {
			return "Enabled"
		} elseif ($ChatIconValue -eq 2) {
			return "Hidden"
		} elseif ($ChatIconValue -eq 3) {
			return "Disabled"
		}
	}

	return "Not Set"
}

function Set-ChatWidgetStatus {
	param (
		[switch]$EnableChatWidget,
		[switch]$DisableChatWidget,
		[switch]$UnsetChatWidget,
		[switch]$AllUsers
	)

	if ($AllUsers) {
		$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
	} else {
		$RegistryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
	}

	if ($EnableChatWidget) {
		$WhatChanged = "enabled"
		if (Test-Path $RegistryPath) {
			Set-ItemProperty -Path $RegistryPath -Name "ChatIcon" -Value 1 -Type DWord -Force
		} else {
			New-Item -Path $RegistryPath | Out-Null
			Set-ItemProperty -Path $RegistryPath -Name "ChatIcon" -Value 1 -Type DWord -Force
		}
	} elseif ($DisableChatWidget) {
		$WhatChanged = "disabled"
		if (Test-Path $RegistryPath) {
			Set-ItemProperty -Path $RegistryPath -Name "ChatIcon" -Value 3 -Type DWord -Force
		} else {
			New-Item -Path $RegistryPath | Out-Null
			Set-ItemProperty -Path $RegistryPath -Name "ChatIcon" -Value 3 -Type DWord -Force
		}
	} elseif ($UnsetChatWidget) {
		$WhatChanged = "unset"
		if (Test-Path $RegistryPath) {
			Remove-ItemProperty -Path $RegistryPath -Name "ChatIcon" -ErrorAction SilentlyContinue
		}
	}

	if ($AllUsers) {
		$AllUsersString = "all users"
	} else {
		$AllUsersString = "the current user"
	}
	Write-Output "Chat widget has been $WhatChanged for $AllUsersString."
}

function Check-GitHubRelease {
	param (
		[string]$Owner,
		[string]$Repo
	)
	try {
		$url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
		$response = Invoke-RestMethod -Uri $url -ErrorAction Stop

		$latestVersion = $response.tag_name
		$publishedAt = $response.published_at

		[PSCustomObject]@{
			LatestVersion = $latestVersion
			PublishedAt   = $publishedAt
		}
	} catch {
		Write-Error "Unable to check for updates. Error: $_"
		exit 1
	}
}

# Help
if ($Help) {
	Get-Help -Name $MyInvocation.MyCommand.Source -Full
	exit 0
}

# Check for updates
if ($CheckForUpdates) {
	$Data = Check-GitHubRelease -Owner "asheroto" -Repo "UninstallTeams"
	$LatestVersion = $Data.LatestVersion
	$PublishedAt = $Data.PublishedAt

	if ($LatestVersion -gt $CurrentVersion) {
		Write-Output "A new version of UninstallTeams is available.`nCurrent version: $CurrentVersion. Latest version: $LatestVersion. Published at: $PublishedAt."
		Write-Output "You can download the latest version from https://github.com/asheroto/UninstallTeams/releases."
	} else {
		Write-Output "UninstallTeams is up to date.`nCurrent version: $CurrentVersion. Latest version: $LatestVersion. Published at: $PublishedAt."
	}
	exit 0
}

# Check if -EnableChatWidget or -DisableChatWidget or -UnsetChatWidget is specified
$IsEnableChatWidget = $EnableChatWidget -and (-not $DisableChatWidget) -and (-not $UnsetChatWidget)
$IsDisableChatWidget = $DisableChatWidget -and (-not $EnableChatWidget) -and (-not $UnsetChatWidget)
$IsUnsetChatWidget = $UnsetChatWidget -and (-not $EnableChatWidget) -and (-not $DisableChatWidget)

# Check if -AllUsers is specified without -EnableChatWidget or -DisableChatWidget or -UnsetChatWidget
if ($AllUsers -and (-not $IsEnableChatWidget) -and (-not $IsDisableChatWidget) -and (-not $IsUnsetChatWidget)) {
	Write-Error "The -AllUsers switch can only be used with -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget. UninstallTeams will always remove Teams for the local machine."
	exit 1
}

# Check if -EnableChatWidget and -DisableChatWidget and -UnsetChatWidget are used together
if (($IsEnableChatWidget -and $IsDisableChatWidget) -or ($IsEnableChatWidget -and $IsUnsetChatWidget) -or ($IsDisableChatWidget -and $IsUnsetChatWidget)) {
	Write-Warning "You cannot enable, disable, and unset the Chat widget at the same time. Please choose either -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget."
	exit 1
}

try {
	# Spacer
	Write-Output ""

	# Update note
	Write-Output "Uninstall Teams $CurrentVersion"
	Write-Output "To check for updates, run UninstallTeams -CheckForUpdates"

	# Spacer
	Write-Output ""

	if ($IsEnableChatWidget) {
		Set-ChatWidgetStatus -EnableChatWidget -AllUsers:$AllUsers
	} elseif ($IsDisableChatWidget) {
		Set-ChatWidgetStatus -DisableChatWidget -AllUsers:$AllUsers
	} elseif ($IsUnsetChatWidget) {
		Set-ChatWidgetStatus -UnsetChatWidget -AllUsers:$AllUsers
	} else {

		# Stopping Teams process
		Write-Output "Stopping Teams process..."
		Stop-Process -Name "*teams*" -Force -ErrorAction SilentlyContinue

		# Uninstall from AppData\Microsoft\Teams
		$TeamsUpdateExePath = Join-Path $env:APPDATA "Microsoft\Teams\Update.exe"
		Write-Output "Uninstalling Teams from AppData\Microsoft\Teams"
		if (Test-Path $TeamsUpdateExePath) {
			$proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
			$proc.WaitForExit()
		}

		# Remove via AppxPackage
		Write-Output "Removing Teams AppxPackage..."
		Get-AppxPackage "*Teams*" | Remove-AppxPackage -ErrorAction SilentlyContinue
		Get-AppxPackage "*Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

		# Delete Teams directory
		$TeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Teams"
		Write-Output "Deleting Teams directory"
		if (Test-Path $TeamsPath) {
			Remove-Item -Path $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
		}

		# Uninstall from Uninstall registry key UninstallString
		function GetUninstallString {
			param (
				[string]$Match
			)

			$key = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | Get-Item
			$subkeys = $key | Get-ChildItem | Where-Object { $_.GetValue("DisplayName") -match $Match }
			$subkeys | ForEach-Object { $_.GetValue("UninstallString") }
		}

		Write-Output "Deleting Teams uninstall registry key"
		$uninstallString = GetUninstallString -Match "Teams"
		if (-not [string]::IsNullOrWhiteSpace($uninstallString)) {
			$uninstallArgs = ($uninstallString.Replace("/I", "/uninstall ") + " /quiet").Replace("  ", " ")
			$proc = Start-Process -FilePath $uninstallArgs.Split(" ")[0] -ArgumentList $uninstallArgs.Split(" ")[1..$uninstallArgs.Length] -PassThru
			$proc.WaitForExit()
		}

		# Remove from startup registry key
		Write-Output "Deleting Teams startup registry key"
		Remove-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	}
} catch {
	Write-Error "An error occurred during the Teams uninstallation process: $_"
	exit 1
}

# Output the status of both the current user and the local machine
$CurrentUserStatus = Get-ChatWidgetStatus
$LocalMachineStatus = Get-ChatWidgetStatus -AllUsers

# Chat widget status
Write-Output ""
Write-Output "Chat widget status:"
Write-Output "Current User Status: $CurrentUserStatus"
Write-Output "Local Machine Status: $LocalMachineStatus"

# If either status is "Enabled" show a warning
if (($CurrentUserStatus -eq "Enabled") -or ($LocalMachineStatus -eq "Enabled")) {
	Write-Warning "Teams Chat widget is enabled. Teams could be reinstalled if the user clicks 'Continue' by using Win+C or by clicking the Chat icon in the taskbar (if enabled). Use the '-DisableChatWidget' or '-DisableChatWidget -AllUsers' switch to disable it. Use 'Get-Help UninstallTeams -Full' for more information."
}

# Spacer
Write-Output ""
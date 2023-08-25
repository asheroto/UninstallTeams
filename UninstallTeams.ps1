<#PSScriptInfo
.VERSION 1.1.0
.GUID 75abbb52-e359-4945-81f6-3fdb711239a9
.AUTHOR asherto
.COMPANYNAME asheroto
.TAGS PowerShell, Microsoft Teams, remove, uninstall, delete, erase, uninstaller, widget, chat, enable, disable, change
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
[Version 1.0.1] - Added URL to -CheckForUpdate function when script is out of date.
[Version 1.0.2] - Improve description.
[Version 1.0.3] - Fixed bug with -Version.
[Version 1.0.4] - Improved CheckForUpdate function by converting time to local time and switching to variables.
[Version 1.0.5] - Changed -CheckForUpdates to -CheckForUpdate.
[Version 1.1.0] - Various bug fixes. Added removal of Desktop and Start Menu shortcuts. Added method to prevent Office from installing Teams. Added folders and registry keys to detect.
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

.PARAMETER BlockTeamsInstall
Prevent Teams from installing again with Office.

.PARAMETER UnblockTeamsInstall
Unprevent Teams from installing again with Office.

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
Version  : 1.1.0
Created by   : asheroto

.LINK
Project Site: https://github.com/asheroto/UninstallTeams

#>

#Requires -RunAsAdministrator

param (
    [switch]$EnableChatWidget,
    [switch]$DisableChatWidget,
    [switch]$UnsetChatWidget,
    [switch]$EnableOfficeTeamsInstall,
    [switch]$DisableOfficeTeamsInstall,
    [switch]$UnsetOfficeTeamsInstall,
    [switch]$AllUsers,
    [switch]$Version,
    [switch]$Help,
    [switch]$CheckForUpdate
)

# Version
$CurrentVersion = '1.1.0'
$RepoOwner = 'asheroto'
$RepoName = 'UninstallTeams'

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
        if ($null -eq $ChatIconValue) {
            return "Unset (default is enabled)"
        } elseif ($ChatIconValue -eq 1) {
            return "Enabled"
        } elseif ($ChatIconValue -eq 2) {
            return "Hidden"
        } elseif ($ChatIconValue -eq 3) {
            return "Disabled"
        }
    }

    return "Unset (default is enabled)"
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

function Get-OfficeTeamsInstallStatus {
    # According to Microsoft, HKLM is the only key that matters for this (no HKCU)
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate"

    if (Test-Path $RegistryPath) {
        $OfficeTeamsInstallValue = (Get-ItemProperty -Path $RegistryPath).PreventTeamsInstall
        if ($null -eq $OfficeTeamsInstallValue) {
            return "Unset (default is enabled)"
        } elseif ($OfficeTeamsInstallValue -eq 0) {
            return "Enabled"
        } elseif ($OfficeTeamsInstallValue -eq 1) {
            return "Disabled"
        }
    }

    return "Unset (default is enabled)"
}

function Set-OfficeTeamsInstallStatus {
    param (
        [switch]$EnableOfficeTeamsInstall,
        [switch]$DisableOfficeTeamsInstall,
        [switch]$UnsetOfficeTeamsInstall
    )

    # According to Microsoft, HKLM is the only key that matters for this (no HKCU)
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate"

    if ($EnableOfficeTeamsInstall) {
        $WhatChanged = "enabled"
        if (Test-Path $RegistryPath) {
            Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 0 -Type DWord -Force
        } else {
            New-Item -Path $RegistryPath | Out-Null
            Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 0 -Type DWord -Force
        }
    } elseif ($DisableOfficeTeamsInstall) {
        $WhatChanged = "disabled"
        if (Test-Path $RegistryPath) {
            Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 1 -Type DWord -Force
        } else {
            New-Item -Path $RegistryPath | Out-Null
            Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 1 -Type DWord -Force
        }
    } elseif ($UnsetOfficeTeamsInstall) {
        $WhatChanged = "unset (default is enabled)"
        if (Test-Path $RegistryPath) {
            Remove-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -ErrorAction SilentlyContinue
        }
    }

    Write-Output "Office's ability to install Teams has been $WhatChanged."
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

# Uninstall from Uninstall registry key UninstallString
function Get-UninstallString {
    param (
        [string]$Match
    )

    try {
        $uninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
        $uninstallStrings = $uninstallKeys | Get-Item |
        Get-ChildItem | Where-Object { $_.GetValue("DisplayName") -like "*$Match*" } | ForEach-Object { $_.GetValue("UninstallString") }

        return $uninstallStrings
    } catch {
        # Silence errors within the function
    }
}

function Remove-Shortcut {
    param (
        [string]$ShortcutName,
        [string]$ShortcutPathName,
        [string]$UserPath,
        [string]$PublicPath
    )

    try {
        $userShortcutPath = Join-Path -Path $UserPath -ChildPath "$ShortcutName.lnk"
        $publicShortcutPath = Join-Path -Path $PublicPath -ChildPath "$ShortcutName.lnk"

        if (Test-Path -Path $userShortcutPath) {
            Write-Output "Deleting $ShortcutName from the user's $ShortcutPathName..."
            Remove-Item -Path $userShortcutPath
        }

        if (Test-Path -Path $publicShortcutPath) {
            Write-Output "Deleting $ShortcutName from the public $ShortcutPathName..."
            Remove-Item -Path $publicShortcutPath
        }
    } catch {
        Write-Output "An error occurred while attempting to delete the shortcut."
    }
}

function Remove-DesktopShortcuts {
    param (
        [string]$ShortcutName
    )

    $userDesktopPath = [Environment]::GetFolderPath("Desktop")
    $publicDesktopPath = "$env:PUBLIC\Desktop"

    Remove-Shortcut -ShortcutPathName "Desktop" -ShortcutName $ShortcutName -UserPath $userDesktopPath -PublicPath $publicDesktopPath
}

function Remove-StartMenuShortcuts {
    param (
        [string]$ShortcutName
    )

    $userStartMenuPath = [Environment]::GetFolderPath("StartMenu") + "\Programs"
    $publicStartMenuPath = "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs"

    Remove-Shortcut -ShortcutPathName "Start Menu" -ShortcutName $ShortcutName -UserPath $userStartMenuPath -PublicPath $publicStartMenuPath
}

# Help
if ($Help) {
    Get-Help -Name $MyInvocation.MyCommand.Source -Full
    exit 0
}

# Check for updates
if ($CheckForUpdate) {
    $Data = Check-GitHubRelease -Owner $RepoOwner -Repo $RepoName
    $LatestVersion = $Data.LatestVersion

    # Convert UTC time to local time
    $PublishedAt = [DateTime]::Parse($Data.PublishedAt)
    $UtcDateTimeFormat = "MM/dd/yyyy HH:mm:ss"

    # Convert UTC time string to local time
    $UtcDateTime = [DateTime]::ParseExact($PublishedAt, $UtcDateTimeFormat, $null)
    $PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

    if ($LatestVersion -gt $CurrentVersion) {
        Write-Output "A new version of $RepoName is available.`nCurrent version: $CurrentVersion. Latest version: $LatestVersion. Published at: $PublishedLocalDateTime."
        Write-Output "You can download the latest version from https://github.com/$RepoOwner/$RepoName/releases"
    } else {
        Write-Output "$RepoName is up to date.`nCurrent version: $CurrentVersion. Latest version: $LatestVersion. Published at: $PublishedLocalDateTime."
        Write-Output "Repository: https://github.com/$RepoOwner/$RepoName/releases"
    }
    exit 0
}

# Check if exactly one or none of -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget is specified
$chatWidgetCount = ($EnableChatWidget, $DisableChatWidget, $UnsetChatWidget).Where({ $_ }).Count

if ($chatWidgetCount -gt 1) {
    Write-Warning "Please choose only one of -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget."
    exit 1
}

# Check if -AllUsers is specified without one of -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget
if ($AllUsers -and $chatWidgetCount -eq 0) {
    Write-Error "The -AllUsers switch can only be used with -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget. UninstallTeams will always remove Teams for the local machine."
    exit 1
}

# Similar checks for -EnableOfficeTeamsInstall, -DisableOfficeTeamsInstall, or -UnsetOfficeTeamsInstall
$officeTeamsInstallCount = ($EnableOfficeTeamsInstall, $DisableOfficeTeamsInstall, $UnsetOfficeTeamsInstall).Where({ $_ }).Count

if ($officeTeamsInstallCount -gt 1) {
    Write-Warning "Please choose only one of -EnableOfficeTeamsInstall, -DisableOfficeTeamsInstall, or -UnsetOfficeTeamsInstall."
    exit 1
}

try {
    # Spacer
    Write-Output ""

    # Update note
    Write-Output "UninstallTeams $CurrentVersion"
    Write-Output "To check for updates, run UninstallTeams -CheckForUpdate"

    # Spacer
    Write-Output ""

    # Default
    $Uninstall = $true

    # Chat widget
    if ($EnableChatWidget) {
        Set-ChatWidgetStatus -EnableChatWidget -AllUsers:$AllUsers
        $Uninstall = $false
    } elseif ($DisableChatWidget) {
        Set-ChatWidgetStatus -DisableChatWidget -AllUsers:$AllUsers
        $Uninstall = $false
    } elseif ($UnsetChatWidget) {
        Set-ChatWidgetStatus -UnsetChatWidget -AllUsers:$AllUsers
        $Uninstall = $false
    }

    # Office Teams install
    if ($EnableOfficeTeamsInstall) {
        Set-OfficeTeamsInstallStatus -EnableOfficeTeamsInstall
        $Uninstall = $false
    } elseif ($DisableOfficeTeamsInstall) {
        Set-OfficeTeamsInstallStatus -DisableOfficeTeamsInstall
        $Uninstall = $false
    } elseif ($UnsetOfficeTeamsInstall) {
        Set-OfficeTeamsInstallStatus -UnsetOfficeTeamsInstall
        $Uninstall = $false
    }

    # Uninstall Teams
    if ($Uninstall -eq $true) {
        # Stopping Teams process
        Write-Output "Stopping Teams process..."
        Stop-Process -Name "*teams*" -Force -ErrorAction SilentlyContinue

        # Uninstall Teams through uninstall registry key
        Write-Output "Deleting Teams through uninstall registry key..."
        $uninstallString = Get-UninstallString -Match "Teams"
        if (-not [string]::IsNullOrWhiteSpace($uninstallString)) {
            $uninstallArgs = ($uninstallString.Replace("/I", "/uninstall ") + " /quiet").Replace("  ", " ")
            $filePath = $uninstallArgs.Split(" ")[0]
            $argList = $uninstallArgs.Split(" ")[1..$uninstallArgs.Length]
            if (Test-Path $filePath) {
                $proc = Start-Process -FilePath $filePath -ArgumentList $argList -PassThru
                $proc.WaitForExit()
            }
        }

        # Uninstall from AppData\Microsoft\Teams
        Write-Output "Checking Teams in AppData\Microsoft\Teams..."
        $TeamsUpdateExePath = Join-Path $env:APPDATA "Microsoft\Teams\Update.exe"
        if (Test-Path $TeamsUpdateExePath) {
            Write-Output "Uninstalling Teams from AppData\Microsoft\Teams..."
            $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
        }

        # Uninstall from TeamsInstaller
        Write-Output "Checking Teams in Program Files (x86)..."
        $TeamsPrgFiles = Join-Path ${env:ProgramFiles(x86)} "Teams Installer\Teams.exe"
        if (Test-Path $TeamsPrgFiles) {
            Write-Output "Uninstalling Teams from Program Files (x86)..."
            $proc = Start-Process -FilePath $TeamsPrgFiles -ArgumentList "--uninstall" -PassThru
            $proc.WaitForExit()
        }

        # Remove via AppxPackage
        Write-Output "Removing Teams AppxPackage..."
        Get-AppxPackage "*Teams*" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage "*Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

        # Delete Microsoft Teams directory
        $MicrosoftTeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft Teams"
        Write-Output "Deleting Microsoft Teams directory..."
        if (Test-Path $MicrosoftTeamsPath) {
            Remove-Item -Path $MicrosoftTeamsPath -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Delete Teams directory
        $TeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Teams"
        Write-Output "Deleting Teams directory..."
        if (Test-Path $TeamsPath) {
            Remove-Item -Path $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Remove from startup registry key
        Write-Output "Deleting Teams startup registry keys..."
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        # Removing desktop shortcuts
        Write-Output "Deleting Teams desktop shortcuts..."
        Remove-DesktopShortcuts -ShortcutName "Microsoft Teams"

        # Removing start menu shortcuts
        Write-Output "Deleting Teams start menu shortcuts..."
        Remove-StartMenuShortcuts -ShortcutName "Microsoft Teams"

        # Removing Teams meeting addin
        Write-Output "Deleting Teams meeting addin..."
        $teamsMeetingAddin = "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin"
        if (Test-Path $teamsMeetingAddin) {
            Remove-Item -Path $teamsMeetingAddin -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Removing Teams meeting addin
        Write-Output "Deleting Teams presence addin..."
        $teamsPresenceAddin = "$env:LOCALAPPDATA\Microsoft\TeamsPresenceAddin"
        if (Test-Path $teamsPresenceAddin) {
            Remove-Item -Path $teamsPresenceAddin -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
} catch {
    Write-Warning "An error occurred during the Teams uninstallation process: $_"
}

# Output the Chat widget status of both the current user and the local machine
$CurrentUserStatus = Get-ChatWidgetStatus
$LocalMachineStatus = Get-ChatWidgetStatus -AllUsers

# Chat widget status
Write-Output ""
Write-Output "----------------- Chat widget ----------------"
Write-Output "Current User Status: $CurrentUserStatus"
Write-Output "Local Machine Status: $LocalMachineStatus"
Write-Output "----------------------------------------------"

# If Chat widget status is "Enabled" show a warning
if (($CurrentUserStatus -eq "Enabled") -or ($LocalMachineStatus -eq "Enabled")) {
    Write-Warning "Teams Chat widget is enabled. Teams could be reinstalled if the user clicks 'Continue' by using Win+C or by clicking the Chat icon in the taskbar (if enabled). Use the '-DisableChatWidget' or '-DisableChatWidget -AllUsers' switch to disable it. Use 'Get-Help UninstallTeams -Full' for more information."
}

# Output the Office Teams install status
$OfficeTeamsInstallStatus = Get-OfficeTeamsInstallStatus

# Chat widget status
Write-Output ""
Write-Output "----- Office's ability to install Teams ------"
Write-Output "Status: $OfficeTeamsInstallStatus"
Write-Output "----------------------------------------------"

# If Office Team install status is Enabled or unset, show a warning
if (($OfficeTeamsInstallStatus -eq "Enabled") -or ($OfficeTeamsInstallStatus -eq "Unset (default is enabled)")) {
    Write-Warning "Office is allowing Teams to install. Teams could be reinstalled if Office is installed or updated.`nUse the '-DisableOfficeTeamsInstall' switch to prevent Teams from installing with Office. Use 'Get-Help UninstallTeams -Full' for more information."
}

# Office note
Write-Output "`nNote: If you just installed Microsoft Office, you may need to restart the computer once or`ntwice and then run UninstallTeams to prevent Teams from reinstalling."

# Spacer
Write-Output ""
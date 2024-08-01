<#PSScriptInfo
.VERSION 1.2.5
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
[Version 1.1.1] - Improved Chat widget warning detection. Improved output into section headers.
[Version 1.1.2] - Improved DisableOfficeTeamsInstall by adding registry key if it doesn't exist.
[Version 1.1.3] - Added TeamsMachineInstaller registry key for deletion.
[Version 1.1.4] - Added Teams uninstall registry key for deletion.
[Version 1.2.0] - Improved functionality of uninstall key removal by detecting MsiExec product GUID to uninstall teams. Added additional startup registry keys.
[Version 1.2.1] - Added additional file and registry uninstall locations.
[Version 1.2.2] - Improved detection of registry uninstall keys. Improved error handling.
[Version 1.2.3] - Fixed bug when uninstalling Teams from the uninstall registry key and using MsiExec.exe.
[Version 1.2.4] - Added AutorunsDisabled registry keys for deletion.
[Version 1.2.5] - Improved path handling for Desktop and Programs folder paths by using special folders.
#>

<#
.SYNOPSIS
Uninstalls Microsoft Teams completely. Optional parameters to disable the Chat widget (Win+C) and prevent Office from installing Teams.

.DESCRIPTION
Uninstalls Microsoft Teams completely. Optional parameters to disable the Chat widget (Win+C) and prevent Office from installing Teams.

The script stops the Teams process, uninstalls Teams using the uninstall key, uninstalls Teams from the Program Files (x86) directory, uninstalls Teams from the AppData directory, removes the Teams AppxPackage, deletes the Microsoft Teams directory in AppData, deletes the Teams directory in AppData, removes the startup registry keys for Teams, and removes the Desktop and Start Menu icons for Teams.

.PARAMETER DisableChatWidget
Disables the Chat widget (Win+C) for Microsoft Teams.

.PARAMETER EnableChatWidget
Enables the Chat widget (Win+C) for Microsoft Teams.

.PARAMETER UnsetChatWidget
Removes the Chat widget registry value, effectively enabling it since that is the default.

.PARAMETER AllUsers
Applies the Chat widget setting to all user profiles on the machine.

.PARAMETER DisableOfficeTeamsInstall
Disable Office's ability to install Teams.

.PARAMETER EnableOfficeTeamsInstall
Enable Office's ability to install Teams.

.PARAMETER UnsetOfficeTeamsInstall
Removes the Office Teams registry value, effectively enabling it since that is the default.

.EXAMPLE
UninstallTeams -DisableChatWidget
Disables the Chat widget (Win+C) for Microsoft Teams.

.EXAMPLE
UninstallTeams -EnableChatWidget
Enables the Chat widget (Win+C) for Microsoft Teams.

.EXAMPLE
UninstallTeams -UnsetChatWidget
Removes the Chat widget value, effectively enabling it since that is the default.

.EXAMPLE
UninstallTeams -DisableChatWidget -AllUsers
Disables the Chat widget (Win+C) for Microsoft Teams for all user profiles on the machine.

.EXAMPLE
UninstallTeams -EnableChatWidget -AllUsers
Enables the Chat widget (Win+C) for Microsoft Teams for all user profiles on the machine.

.EXAMPLE
UninstallTeams -UnsetChatWidget -AllUsers
Removes the Chat widget value, effectively enabling it since that is the default, for all user profiles on the machine.

.EXAMPLE
UninstallTeams -DisableOfficeTeamsInstall
Disable Office's ability to install Teams.

.EXAMPLE
UninstallTeams -EnableOfficeTeamsInstall
Enable Office's ability to install Teams.

.EXAMPLE
UninstallTeams -UnsetOfficeTeamsInstall
Removes the Office Teams registry value, effectively enabling it since that is the default.

.NOTES
Version  : 1.2.5
Created by   : asheroto

.LINK
Project Site: https://github.com/asheroto/UninstallTeams

#>

#Requires -RunAsAdministrator

[CmdletBinding()]
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
$CurrentVersion = '1.2.5'
$RepoOwner = 'asheroto'
$RepoName = 'UninstallTeams'
$PowerShellGalleryName = 'UninstallTeams'

# Versions
$ProgressPreference = 'SilentlyContinue' # Suppress progress bar (makes downloading super fast)
$ConfirmPreference = 'None' # Suppress confirmation prompts

# Display version if -Version is specified
if ($Version.IsPresent) {
    $CurrentVersion
    exit 0
}

# Display full help if -Help is specified
if ($Help) {
    Get-Help -Name $MyInvocation.MyCommand.Source -Full
    exit 0
}

# Display $PSVersionTable and Get-Host if -Verbose is specified
if ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) {
    $PSVersionTable
    Get-Host
}

function Get-GitHubRelease {
    <#
        .SYNOPSIS
        Fetches the latest release information of a GitHub repository.

        .DESCRIPTION
        This function uses the GitHub API to get information about the latest release of a specified repository, including its version and the date it was published.

        .PARAMETER Owner
        The GitHub username of the repository owner.

        .PARAMETER Repo
        The name of the repository.

        .EXAMPLE
        Get-GitHubRelease -Owner "asheroto" -Repo "winget-install"
        This command retrieves the latest release version and published datetime of the winget-install repository owned by asheroto.
    #>
    [CmdletBinding()]
    param (
        [string]$Owner,
        [string]$Repo
    )
    try {
        $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop

        $latestVersion = $response.tag_name
        $publishedAt = $response.published_at

        # Convert UTC time string to local time
        $UtcDateTime = [DateTime]::Parse($publishedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

        [PSCustomObject]@{
            LatestVersion     = $latestVersion
            PublishedDateTime = $PublishedLocalDateTime
        }
    } catch {
        Write-Error "Unable to check for updates.`nError: $_"
        exit 1
    }
}

function CheckForUpdate {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [version]$CurrentVersion,
        [string]$PowerShellGalleryName
    )

    $Data = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName

    if ($Data.LatestVersion -gt $CurrentVersion) {
        Write-Output "`nA new version of $RepoName is available.`n"
        Write-Output "Current version: $CurrentVersion."
        Write-Output "Latest version: $($Data.LatestVersion)."
        Write-Output "Published at: $($Data.PublishedDateTime).`n"
        Write-Output "You can download the latest version from https://github.com/$RepoOwner/$RepoName/releases`n"
        if ($PowerShellGalleryName) {
            Write-Output "Or you can run the following command to update:"
            Write-Output "Install-Script $PowerShellGalleryName -Force`n"
        }
    } else {
        Write-Output "`n$RepoName is up to date.`n"
        Write-Output "Current version: $CurrentVersion."
        Write-Output "Latest version: $($Data.LatestVersion)."
        Write-Output "Published at: $($Data.PublishedDateTime)."
        Write-Output "`nRepository: https://github.com/$RepoOwner/$RepoName/releases`n"
    }
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

    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate"

    if (-Not (Test-Path $RegistryPath)) {
        Write-Output "Creating registry path $RegistryPath."
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    if ($EnableOfficeTeamsInstall) {
        $WhatChanged = "enabled"
        Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 0 -Type DWord -Force
    } elseif ($DisableOfficeTeamsInstall) {
        $WhatChanged = "disabled"
        Set-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -Value 1 -Type DWord -Force
    } elseif ($UnsetOfficeTeamsInstall) {
        $WhatChanged = "unset (default is enabled)"
        Remove-ItemProperty -Path $RegistryPath -Name "PreventTeamsInstall" -ErrorAction SilentlyContinue
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

function Write-Section($text) {
    <#
        .SYNOPSIS
        Prints a text block surrounded by a section divider for enhanced output readability.

        .DESCRIPTION
        This function takes a string input and prints it to the console, surrounded by a section divider made of hash characters.
        It is designed to enhance the readability of console output.

        .PARAMETER text
        The text to be printed within the section divider.

        .EXAMPLE
        Write-Section "Downloading Files..."
        This command prints the text "Downloading Files..." surrounded by a section divider.
    #>
    Write-Output ""
    Write-Output ("#" * ($text.Length + 4))
    Write-Output "# $text #"
    Write-Output ("#" * ($text.Length + 4))
    Write-Output ""
}

# Get uninstall registry keys
function Get-UninstallRegistryKey {
    param (
        [string]$Match
    )

    $result = @()
    $uninstallKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($key in $uninstallKeys) {
        if (Test-Path $key) {
            Get-Item $key | Get-ChildItem | Where-Object {
                $_.GetValue("DisplayName") -like "*${Match}*"
            } | ForEach-Object {
                $result += $_.PSPath
            }
        }
    }

    return $result
}

# Get uninstall string from registry key
function Get-UninstallString {
    param (
        [string]$Match
    )

    $result = @()
    $registryKeys = Get-UninstallRegistryKey -Match $Match

    foreach ($regKey in $registryKeys) {
        try {
            $displayName = (Get-ItemProperty -Path $regKey).DisplayName
            $uninstallString = (Get-ItemProperty -Path $regKey).UninstallString

            if ($displayName -and $uninstallString) {
                $obj = [PSCustomObject]@{
                    DisplayName     = $displayName
                    UninstallString = $uninstallString
                }
                $result += $obj
            }
        } catch {

        }
    }

    return $result
}

function Remove-Shortcut {
    param (
        [string]$ShortcutName,
        [string]$ShortcutPathName,
        [string]$UserPath,
        [string]$PublicPath
    )

    try {
        $userShortcutPath = [System.IO.Path]::Combine($UserPath, "$ShortcutName.lnk")
        $publicShortcutPath = [System.IO.Path]::Combine($PublicPath, "$ShortcutName.lnk")

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

    $userDesktopPath = [System.Environment]::GetFolderPath('Desktop')
    $publicDesktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')

    Remove-Shortcut -ShortcutPathName "Desktop" -ShortcutName $ShortcutName -UserPath $userDesktopPath -PublicPath $publicDesktopPath
}

function Remove-StartMenuShortcuts {
    param (
        [string]$ShortcutName
    )

    $userStartMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), "Programs")
    $publicStartMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('CommonStartMenu'), "Programs")

    Remove-Shortcut -ShortcutPathName "Start Menu" -ShortcutName $ShortcutName -UserPath $userStartMenuPath -PublicPath $publicStartMenuPath
}

# ============================================================================ #
# Initial checks
# ============================================================================ #

# Check for updates if -CheckForUpdate is specified
if ($CheckForUpdate) {
    CheckForUpdate -RepoOwner $RepoOwner -RepoName $RepoName -CurrentVersion $CurrentVersion -PowerShellGalleryName $PowerShellGalleryName
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

    # Heading
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

        ###########################################################################
        # Start the process of uninstalling Teams
        Write-Output "Deleting Teams through uninstall registry key..."

        # Retrieve the uninstall information for Teams
        $uninstallInfo = Get-UninstallString -Match "Teams"

        foreach ($info in $uninstallInfo) {
            $uninstallString = $info.UninstallString

            if (-not [string]::IsNullOrWhiteSpace($uninstallString)) {
                Write-Debug "Found Teams uninstall string: $uninstallString"

                # Check if the uninstall string is an MSI command
                if ($uninstallString -match "msiexec.exe\s*/[XxIi]\{([^\}]+)\}") {
                    $productGUID = $matches[1]
                    Write-Debug "Found Teams product GUID: $productGUID"

                    # Construct the MSI uninstall command with the correct format for GUID
                    $filePath = "msiexec.exe"
                    $argList = "/x {${productGUID}} /qn"  # Correct format for GUID
                } else {
                    # For non-MSI packages, assume the uninstall string is a complete command
                    $filePath = $uninstallString.Split(" ")[0]
                    $argList = $uninstallString.Substring($filePath.Length).Trim()
                }

                # Execute the uninstall command
                if ($filePath -ieq "msiexec.exe" -or (Test-Path $filePath)) {
                    Write-Debug "Uninstalling Teams with command: $filePath $argList"
                    $proc = Start-Process -FilePath $filePath -ArgumentList $argList -PassThru
                    $proc.WaitForExit()
                } else {
                    Write-Warning "The path $filePath does not exist."
                }
            }
        }
        ###########################################################################

        # Uninstall from "Teams Installer"
        $TeamsPrgFiles = Join-Path ${env:ProgramFiles(x86)} "Teams Installer\Teams.exe"
        Write-Output "Checking Teams in `"$TeamsPrgFiles`..."
        if (Test-Path $TeamsPrgFiles) {
            Write-Output "Uninstalling Teams from `"$TeamsPrgFiles`..."
            $proc = Start-Process -FilePath $TeamsPrgFiles -ArgumentList "--uninstall" -PassThru
            $proc.WaitForExit()
        }

        # Uninstall from AppData\Microsoft\Teams
        $TeamsUpdateExePath = Join-Path $env:APPDATA "Microsoft\Teams\Update.exe"
        Write-Output "Checking Teams in `"$TeamsUpdateExePath`"..."
        if (Test-Path $TeamsUpdateExePath) {
            Write-Output "Uninstalling Teams from `"$TeamsUpdateExePath`"..."
            $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
        }

        # Uninstall from Program Files (x86)\Microsoft\Teams\current
        $TeamsUpdateExePathPrgX86 = Join-Path ${env:ProgramFiles(x86)} "Microsoft\Teams\current\Update.exe"
        Write-Output "Checking Teams in `"$TeamsUpdateExePathPrgX86`"..."
        if (Test-Path $TeamsUpdateExePathPrgX86) {
            Write-Output "Uninstalling Teams from `"$TeamsUpdateExePathPrgX86`"..."
            $proc = Start-Process -FilePath $TeamsUpdateExePathPrgX86 -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
        }

        # Remove via AppxPackage
        Write-Output "Removing Teams AppxPackage..."
        Get-AppxPackage "*Teams*" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage "*Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

        # Delete Microsoft Teams directory
        $MicrosoftTeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft Teams"
        Write-Output "Deleting `"$MicrosoftTeamsPath`"..."
        if (Test-Path $MicrosoftTeamsPath) {
            Remove-Item -Path $MicrosoftTeamsPath -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Delete Teams directory
        $TeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Teams"
        Write-Output "Deleting `"$TeamsPath`"..."
        if (Test-Path $TeamsPath) {
            Remove-Item -Path $TeamsPath -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Remove from startup registry key
        Write-Output "Deleting Teams startup registry keys..."
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        # Remove from AutorunsDisabled registry key
        Write-Output "Deleting Teams startup registry keys from AutorunsDisabled..."
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Remove-ItemProperty -Path 'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller' -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        # Remove Teams uninstall registry keys
        Write-Output "Deleting Teams uninstall registry keys..."
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams" -Force -Recurse -ErrorAction SilentlyContinue

        # Removing desktop shortcuts
        Write-Output "Deleting Teams desktop shortcuts..."
        Remove-DesktopShortcuts -ShortcutName "Microsoft Teams"

        # Removing start menu shortcuts
        Write-Output "Deleting Teams start menu shortcuts..."
        Remove-StartMenuShortcuts -ShortcutName "Microsoft Teams"
        Remove-StartMenuShortcuts -ShortcutName "Microsoft Teams classic (work or school)"

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

# Let user know nothing will change
if ($Uninstall -eq $true) {
    Write-Output ""
    Write-Output "Teams has been uninstalled, please restart your computer."
    Write-Output ""
    Write-Output "The information below is only information, the settings below will not change unless you use parameters to change them."
}

# Output the Chat widget status of both the current user and the local machine
$CurrentUserStatus = Get-ChatWidgetStatus
$LocalMachineStatus = Get-ChatWidgetStatus -AllUsers

# Determine the effective status
if ($CurrentUserStatus -ne "Unset (default is enabled)") {
    $effectiveStatus = $CurrentUserStatus
} elseif ($LocalMachineStatus -ne "Unset (default is enabled)") {
    $effectiveStatus = $LocalMachineStatus
} else {
    $effectiveStatus = "Enabled by default"
    Write-Output "Both Current User and Local Machine statuses are Unset (default is enabled). Enabled by default."
}

Write-Section("Chat widget")
Write-Output "Current User Status: $CurrentUserStatus"
Write-Output "Local Machine Status: $LocalMachineStatus"
Write-Output "Effective Status: $effectiveStatus"
Write-Output ""

# If Chat widget status is "Enabled" or "Enabled by default", show a warning
if ($effectiveStatus -eq "Enabled" -or $effectiveStatus -eq "Enabled by default") {
    Write-Warning "Teams Chat widget is enabled. Teams could be reinstalled if the user clicks 'Continue' after using Win+C or by clicking the Chat icon in the taskbar (if enabled). Use the '-DisableChatWidget' or '-DisableChatWidget -AllUsers' switch to disable it. Current user takes precedence unless unset. Use 'Get-Help UninstallTeams -Full' for more information."
}

# Output the Office Teams install status
$OfficeTeamsInstallStatus = Get-OfficeTeamsInstallStatus

# Chat widget status
Write-Section("Office's ability to install Teams")
Write-Output "Status: $OfficeTeamsInstallStatus"
Write-Output ""

# If Office Team install status is Enabled or unset, show a warning
if (($OfficeTeamsInstallStatus -eq "Enabled") -or ($OfficeTeamsInstallStatus -eq "Unset (default is enabled)")) {
    Write-Warning "Office is allowing Teams to install. Teams could be reinstalled if Office is installed or updated.`nUse the '-DisableOfficeTeamsInstall' switch to prevent Teams from installing with Office. Use 'Get-Help UninstallTeams -Full' for more information."
}

# Office note
Write-Section("Office Note")
Write-Output "If you just installed Microsoft Office, you may need to restart the computer once or`ntwice and then run UninstallTeams to prevent Teams from reinstalling."

# Spacer
Write-Output ""
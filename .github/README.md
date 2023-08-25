![Uninstall Teams](https://github.com/asheroto/UninstallTeams/assets/49938263/aaa5ab1a-40f3-4a38-bf44-5ee7dbece2df)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/UninstallTeams)](https://github.com/asheroto/UninstallTeams/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/UninstallTeams/total)](https://github.com/asheroto/UninstallTeams/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>

# UninstallTeams

UninstallTeams is a PowerShell script that allows you to quickly uninstall Microsoft Teams from all locations on your Windows machine. Desktop and Start Menu shortcuts are also removed.

You can also adjust the ability to access the Chat widget (Win+C) by enabling, disabling, or unsetting (default / effectively enabling). By default, the chat widget is enabled (unset). You can disable it by running the script with the `-DisableChatWidget` parameter. The `-AllUsers` parameter can be used to apply the setting to all user profiles on the machine, excluding the current one, as they are not applied to the current user profile (HKLM/HKCU registry hives).

By default when installing Microsoft Office, Teams is installed. To prevent Teams from being installed when installing Office, you can run `-EnablePreventTeamsInstall` *before* you install Office. To re-enable Teams to be installed when installing Office, you can run `-DisablePreventTeamsInstall`. This is a machine-wide setting.

If you specify a paramter, it will not uninstall Teams. If you do not specify a parameter, it will uninstall Teams.

Microsoft Teams user data is not removed.

**Note:** If you just installed Microsoft Office, you may need to restart the computer once or twice and then run UninstallTeams to prevent Teams from reinstalling.

## Setup

### Method 1 - PowerShell Gallery

**Note:** please use the latest version using Install-Script or the PS1 file from Releases, the version on GitHub itself may be under development and not work properly.

Open PowerShell as Administrator and type

```powershell
Install-Script UninstallTeams -Force
```

Follow the prompts to complete the installation (you can tap `A` to accept all prompts or `Y` to select them individually.

**Note:** `-Force` is optional but recommended, as it will force the script to update if it is outdated.

The script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/UninstallTeams) under `UninstallTeams`.

### Tip - How to trust PSGallery

If you want to trust PSGallery so you aren't prompted each time you run this command, or if you're scripting this and want to ensure the script isn't interrupted the first time it runs...

```powershell
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

### Method 2 - Download Locally and Run

-   Download the latest [UninstallTeams.ps1](https://github.com/asheroto/UninstallTeams/releases/latest/download/UninstallTeams.ps1) from [Releases](https://github.com/asheroto/UninstallTeams/releases)
-   Run the script with `.\UninstallTeams.ps1`

## Usage

In PowerShell, type

```powershell
UninstallTeams
```

This will execute the script and uninstall Microsoft Teams from your machine.

### Parameters

UninstallTeams provides additional options to manage the Chat widget (Win+C) for Microsoft Teams, as well as the ability to prevent Teams from being installed when installing Microsoft Office.

| Parameter                | Description                                                                                     |
|--------------------------|-------------------------------------------------------------------------------------------------|
| EnableChatWidget         | Enables the Chat widget (Win+C) for Microsoft Teams.                                            |
| DisableChatWidget        | Disables the Chat widget (Win+C) for Microsoft Teams.                                           |
| UnsetChatWidget          | Removes the Chat widget key, effectively enabling it since that is the default.                 |
| AllUsers                 | Applies the Chat widget setting to all user profiles on the machine.                            |
| EnableOfficeTeamsInstall | Enables the ability for Office to install Teams.                                                |
| DisableOfficeTeamsInstall| Disables the ability for Office to install Teams.                                               |
| UnsetOfficeTeamsInstall  | Unsets the ability for Office to install Teams (default is enabled).                            |
| Version                  | Outputs the current version of the script.                                                      |
| Help                     | Displays the full help information for the script.                                              |
| CheckForUpdate           | Checks for updates to the script on GitHub.                                                     |

These options are used independent of the main script.
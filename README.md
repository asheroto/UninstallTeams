![Uninstall Teams](https://github.com/asheroto/UninstallTeams/assets/49938263/5d786fb1-6716-4636-b407-6feb1e7a48fd)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/UninstallTeams)](https://github.com/asheroto/UninstallTeams/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/UninstallTeams/total)](https://github.com/asheroto/UninstallTeams/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=seb6596&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=asheroto&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# UninstallTeams

UninstallTeams is a PowerShell script that allows you to quickly uninstall Microsoft Teams from all locations on your Windows machine. Desktop and Start Menu shortcuts are also removed.

You can also adjust the ability to access the Chat widget (Win+C) by enabling, disabling, or unsetting (default / effectively enabling). By default, the chat widget is enabled (unset). You can disable it by running the script with the `-DisableChatWidget` parameter. The `-AllUsers` parameter can be used to apply the setting to all user profiles on the machine, excluding the current one, as they are not applied to the current user profile (HKLM/HKCU registry hives).

By default when installing Microsoft Office, Teams is installed. To prevent Teams from being installed when installing Office, you can run `-EnablePreventTeamsInstall` _before_ you install Office. To re-enable Teams to be installed when installing Office, you can run `-DisablePreventTeamsInstall`. This is a machine-wide setting.

If you specify a paramter, it will not uninstall Teams. If you do not specify a parameter, it will uninstall Teams.

Microsoft Teams user data is not removed.

**Note:** If you just installed Microsoft Office, you may need to restart the computer once or twice and then run UninstallTeams to prevent Teams from reinstalling.

## Setup

**Note:** For a stable experience, use one of the methods listed below (#1, #2, or #3) to fetch the latest version. **Using the version directly from the GitHub repository is not advised**, as it could be under active development and not fully stable.

### Method 1 - PowerShell Gallery

**This is the recommended method, because it always gets the public release that has been tested, it's easy to remember, and supports all parameters.**

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

### Method 2 - One Line Command (Runs Immediately)

The URL [asheroto.com/uninstallteams](https://asheroto.com/uninstallteams) always redirects to the [latest code-signed release](https://github.com/asheroto/UninstallTeams/releases/latest/download/UninstallTeams.ps1) of the script.

If you just need to run the basic script without any parameters, you can use the following one-line command:

```powershell
irm asheroto.com/uninstallteams | iex
```

Due to the nature of how PowerShell works, you won't be able to use any parameters like `-DisableOfficeTeamsInstall` with this command. You can either use Method [#1](https://github.com/asheroto/UninstallTeams#method-1---powershell-gallery), [#3](https://github.com/asheroto/UninstallTeams#method-3---download-locally-and-run), or if you absolutely need to use a one-line command with parameters, you can use the following:

```powershell
&([ScriptBlock]::Create((irm asheroto.com/uninstallteams))) -DisableOfficeTeamsInstall
```

### Method 3 - Download Locally and Run

-   Download the latest [UninstallTeams.ps1](https://github.com/asheroto/UninstallTeams/releases/latest/download/UninstallTeams.ps1) from [Releases](https://github.com/asheroto/UninstallTeams/releases)
-   Run the script with `.\UninstallTeams.ps1`

## Usage

In PowerShell, type

```powershell
UninstallTeams
```

This will execute the script and uninstall Microsoft Teams from your machine.

### Parameters

These options are used independent of the main script. If you do not use any options, the script will uninstall Teams. If you use any of the options, the script will not uninstall Teams.

UninstallTeams provides additional options to manage the Chat widget (Win+C) for Microsoft Teams, as well as the ability to prevent Teams from being installed when installing Microsoft Office.

| Parameter                    | Description                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------- |
| `-EnableChatWidget`          | Enables the Chat widget (Win+C) for Microsoft Teams.                                        |
| `-DisableChatWidget`         | Disables the Chat widget (Win+C) for Microsoft Teams.                                       |
| `-UnsetChatWidget`           | Removes the Chat widget value, effectively enabling it since that is the default.           |
| `-AllUsers`                  | Applies the Chat widget setting to all user profiles on the machine.                        |
| `-EnableOfficeTeamsInstall`  | Enables the ability for Office to install Teams.                                            |
| `-DisableOfficeTeamsInstall` | Disables the ability for Office to install Teams.                                           |
| `-UnsetOfficeTeamsInstall`   | Removes the Office Teams registry value, effectively enabling it since that is the default. |
| `-Version`                   | Outputs the current version of the script.                                                  |
| `-Help`                      | Displays the full help information for the script.                                          |
| `-CheckForUpdate`            | Checks for updates to the script on GitHub.                                                 |
| `-Debug`                     | Debug information is natively supported with additional information presented if used.      |

## Contributing

If you'd like to help develop this project: fork the repo, edit, then submit a pull request. 😊
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/UninstallTeams)](https://github.com/asheroto/UninstallTeams/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/UninstallTeams/total)](https://github.com/sponsors/asheroto)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/asheroto)

# UninstallTeams

UninstallTeams is a PowerShell script that allows you to quickly uninstall Microsoft Teams from all locations on your Windows machine. You can also adjust the status of the Chat widget (Win+C) by enabling, disabling, or unsetting (default / effectively enabling).

## Installation

To install UninstallTeams, open PowerShell as Administrator and run the following command:

```powershell
Install-Script UninstallTeams
```

Follow the prompts to complete the installation (you can tap `A` to accept all prompts or `Y` to select them individually.

The script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/UninstallTeams).

### Tip - How to trust PSGallery

If you want to trust PSGallery so you aren't prompted each time you run this command, you can type...

```powershell
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
```

## Usage

To use UninstallTeams, open PowerShell as Administrator and run the following command:

```powershell
UninstallTeams
```

This will execute the script and uninstall Microsoft Teams from your machine.

### Chat Widget Options

UninstallTeams provides additional options to manage the Chat widget (Win+C) for Microsoft Teams.

You can use the following parameters:
| Parameter | Required | Description |
| --------------------- | -------- | ------------------------------------------------------------------- |
| `-EnableChatWidget` | No | Enables the Chat widget (Win+C) for Microsoft Teams. |
| `-DisableChatWidget` | No | Disables the Chat widget (Win+C) for Microsoft Teams. |
| `-UnsetChatWidget` | No | Removes the Chat widget key, effectively enabling it (default). |
| `-AllUsers` | No | Applies the Chat widget setting to all user profiles on the machine. |

These options are used independent of the main script.
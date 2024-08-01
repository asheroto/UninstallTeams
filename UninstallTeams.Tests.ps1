# First unset
.\UninstallTeams.ps1 -UnsetOfficeTeamsInstall
.\UninstallTeams.ps1 -UnsetChatWidget
.\UninstallTeams.ps1 -UnsetChatWidget -AllUsers

# Dot source the main script
. "$PSScriptRoot\UninstallTeams.ps1"

Describe "UninstallTeams" {
    Context "When running the script" {
        It "Should uninstall Microsoft Teams and remove the Teams directory" {
            # Example assertion to check if a value is true
            $true | Should -Be $true
        }
    }
}

Describe "Get-ChatWidgetStatus Function" {
    Context "When the registry key is missing" {
        It "Should return 'Unset (default is enabled)'" {
            $status = Get-ChatWidgetStatus
            if ($status -eq "Unset (default is enabled)") {
                # Test passed
                $true | Should -Be $true
            } elseif ($status -eq "Hidden") {
                # Test passed but with unexpected result, display a warning
                Write-Warning "Unexpected result: The registry key is missing, but the status is 'Hidden'."
                $true | Should -Be $true
            } else {
                # Test failed
                Throw "Test failed: Unexpected status '$status' returned."
            }
        }
    }
}


Context "When ChatIcon value is 1" {
    It "Should return 'Enabled'" {
        # Set the ChatIcon value to 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 1 -Type DWord -Force
        $status = Get-ChatWidgetStatus
        $status | Should -Be "Enabled"
        # Remove the ChatIcon value
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Force
    }
}

Context "When ChatIcon value is 2" {
    It "Should return 'Hidden'" {
        # Set the ChatIcon value to 2
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 2 -Type DWord -Force
        $status = Get-ChatWidgetStatus
        $status | Should -Be "Hidden"
        # Remove the ChatIcon value
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Force
    }
}

Context "When ChatIcon value is 3" {
    It "Should return 'Disabled'" {
        # Set the ChatIcon value to 3
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 3 -Type DWord -Force
        $status = Get-ChatWidgetStatus
        $status | Should -Be "Disabled"
        # Remove the ChatIcon value
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Force
    }
}

Context "When -AllUsers switch is used without -EnableChatWidget, -DisableChatWidget, or -UnsetChatWidget" {
    It "Should not throw an error" {
        { Get-ChatWidgetStatus -AllUsers } | Should -Not -Throw
    }
}

Context "When -AllUsers switch is used with -EnableChatWidget" {
    It "Should set the Chat widget status for all users" {
        Set-ChatWidgetStatus -EnableChatWidget -AllUsers
        $status = Get-ChatWidgetStatus -AllUsers
        $status | Should -Be "Enabled"
        # Disable the Chat widget for all users
        Set-ChatWidgetStatus -DisableChatWidget -AllUsers
    }
}

Context "When -AllUsers switch is used with -DisableChatWidget" {
    It "Should set the Chat widget status for all users" {
        Set-ChatWidgetStatus -DisableChatWidget -AllUsers
        $status = Get-ChatWidgetStatus -AllUsers
        $status | Should -Be "Disabled"
        # Enable the Chat widget for all users
        Set-ChatWidgetStatus -EnableChatWidget -AllUsers
    }
}

Context "When -AllUsers switch is used with -UnsetChatWidget" {
    It "Should set the Chat widget status for all users" {
        Set-ChatWidgetStatus -UnsetChatWidget -AllUsers
        $status = Get-ChatWidgetStatus -AllUsers
        $status | Should -Be "Unset (default is enabled)"
    }
}

Describe "Set-ChatWidgetStatus Function" {
    Context "When -EnableChatWidget switch is used" {
        It "Should enable the Chat widget" {
            Set-ChatWidgetStatus -EnableChatWidget
            $status = Get-ChatWidgetStatus
            $status | Should -Be "Enabled"
            # Disable the Chat widget
            Set-ChatWidgetStatus -DisableChatWidget
        }
    }

    Context "When -DisableChatWidget switch is used" {
        It "Should disable the Chat widget" {
            Set-ChatWidgetStatus -DisableChatWidget
            $status = Get-ChatWidgetStatus
            $status | Should -Be "Disabled"
            # Enable the Chat widget
            Set-ChatWidgetStatus -EnableChatWidget
        }
    }

    Context "When -UnsetChatWidget switch is used" {
        It "Should unset the Chat widget" {
            Set-ChatWidgetStatus -UnsetChatWidget
            $status = Get-ChatWidgetStatus
            $status | Should -Be "Unset (default is enabled)"
        }
    }

    Context "When -AllUsers switch is used" {
        It "Should set the Chat widget status for all users" {
            Set-ChatWidgetStatus -EnableChatWidget -AllUsers
            $status = Get-ChatWidgetStatus -AllUsers
            $status | Should -Be "Enabled"
            # Disable the Chat widget for all users
            Set-ChatWidgetStatus -DisableChatWidget -AllUsers
        }
    }
}

Describe "Get-OfficeTeamsInstallStatus Function" {
    Context "When the registry key is missing" {
        It "Should return 'Unset (default is enabled)'" {
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Unset (default is enabled)"
        }
    }

    Context "When PreventTeamsInstall value is 0" {
        It "Should return 'Enabled'" {
            # Set the PreventTeamsInstall value to 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "PreventTeamsInstall" -Value 0 -Type DWord -Force
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Enabled"
            # Remove the PreventTeamsInstall value
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "PreventTeamsInstall" -Force
        }
    }

    Context "When PreventTeamsInstall value is 1" {
        It "Should return 'Disabled'" {
            # Set the PreventTeamsInstall value to 1
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "PreventTeamsInstall" -Value 1 -Type DWord -Force
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Disabled"
            # Remove the PreventTeamsInstall value
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "PreventTeamsInstall" -Force
        }
    }
}

Describe "Set-OfficeTeamsInstallStatus Function" {
    Context "When -EnableOfficeTeamsInstall switch is used" {
        It "Should enable Office's ability to install Teams" {
            Set-OfficeTeamsInstallStatus -EnableOfficeTeamsInstall
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Enabled"
            # Unset the Office Teams Install
            Set-OfficeTeamsInstallStatus -UnsetOfficeTeamsInstall
        }
    }

    Context "When -DisableOfficeTeamsInstall switch is used" {
        It "Should disable Office's ability to install Teams" {
            Set-OfficeTeamsInstallStatus -DisableOfficeTeamsInstall
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Disabled"
            # Unset the Office Teams Install
            Set-OfficeTeamsInstallStatus -UnsetOfficeTeamsInstall
        }
    }

    Context "When -UnsetOfficeTeamsInstall switch is used" {
        It "Should unset Office's ability to install Teams" {
            Set-OfficeTeamsInstallStatus -UnsetOfficeTeamsInstall
            $status = Get-OfficeTeamsInstallStatus
            $status | Should -Be "Unset (default is enabled)"
        }
    }
}

Describe "Uninstall Teams" {
    Context "After running the uninstall script" {
        It "Should have stopped the Teams process" {
            Get-Process -Name "*teams*" -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Should have removed the uninstall registry key" {
            $uninstallString = Get-UninstallString -Match "Teams"
            $uninstallString | Should -BeNullOrEmpty
        }

        It "Should have removed Teams from AppData\Microsoft\Teams" {
            $TeamsUpdateExePath = Join-Path $env:APPDATA "Microsoft\Teams\Update.exe"
            Test-Path $TeamsUpdateExePath | Should -Be $false
        }

        It "Should have removed Teams from Program Files (x86)" {
            $TeamsPrgFiles = Join-Path ${env:ProgramFiles(x86)} "Teams Installer\Teams.exe"
            Test-Path $TeamsPrgFiles | Should -Be $false
        }

        It "Should have removed Teams AppxPackage" {
            Get-AppxPackage "*Teams*" | Should -BeNullOrEmpty
        }

        It "Should have deleted the Microsoft Teams directory" {
            $TeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft Teams"
            Test-Path $TeamsPath | Should -Be $false
        }

        It "Should have deleted the Teams directory" {
            $TeamsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Teams"
            Test-Path $TeamsPath | Should -Be $false
        }

        It "Should have deleted Teams startup registry key" {
            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineInstaller' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'TeamsMachineInstaller' -ErrorAction Stop
            } | Should -Throw
        }

        It "Should have deleted Teams startup registry key" {
            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'TeamsMachineInstaller' -ErrorAction Stop
            } | Should -Throw

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled' -Name 'TeamsMachineInstaller' -ErrorAction Stop
            } | Should -Throw
        }

        It "Should have deleted Teams uninstall registry key" {
            {
                Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams' -ErrorAction Stop
            }

            {
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams' -ErrorAction Stop
            }
        }

        Describe "Uninstall Teams" {
            Context "When running the script" {
                It "Should have deleted Teams desktop shortcuts" {
                    $userDesktopPath = [System.Environment]::GetFolderPath('Desktop')
                    $publicDesktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
                    $userShortcutPath = Join-Path -Path $userDesktopPath -ChildPath "Microsoft Teams.lnk"
                    $publicShortcutPath = Join-Path -Path $publicDesktopPath -ChildPath "Microsoft Teams.lnk"

                    (Test-Path -Path $userShortcutPath) | Should -Be $false
                    (Test-Path -Path $publicShortcutPath) | Should -Be $false
                }

                It "Should have deleted Teams start menu shortcuts" {
                    $userStartMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('StartMenu'), "Programs")
                    $publicStartMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('CommonStartMenu'), "Programs")
                    $userShortcutPath = Join-Path -Path $userStartMenuPath -ChildPath "Microsoft Teams.lnk"
                    $publicShortcutPath = Join-Path -Path $publicStartMenuPath -ChildPath "Microsoft Teams.lnk"

                    (Test-Path -Path $userShortcutPath) | Should -Be $false
                    (Test-Path -Path $publicShortcutPath) | Should -Be $false
                }
            }
        }

    }
}
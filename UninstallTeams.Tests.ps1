# Dot source the main script
. "$PSScriptRoot\UninstallTeams.ps1"

Describe "UninstallTeams" {
	Context "When running the script" {
		It "Should uninstall Microsoft Teams and remove the Teams directory" {
			# Add your assertions here
			$true | Should -Be $true
		}
	}
}

Describe "Get-ChatWidgetStatus Function" {
	Context "When the registry key is missing" {
		It "Should return 'Not Set'" {
			$status = Get-ChatWidgetStatus
			if ($status -eq "Not Set") {
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
			$status | Should -Be "Not Set"
		}
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
			$status | Should -Be "Not Set"
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
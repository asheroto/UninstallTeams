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
# SIG # Begin signature block
# MIIp0AYJKoZIhvcNAQcCoIIpwTCCKb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCd3boS/qIsRIUP
# WxEkJ9fwoFF37iX56qXdkjWX904PuqCCDrkwggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wgggBMIIF6aADAgECAhAOyLAmjUpdRlQheQrwADJFMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjIwNDAxMDAwMDAwWhcNMjMwNDAx
# MjM1OTU5WjCB0zETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhPa2xhaG9tYTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEzARBgNV
# BAUTCjE5MTMwMjk2MDExCzAJBgNVBAYTAlVTMREwDwYDVQQIEwhPa2xhaG9tYTER
# MA8GA1UEBxMITXVza29nZWUxHDAaBgNVBAoTE0FzaGVyIFNvbHV0aW9ucyBJbmMx
# HDAaBgNVBAMTE0FzaGVyIFNvbHV0aW9ucyBJbmMwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCwsC6ZPJjALlD34NKQyBQp7LMwO61CnMijdMX5VdjqfbII
# 3bTcVIxd9c2VXA4CNHOySle9mwrUKg0/fuSMCL6v+YT+nlykdiGF+1JzF/xztPxi
# UYh/nosuzuJli1cKSqLklo1aJBSbaraI2d2uuEhuZs1bdtNEiDAqB9uzLM1sjdA9
# xMcGqa0a0fWHkiMTgcoTOXttegnjRaOfLjoOHMG885zCbivqvUi1PDw/denxiY8J
# USIlXrfRXG63+HOzp4CyX4BTOdhhljj9KB5WVo8671gBdFFjxG9sjlDpBqT11etn
# ZUS3WUNOx3RnAmUQeriDSlChZuDr4oGS5C2Czwv5tKp/lWsbmBzIlBek0IuxKv+B
# Ve5dIM8lx5o8FV+mHyt9OWPqh1G4I03vS4KQTKs79ck7msPUcWICBb9WUKSFiKbL
# 991jbjY8cviKvI7keQiY+kOP3kH83H8vNSe6cFoFEBFDlq3giO1BYV/36bSsM9xx
# ZgBXQqfMqjqX/HsCRMSRb6aS/GaETq0s9/5ExMJEoLPTN/xi4h+ErLTooX6DgY2Y
# 4Lg5zWeSX3rC9b2/h5SifXxhKDxL8B4V6Pba0mOhc36TcTmPIbz0rBn097i8kuCG
# h11jpqCgfi2jtyyEbsOvEcpnQAwb/SiWbznD0IpNwsnYk5t1hBYx4TTxU8FrNQID
# AQABo4ICODCCAjQwHwYDVR0jBBgwFoAUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHQYD
# VR0OBBYEFNK8fnBc0Eyw1svglEaxakfmNIEzMDEGA1UdEQQqMCigJgYIKwYBBQUH
# CAOgGjAYDBZVUy1PS0xBSE9NQS0xOTEzMDI5NjAxMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JT
# QTQwOTZTSEEzODQyMDIxQ0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0
# MjAyMUNBMS5jcmwwPQYDVR0gBDYwNDAyBgVngQwBAzApMCcGCCsGAQUFBwIBFhto
# dHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXAYIKwYBBQUHMAKG
# UGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENv
# ZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0MAwGA1UdEwEB/wQCMAAw
# DQYJKoZIhvcNAQELBQADggIBABH5uRf88l9+NJ1427Htk3pDHtE1xpJjWI2GNx6H
# ML7PkUqt8VTYOBZcyN/GpQKbp4aA+YNvRK4r/YN3LelR5j+OItSiNcY9f/x0ODfZ
# 90pBvuo+1HCBaZAHhnuiMQFH80ej/vtQ6YtAhphOGjKWEeStCtFp5WD5NNZICBYF
# /omOktMibMWpbR+ya5bT1l/VmnBrMawljkZqy4aKWT4quKb5p1mHcVD2SJxqEKrt
# Ql8iHFR0j96vNnuhWRpYGs38AAx3vWrX/6sGTLXdyrjsHVVYOcRD/DuH2kGXFzmL
# T7/1RGEZJDIQkWDgDJEmjIC98O9uO+gFTwkqkyen3gHj7DzMMtHTnkVe8Efu7Vtf
# qE4EkcPk3eXIL/tEmtr3sXqBKLoNm+c1OUn9PdzZwNFqBgPHZvLKfBtOI1Q/2C88
# fTOEFofJIC2s95MAGMgzHbJOPSWhNRDNkIJbFaGeCxlddb7DoWtKoCZhFtEKtrSF
# h7kzXSvqQqJTsE8z9pB/pRyDNzSYMqDHifZy6rkMkqd7Nv3btUzlyzFxrok3+CDs
# XfwXbO2PJe6HUL2Cvq5lw+1/dsedOoNbdvmX0e84W8tFbJJPs3as1u6OdtRs7tmB
# A/VJxtkZp5vMH4Erdw3ZagCHUGRMX+a5rNzMElHFSkoR5cOt7sKXBzyKx/tI0XgV
# sCHhMYIabTCCGmkCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWdu
# aW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAOyLAmjUpdRlQheQrwADJFMA0G
# CWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZI
# hvcNAQkEMSIEIFRZIKLSeH2k77LvsbbzQjdN0K8dKWvbD1SMFfbhAe2rMA0GCSqG
# SIb3DQEBAQUABIICAJznWGGOp4HUYkeQL7sNe4iHMtppjV7+rLnLhWxVWg0WbvGX
# 9RP5/IOheN7KDOtU50emXE+yqebdy+etEkYuOFGhlbnFdVHgggCCz8p8HzAnzTW8
# dFn+X4/2Rm34b4rzqLNIolTty6w2SSdXGX9jwf671ZwX4X9umhhLas2u9tho+r/I
# VOvunom8E31SGqIAW34V39CSWPWMK6FF4EhbFMmx1H5C4qsz955klQy2WoYYrj+X
# bku/bz2avKc8g+hlOnGfqm/b7CSJPHyc8gR8tsXeHWZf5C5oXE6R0ZmC7ltjgJ49
# JR7cJRt7TY9lnzfBx7bMYVkq41EPR2Vv0MQqdrcPqDPGyyO7T/i2hEt0+8mBuW5n
# /5kOSLWLwOxK30/CLLhzOO9Vb8+EHhtWz35K6PjZuG+/pCn+JWQAt/JQqFGAemm8
# x0ew+spg0+KChZoiNJhhXJsrj32C0wUmoE42Ufw9tHCSSCLN7NO+KxqbpsZh9bMT
# 92fMEdUgZNzEyrBs2tuY7Fjsr1Ge5LyhTvxhkLoFDHk8Fko7z2GAdNfWXiPDeUxT
# x4R0RE3qpmsBfjMycUHa0DNQNXXpz2chfsz9/Ota8mAHMFGpGOPwiYyrokJdt4+i
# mWCfEWLQDhMqggkrXhAFphbtVvH656IWku0OP3w2ikZxKrbLoVp6BEtjVwo0oYIX
# QzCCFz8GCisGAQQBgjcDAwExghcvMIIXKwYJKoZIhvcNAQcCoIIXHDCCFxgCAQMx
# DzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9
# bAcBMDEwDQYJYIZIAWUDBAIBBQAEIHLDD6CMX/BbKjvcMl57v3VvCTu8OpR4I6VG
# aGNcy/GHAhAF6A4Ubrr/ZPUVQLYUPEtvGA8yMDIyMDgyOTA0MDUzMFqgghMNMIIG
# xjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaXnTANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTIyMDMyOTAwMDAwMFoXDTMzMDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSQwIgYDVQQDExtEaWdpQ2VydCBUaW1l
# c3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5
# KpYjply8X9ZJ8BWCGPQz7sxcbOPgJS7SMeQ8QK77q8TjeF1+XDbq9SWNQ6OB6zhj
# +TyIad480jBRDTEHukZu6aNLSOiJQX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2s
# O37cKhypvTDGFtjavOuy8YPRn80JxblBakVCI0Fa+GDTZSw+fl69lqfw/LH09CjP
# QnkfO8eTB2ho5UQ0Ul8PUN7UWSxEdMAyRxlb4pguj9DKP//GZ888k5VOhOl2GJiZ
# ERTFKwygM9tNJIXogpThLwPuf4UCyYbh1RgUtwRF8+A4vaK9enGY7BXn/S7s0psA
# iqwdjTuAaP7QWZgmzuDtrn8oLsKe4AtLyAjRMruD+iM82f/SjLv3QyPf58NaBWJ+
# cCzlK7I9Y+rIroEga0OJyH5fsBrdGb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh/9sR
# L5IDMM4wt4sPXUSzQx0jUM2R1y+d+/zNscGnxA7E70A+GToC1DGpaaBJ+XXhm+ho
# 5GoMj+vksSF7hmdYfn8f6CvkFLIW1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/G
# baR5Sa2Lf2GHBWj31HDjQpXonrubS7LitkE956+nGijJrWGwoEEYGU7tR5thle0+
# C2Fa6j56mJJRzT/JROeAiylCcvd5st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYD
# VR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaA
# FLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSNZLeJIf5WWESEYafqbxw2
# j92vDTBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3Js
# MIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0Eu
# Y3J0MA0GCSqGSIb3DQEBCwUAA4ICAQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeC
# KZxDbwEtqzi1cBG/hBmLP13lhk++kzreKjlaOU7YhFmlvBuYquhs79FIaRk4W8+J
# OR1wcNlO3yMibNXf9lnLocLqTHbKodyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/u
# SZW3s8zFp+4O4e8eOIqf7xHJMUpYtt84fMv6XPfkU79uCnx+196Y1SlliQ+inMBl
# 9AEiZcfqXnSmWzWSUHz0F6aHZE8+RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAG
# cqlEO2lHEdPu6cegPk8QuTA25POqaQmoi35komWUEftuMvH1uzitzcCTEdUyeEpL
# NypM81zctoXAu3AwVXjWmP5UbX9xqUgaeN1Gdy4besAzivhKKIwSqHPPLfnTI/Ke
# GeANlCig69saUaCVgo4oa6TOnXbeqXOqSGpZQ65f6vgPBkKd3wZolv4qoHRbY2be
# ayy4eKpNcG3wLPEHFX41tOa1DKKZpdcVazUOhdbgLMzgDCS4fFILHpl878jIxYxY
# aa+rPeHPzH0VrhS/inHfypex2EfqHIXgRU4SHBQpWMxv03/LvsEOSm8gnK7ZczJZ
# COctkqEaEf4ymKZdK5fgi9OczG21Da5HYzhHF1tvE9pqEG4fSbdEW7QICodaWQR2
# EaGndwITHDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcN
# AQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3Rl
# ZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8Ty
# kTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsm
# c5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTn
# KC3r07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2
# R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0
# QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/
# oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1ps
# lPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhI
# fxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8
# I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkU
# EBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1G
# nrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEA
# MB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC
# 0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSG
# Mmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0B
# AQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7
# cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2p
# Vs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxk
# Jodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpkn
# G6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2
# n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fm
# w0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvt
# Cl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU
# 5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8K
# vYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/
# GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIE
# daADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAe
# Fw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC
# 4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWl
# fr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1j
# KS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dP
# pzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3
# pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJ
# pMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aa
# dMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXD
# j/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB
# 4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ
# 33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amy
# HeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC
# 0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823I
# DzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYD
# VR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcN
# AQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxpp
# VCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6
# mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPH
# h6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCN
# NWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg6
# 2fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAp6
# SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjA4MjkwNDA1MzBaMCsGCyqG
# SIb3DQEJEAIMMRwwGjAYMBYEFIUI84ZRXLPTB322tLfAfxtKXkHeMC8GCSqGSIb3
# DQEJBDEiBCCjKTPkNgQ3uoG+vOAFgp6xLnQdXGS02NwbSkZl4DXUHTA3BgsqhkiG
# 9w0BCRACLzEoMCYwJDAiBCCdppAVw0nGwYl4Rbo1gq1wyI+kKTvbar6cK9JTknnm
# OzANBgkqhkiG9w0BAQEFAASCAgCwx/BVKTzBs3T66MaF3sFT/OM55DjAokF9QiYn
# 0HZ/EdBjN6YuuddwKXMlDWqqIXqNBV+Dl6Fh68wkg+M46cAb+52MV+Yv3529KVjm
# 2jTXqCBAgHA63XTjMqUrz0VmeASzGiMYv5QDtixSTjwAp2xxBtC7TGZemivi7xjw
# /F0X+h2glwSkCArJHagKhMyjDhqjwz3r6aq0EyOpENiX6LOGAKPvDa0t8pMBmTBL
# MEaBoXvZ/+vHHJk3MEBziz3vuvs2Y38kqqSY4vIa5vhExF1cGbU639qAYbFif7mr
# 7TjyYO8zFlAzIoIfExfk10dc9mgHufo4Nomz8QSG5jC1R6J0k07BIfa12uWFx6bT
# 9ZXIXAFyHxPdnIUqYTJlp2PXrGRUdNiujvoRD+juNEVkbbZzf8ixBYujeyWV9SQo
# hNGWzLMw3zvLarkhIsER3juxE4BisJ9XPm3igMkuhqhpKaIwqhtbdRbEC4MFTN2z
# 4EmT4GrOMBDC1YgiWl4mKi8xYgsMk6Gh5NCzbehDJB0XrphSWJWfO5Ytwn0Eh9Hj
# wfBH4IBSdAwAOwO5zCI5sTs5VErJ8jPP9S0NEh5s0/YvxCUOaelItIgSnW5e1YY+
# 84mJUkltNPYLBTyEZ+YSZg0jjS1wC++fqun/wbWzuxpOKmecd+hOmy7OvRoOoPsy
# Yb5qBA==
# SIG # End signature block

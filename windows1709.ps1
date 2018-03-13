# Notable Site: http://getadmx.com/?Category=Windows_10_2016#

# Self Elevate
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Execution Setting
Set-ExecutionPolicy Unrestricted -Force -Confirm:$false

# Administrator Account
net user "Administrator" /active:yes
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername" -Value "Administrator"
Remove-LocalUser -Name "deleteme" -ErrorAction SilentlyContinue

Restart-Computer -Force

# Remove Initial User
if (Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -like "*deleteme*"}) {
    (Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -like "*deleteme*"}).Delete()
}

New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR" -ErrorAction SilentlyContinue
New-PSDrive -PSProvider "Registry" -Name "HKU" -Root "HKEY_USERS" -ErrorAction SilentlyContinue

# Function which tests for up to three levels of Hive Paths and creates what is needed
function Make-HiveKey {param (
        [string]$hivekey
    )
    try {
        if (!(Test-Path -Path $hivekey)) {
            $parentHK = $hivekey.Substring(0, $hivekey.lastIndexOf('\'))
            if (!(Test-Path -Path $parentHK)) {
                if (!(Test-Path -Path $parentHK.Substring(0, $parentHK.lastIndexOf('\')))) {
                    New-Item -Path $parentHK.Substring(0, $parentHK.lastIndexOf('\'))
                }
                New-Item -Path $parentHK
            }
            New-Item -Path $hivekey
        }
    } catch {
        Write-Error "Error making HKEY"
    }
}

# Taskbar pinning
$pinnedApps = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | select Name
$pinApps = @('This PC','Internet Explorer','Microsoft Edge','Settings','Control Panel','Remote Desktop Connection','Windows Powershell',
'Command Prompt','Calculator','Notepad','Paint','Snipping Tool')

function Pin-App {param (
        [string]$appname,
        [switch]$unpin
    )
    try {
        if ($unpin.IsPresent) {
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | %{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        } else {
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'To "Start" Pin|Pin to Start'} | %{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    } catch {
        Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
    }
}

foreach ($pinned in $pinnedApps) {Pin-App $pinned.Name -unpin}
foreach ($pin in $pinApps) {Pin-App $pin}

# OneDrive Removal
if (Get-Process -ProcessName "OneDrive.exe" -ErrorAction SilentlyContinue) {
    taskkill.exe /F /IM "OneDrive.exe"
}
if (Get-Service -Name "OneDrive.exe" -ErrorAction SilentlyContinue) {
    taskkill.exe /F /IM "OneDrive.exe"
}

$onedriveHK = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive","HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive",
"HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}","HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")

$onedriveIP = @("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive","DisableFileSyncNGSC",1),
@("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}","System.IsPinnedToNameSpaceTree",0),
@("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}","System.IsPinnedToNameSpaceTree",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive","DisableMeteredNetworkFileSync",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive","DisableLibrariesDefaultSaveToOneDrive",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive","DisableFileSyncNGSC",1)

foreach ($one in $onedriveHK) {Make-HiveKey $one}
foreach ($one in $onedriveIP) {Set-ItemProperty -Path $one[0] -Name $one[1] -Value $one[2]}

if (Test-Path "$ENV:USERPROFILE\OneDrive" -ErrorAction SilentlyContinue) {
    Remove-Item "$ENV:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
}

if (Test-Path "$ENV:LOCALAPPDATA\Microsoft\OneDrive" -ErrorAction SilentlyContinue) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$ENV:LOCALAPPDATA\Microsoft\OneDrive"
}
if (Test-Path "$ENV:PROGRAMDATA\Microsoft OneDrive" -ErrorAction SilentlyContinue) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$ENV:PROGRAMDATA\Microsoft OneDrive"
}
if (Test-Path "C:\OneDriveTemp" -ErrorAction SilentlyContinue) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"
}

reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
if (Get-ItemProperty "HKU:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -ErrorAction SilentlyContinue) {
    Remove-ItemProperty "HKU:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -Force
}
reg unload "hku\Default"

if (Test-Path "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -ErrorAction SilentlyContinue) {
    Remove-Item "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -ErrorAction SilentlyContinue
}

if (Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ErrorAction SilentlyContinue) {
    Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
}

Stop-Process -ProcessName explorer

Start-Sleep -Seconds 5

# Uninstall Apps
$winApps = @("Microsoft.MicrosoftOfficeHub","Microsoft.XboxApp","Microsoft.Xbox.TCUI","Microsoft.WindowsStore","Microsoft.ZuneVideo",
"Microsoft.ZuneMusic","Microsoft.XboxSpeechToTextOverlay","Microsoft.XboxIdentityProvider","Microsoft.BingWeather",
"Microsoft.XboxGameOverlay","Microsoft.WindowsFeedbackHub","microsoft.windowscommunicationsapps","Microsoft.Wallet","Microsoft.StorePurchaseApp"
,"Microsoft.MicrosoftSolitaireCollection","Microsoft.Microsoft3DViewer","Microsoft.Getstarted","Microsoft.SkypeApp",
"Microsoft.Advertising.Xaml","Microsoft.OneConnect")

foreach ($w in $winApps) {
    Get-AppxPackage $w -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $w | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

$uninstallAppsHK = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore")

$uninstallAppsIP = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsConsumerFeatures",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore","DisableStoreApps",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore","AutoDownload",4),
@("HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore","DisableOSUpgrade",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore","RemoveWindowsStore",1)

foreach ($uninstall in $uninstallAppsHK) {Make-HiveKey $uninstall}
foreach ($uninstall in $uninstallAppsIP) {Set-ItemProperty -Path $uninstall[0] -Name $uninstall[1] -Value $uninstall[2] -ErrorAction SilentlyContinue}

# Windows Update Fix
$winUdateHK = @("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU","HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")

$winUpdateIP = @("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU","NoAutoUpdate",1),
@("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions",2),
@("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU","ScheduledInstallDay",0),
@("HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU","ScheduledInstallTime",3),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","DeferFeatureUpdates",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","DeferQualityUpdates",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AutoInstallMinorUpdates",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AlwaysAutoRebootAtScheduledTime",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","DetectionFrequencyEnabled",0),
@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","DODownloadMode",0),
@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","UserOptedInOOBE",0),
@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","DOAllowVPNPeerCaching",0)

foreach ($winUp in $winUdateHK) {Make-HiveKey $winUp}
foreach ($winUp in $winUpdateIP) {Set-ItemProperty -Path $winUp[0] -Name $winUp[1] -Value $winUp[2]}

# User Settings
$userSettingsHK = @("HKCU:\Control Panel\International\User Profile","HKCU:\SOFTWARE\Microsoft\Input\TIPC",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo","HKCU:\SOFTWARE\Microsoft\InputPersonalization",
"HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}",
"HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled",
"HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration","HKCU:\SOFTWARE\Microsoft\Siuf\Rules",
"HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}",
"HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer","HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps","HKCU:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors",
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\HelpSvc",
"HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting","HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting",
"HKLM:\SOFTWARE\Policies\Microsoft\Messenger\Client","HKLM:\SOFTWARE\Policies\SQMClient\Windows",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy","HKCU:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")

$userSettingsIP = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR","AllowgameDVR",0),
@("HKLM:\System\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp",1),@("HKLM:\System\CurrentControlSet\Control\Terminal Server","fDenyTSConnections",0),
@("HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp","UserAuthentication",0),@("HKCU:\Control Panel\Accessibility\StickyKeys","Flags","506"),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","HideFileExt",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu","{59031a47-3f72-44a7-89c5-5595fe6b30ee}",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{59031a47-3f72-44a7-89c5-5595fe6b30ee}",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer","ShowRunasDifferentUserinStart",1),
@("HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting","Value",0),
@("HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots","Value",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search","BingSearchEnabled",0),@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules\","PeriodInNanoSeconds",0),
@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules\","NumberOfSIUFInPeriod",0),
@("HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}","SensorPermissionState",0),
@("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection",1),@("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection",1),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo","Enabled",0),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost","EnableWebContentEvaluation",0),@("HKCU:\SOFTWARE\Microsoft\Input\TIPC","Enabled",0),
@("HKCU:\Control Panel\International\User Profile","HttpAcceptLanguageOptOut",1),@("HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service","Configuration",0),
@("HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}","SensorPermissionState",0),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global","{BFA794E4-F964-4FDB-90F6-51056BFE4B44}","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}","Value","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}","Value","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}","Value","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}","Value","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}","Value","Deny"),
@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}","Value","Deny"),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled","Type","LooselyCoupled"),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled","Value","Deny"),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled","InitialAppValue","Unspecified"),
@("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Privacy\DisableAdvertisingId","value",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy","LetAppsGetDiagnosticInfo",0),
@("HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\AppPrivacy","LetAppsGetDiagnosticInfo",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}","Value","Deny"),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}","Value","Deny"),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps","AutoDownloadAndUpdateMapData",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps","AllowUntriggeresNetworkTrafficOnSettingsPage",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableLocation",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableLocationScripting",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableSensors",1),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoAutoUpdate",1),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoUseStoreOpenWith",1),@("HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\HelpSvc","Headlines",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting","DoReport",0),@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting","Disabled",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Messenger\Client","CEIP",1),@("HKLM:\SOFTWARE\Policies\SQMClient\Windows","CEIPEnable",1),
@("HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System","LocalAccountTokenFilterPolicy",1),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","Start_TrackProgs",0),
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications","GlobalUserDisabled",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy","LetAppsGetDiagnosticInfo",2),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableWindowsLocationProvider",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableLocation",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableLocationScripting",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableSensors",1),
@("HKCU:\SOTWARE\Policies\Microsoft\Windows\Explorer","NoBalloonFeatureAdvertisements",1),
@("HKCU:\SOTWARE\Policies\Microsoft\Windows\Explorer","ShowWindowsStoreAppsOnTaskbar",2)

foreach ($user in $userSettingsHK) {Make-HiveKey $user}
foreach ($user in $userSettingsIP) {Set-ItemProperty -Path $user[0] -Name $user[1] -Value $user[2]}

$groups = @("Accessibility","AppSync","BrowserSettings","Credentials","DesktopTheme",
"Language","PackageState","Personalization","StartLayout","Windows")

foreach ($group in $groups) {
    Make-HiveKey "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\$group"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\$group" -Name "Enabled" -Value 0
}

foreach ($item in (ls "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -ErrorAction SilentlyContinue)) {
    Make-HiveKey ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\" + $item.PSChildName)
    Set-ItemProperty -Path ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\" + $item.PSChildName) -Name "Disabled" -Value 1
}

foreach ($key in (Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global")) {
    if ($key.PSChildName -EQ "LooselyCoupled") {
        continue
    }
    Set-ItemProperty ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\" + $key.PSChildName) -Name "Type" -Value "InterfaceClass"
    Set-ItemProperty ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\" + $key.PSChildName) -Name "Value" -Value "Deny"
    Set-ItemProperty ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\" + $key.PSChildName) -Name "InitialAppValue" -Value "Unspecified"
}

$user = New-Object System.Security.Principal.NTAccount($ENV:USERNAME)
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]).value
Make-HiveKey ("HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" + $sid)
Set-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" + $sid) -Name "FeatureStates" -Value 0x33c
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" -Name "WiFiSenseCredShared" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" -Name "WiFiSenseOpen" -Value 0

$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl" -ErrorAction SilentlyContinue) {
    Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
}
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

if (Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue) {
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
}

bcdedit.exe /set "{current}" bootmenupolicy legacy

Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart

foreach ($item in (Get-ChildItem "HKU:\")) {
    if (Test-Path -Path ("HKU:\" + $item.PSChildName + "\System\GameConfigStore")){
        Set-ItemProperty -Path ("HKU:\" + $item.PSChildName + "\System\GameConfigStore") -Name "GameDVR_FSEBehavior" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path ("HKU:\" + $item.PSChildName + "\System\GameConfigStore") -Name "GameDVR_FSEBehaviorMode" -Value 0 -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\GameBar")){
        Set-ItemProperty -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\GameBar") -Name "UseNexusForGameBarEnabled" -Value 0 -ErrorAction SilentlyContinue
    }
}

foreach ($item in (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Privacy")) {
    if (Test-Path -Path ("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Privacy\" + $item.PSChildName)){
        Set-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Privacy\" + $item.PSChildName) -Name "value" -Value 0 -ErrorAction SilentlyContinue
    }
}

# Internet Settings
$netSettingsHK = @("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main",
"HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main","HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation",
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\CommandBar","HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation"
"HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation","HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\CommandBar",
"HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings",
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main")

$netSettingsIP = @("HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main","Start Page",""),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer",""),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyEnable",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main","DisableFirstRunCustomize",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main","GoToIntranetSiteForSingleWordEntry",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main","GoToIntranetSiteForSingleWordEntry",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation","MSCompatibiliyMode",0),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation","MSCompatibiliyMode",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\CommandBar","ShowCompatibilityViewButton",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\CommandBar","ShowCompatibilityViewButton",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","DisableSiteListEditing",0),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","DisableSiteListEditing",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","AllSitesCompatibilityMode",0),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","AllSitesCompatibilityMode",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","IntranetCompatibilityMode",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Browser Emulation","IntranetCompatibilityMode",1),
@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableSoftLanding",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableThirdPartySuggestions",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","ConfigurewindowsSpotlight",2),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableTailoredExperiencesWithDiagnosticData",1),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsSpotlightFeatures",1)

foreach ($net in $netSettingsHK) {Make-HiveKey $net}
foreach ($net in $netSettingsIP) {Set-ItemProperty -Path $net[0]  -Name $net[1] -Value $net[2]}

# Telemetry
$telHK = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP",
"HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")

$telIP = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","AllowTelemetry",0),
@("HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP","CEIPEnable",0),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","AllowTelemetry",0),
@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","AllowTelemetry",1)

foreach ($tel in $telHK) {Make-HiveKey $tel}
foreach ($tel in $telIP) {Set-ItemProperty -Path $tel[0]  -Name $tel[1] -Value $tel[2]}

# Cortana
$cortanaHK = @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","HKCU:\Software\Microsoft\Personalization\Settings",
"HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")

$cortanaIP = @("HKLM:\SOFTWARE\Microsoft\Windows Search","AllowCortana",0),@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana",0),
@("HKCU:\Software\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy",0),@("HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts",0),
@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","DeviceHistoryEnabled",0),@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","VoiceShortcut",0),
@("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\AboveLock\AllowCortanaAboveLock","value",0),
@("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana","value",0),@("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\AllowCloudSearch","value",0),
@("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Search\AllowSearchToUseLocation","value",0)

foreach ($cort in $cortanaHK) {Make-HiveKey $cort}
foreach ($cort in $tcortanaIP) {Set-ItemProperty -Path $cort[0]  -Name $cort[1] -Value $cort[2]}

foreach ($item in (Get-ChildItem "HKU:\")) {
    if (Test-Path -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\Windows\CurrentVersion\Search")){
        $searchIP = @("DeviceHistoryEnabled",0),@("VoiceShortcut",0)
        foreach ($search in $searchIP) {
            Set-ItemProperty -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\Windows\CurrentVersion\Search") -Name $search[0] -Value $search[1]
        }
    }
}

foreach ($item in (Get-ChildItem "HKU:\")) {
    Make-HiveKey ("HKU:\" + $item.PSChildName + "\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")
    if (Test-Path -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")){
        Set-ItemProperty -Path ("HKU:\" + $item.PSChildName + "\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People") -Name "PeopleBand" -Value 0
    }
}

# BitLocker
if (Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    $blv = Get-BitLockerVolume -ErrorAction SilentlyContinue
    Disable-BitLocker -MountPoint $blv -ErrorAction SilentlyContinue
}
Remove-Item -Path "HKCR:\Drive\shell\*bde*" -Recurse -Force

# Defender
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\" -Name "DisableAntiSpyware" -Value 1 -ErrorAction SilentlyContinue

# Remove Services
$services = @('XboxNetApiSvc','XblGameSave','XblAuthManager','OneSyncSvc_47eef7','Mapsbroker','WalletService','WinDefend','WMPNetworkSvc','lfsvc','HomeGroupProvider','HomeGroupListener','DiagTrack')
foreach ($s in $services) {
    if (Get-Service -Name $s -ErrorAction SilentlyContinue) {
        Get-Service -Name $s | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
        (gwmi -Class Win32_Service -Filter "Name='$s'").delete()
    }
}

# CleanUp Machine
Remove-Item -Recurse ./*.lnk -Force
$shell = New-Object -ComObject Shell.Application 
$recycleBin = $shell.Namespace(0xA)
$temp = get-ChildItem "env:\TEMP"
$temp2 = $temp.Value

Remove-Item -Recurse  "$temp2\*" -Force -Verbose -ErrorAction SilentlyContinue
$recycleBin.items() | ForEach-Object { remove-item $_.path -Recurse -Confirm:$false} -ErrorAction SilentlyContinue
Remove-Item -Recurse "C:\Windows\Temp\*" -Force -ErrorAction SilentlyContinue

$cleanHK = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup',
'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files')

foreach ($clean in $cleanHK) {Make-HiveKey $clean}

Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name "StateFlags0001" -ErrorAction SilentlyContinue | Remove-ItemProperty -Name "StateFlags0001" -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Name "StateFlags0001" -Value 2
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name "StateFlags0001" -Value 2
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait

$regpath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\uninstall"
Get-childItem $regpath | %  {
    $keypath = $_.pschildname
    $key = Get-Itemproperty $regpath\$keypath
    if ($key.DisplayName -match "VMware Tools") {
        $VMwareToolsGUID = $keypath
    }
    MsiExec.exe /x $VMwareToolsGUID  /qn /norestart
}

Stop-Process -ProcessName explorer

Restart-Computer -Force

# Sysprep
# C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown

# Capture Image
# net use z: <Destination>\1709 /user:<User>
# D:
# dism /Capture-Image /ImageFile:z:\install.wim /capturedir:d:\ /name:W10X64_1709

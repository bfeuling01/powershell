Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

$shareLoc = ""
$customWim = ""
New-PSDrive -Name "DS003" -PSProvider MDTProvider -Root $shareLoc -Description "MDT Deployment Share" -Force -Verbose | add-MDTPersistentDrive -Verbose

# Adding Folders
## Applications
New-Item -Path "DS003:\Applications" -Enable "True" -Name "Standard" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications" -Enable "True" -Name "Hardware" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications\Hardware" -Enable "True" -Name "Dell" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications\Hardware" -Enable "True" -Name "Toshiba" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications" -Enable "True" -Name "Region Specific" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications\Region Specific" -Enable "True" -Name "NAmerica" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Applications\Region Specific" -Enable "True" -Name "Eurasia" -Comments "" -ItemType "folder" -Verbose

## Win10 Drivers
New-Item -Path "DS003:\Out-of-Box Drivers" -Enable "True" -Name "Windows10" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers" -Enable "True" -Name "WinPE" -Comments "" -ItemType "folder" -Verbose

### Dell Drivers
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10" -Enable "True" -Name "Dell Inc." -Comments "" -ItemType "folder" -Verbose
$dellModels = @(<Model Names>, <As Strings>, <Comma Seperated>)

foreach ($dell in $dellModels) {
    New-Item -Path "DS003:\Out-of-Box Drivers\Windows10\Dell Inc." -Enable "True" -Name $dell -Comments "" -ItemType "folder" -Verbose
}

### Toshiba Drivers
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10" -Enable "True" -Name "Toshiba" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10\Toshiba" -Enable "True" -Name "Portege R930" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10\Toshiba" -Enable "True" -Name "Portege Z930" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10\Toshiba" -Enable "True" -Name "Portege R30-A" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers\Windows10\Toshiba" -Enable "True" -Name "Portege Z30-A" -Comments "" -ItemType "folder" -Verbose

## WinPE Drivers
New-Item -Path "DS003:\Out-of-Box Drivers" -Enable "True" -Name "WinPE" -Comments "" -ItemType "folder" -Verbose
New-Item -Path "DS003:\Out-of-Box Drivers\WinPE" -Enable "True" -Name "WinPE10" -Comments "" -ItemType "folder" -Verbose

# Adding Applications
import-MDTApplication -path "DS003:\Applications\Standard" -Enable "True" -Name "VPN" -ShortName "VPN" -Version "" -Publisher "" -Language "" -CommandLine "msiexec /i vpn.msi /quiet /qn /norestart" -WorkingDirectory ".\Applications\VPN" -ApplicationSourcePath "<Source>\Applications\VPN" -DestinationFolder "VPN" -Verbose
import-MDTApplication -path "DS003:\Applications\Standard" -Enable "True" -Name "SCCM" -ShortName "SCCM" -Version "" -Publisher "" -Language "" -CommandLine "Install.CMD" -WorkingDirectory ".\Applications\SCCM" -ApplicationSourcePath "<Source>\Applications\SCCM" -DestinationFolder "SCCM" -Verbose
import-MDTApplication -path "DS003:\Applications\Standard" -Enable "True" -Name "Encryption" -ShortName "Encryption" -Version "" -Publisher "" -Language "" -CommandLine "msiexec /i Encryption.msi /quiet" -WorkingDirectory ".\Applications\Encryption" -ApplicationSourcePath "<Source>\Applications\Encryption" -DestinationFolder "Encryption" -Verbose
import-MDTApplication -Path "DS003:\Applications\Standard" -Enable "True" -Name "AVAdmin" -ShortName "AVAdmin" -Version "" -Publisher "" -Language "" -CommandLine "AdminAV.exe" -WorkingDirectory ".\Applications\AVAdmin" -ApplicationSourcePath "<Source>\Applications\AdminAV" -DestinationFolder "AVAdmin" -Verbose
Import-MDTApplication -Path "DS003:\Applications\Region Specific\NAmerica" -Enable "True" -Name "InternEncryption" -ShortName "InternEncryption" -Version "" -Publisher "" -Language "" -CommandLine "msiexec /i eps.msi /quiet" -WorkingDirectory ".\Applications\InternEncryption" -ApplicationSourcePath "<Source>\Applications\Checkpoint Intern Package" -DestinationFolder "InternEncryption" -Verbose
Import-MDTApplication -Path "DS003:\Applications\Hardware\Dell" -Enable "True" -Name "DellCV" -ShortName "DellCV" -Version "" -Publisher "" -Language "" -CommandLine "CVHCI64.exe /s /v /qn /norestart" -WorkingDirectory ".\Applications\DellCV" -ApplicationSourcePath "<Source>\Applications\DCV" -DestinationFolder "DellCV" -Verbose
Import-MDTApplication -Path "DS003:\Applications\Hardware\Dell" -Enable "True" -Name "DellThunderbolt" -ShortName "DellThunderbolt" -Version "" -Publisher "" -Language "" -CommandLine "Network_Driver_169KR_WN32_1.0.0.7_A03.EXE /s" -WorkingDirectory ".\Applications\DellThunderbolt" -ApplicationSourcePath "<Source>\Applications\DellThunderbolt" -DestinationFolder "DellThunderbolt" -Verbose
Import-MDTApplication -Path "DS003:\Applications\Hardware\Toshiba" -Enable "True" -Name "Toshiba Bluetooth Stack" -ShortName "Toshiba Bluetooth Stack" -Version "" -Publisher "" -Language "" -CommandLine "setup.exe /s /v/qn" -WorkingDirectory ".\Applications\Toshiba Bluetooth Stack" -ApplicationSourcePath "<Source>\Applications\ToshibaBluetoothStack" -DestinationFolder "Toshiba Bluetooth Stack" -Verbose
Import-MDTApplication -Path "DS003:\Applications\Hardware\Toshiba" -Enable "True" -Name "Toshiba Value Added Package" -ShortName "Toshiba Value Added Package" -Version "" -Publisher "" -Language "" -CommandLine "setup.exe /s /all" -WorkingDirectory ".\Applications\Toshiba Value Added Package" -ApplicationSourcePath "<Source>\Applications\Toshiba_Value_Added_Package" -DestinationFolder "Toshiba Value Added Package" -Verbose

# Adding Operating System
Import-mdtoperatingsystem -Path "DS003:\Operating Systems" -SourceFile $noOfficeWim -DestinationFolder "install" -Verbose
Import-mdtoperatingsystem -Path "DS003:\Operating Systems" -SourceFile $officeWim -DestinationFolder "install2" -Verbose

# Selection Profile
## WinPE Profile
New-Item -Path "DS003:\Selection Profiles" -Enable "True" -Name "WinPE" -Comments "All WinPE Drivers" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE`" /></SelectionProfile>" -ReadOnly "False" -Verbose

## Offline Media
New-Item -Path "DS003:\Selection Profiles" -Enable "True" -Name "Windows 10 Offline Media" -Comments "For Windows 10 Offline Media" -Definition "<SelectionProfile><Include path=`"DS003:\`" /></SelectionProfile>" -ReadOnly "False" -Verbose

# Task Sequence
## Win10
Import-MdtTaskSequence -Path "DS003:\Task Sequences" -Name "Windows 10x64 Pro" -Template "Client.xml" -Comments "Install Windows 10 64bit" -ID "W10X64" -Version "1.0" -OperatingSystemPath "DS003:\Operating Systems\install.wim" -FullName "" -OrgName "" -HomePage "" -Verbose

# Add Drivers
$dellLatModels = @(<Latitude Models>, <As Strings>, <Comma Seperated>)

$dellOptiModels = @(<Optiplex Models>, <As Strings>, <Comma Seperated>)

$dellPrecModels = @(<Precision Models>, <As Strings>, <Comma Seperated>)

foreach ($lat in $dellLatModels) {
    "*********************************************************$lat EMPTYING********************************************"
    Remove-Item -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$lat IMPORT********************************************"
    Import-MdtDriver -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat" -SourcePath "<Source>\Dell\Latitude $lat" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($opti in $dellOptiModels) {
    "*********************************************************$opti EMPTYING********************************************"
    Remove-Item -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$opti IMPORT********************************************"
    Import-MdtDriver -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti" -SourcePath "<Source>\Dell\Optiplex $opti" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($prec in $dellPrecModels) {
    if ($prec -eq "T3620") {
        "*********************************************************$prec EMPTYING********************************************"
        Remove-Item -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620" -SourcePath "<Source>\Dell\Precision Tower 3620" -Verbose
        Start-Sleep -Seconds 2
    } else {
        "*********************************************************$prec EMPTY********************************************"
        Remove-Item -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "DS002:\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec" -SourcePath "<Source>\Dell\Precision $prec" -Verbose
        Start-Sleep -Seconds 2
    }
}

# Update share
Update-MDTDeploymentShare -Path "DS003:" -Verbose

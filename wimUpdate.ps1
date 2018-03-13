Import-Module BitsTransfer
$wim = "install.wim"
$newWim = "<Source>\$wim"
$origWim = "<Source>\$wim"
$update = "<Update>.msu"
$mount = "C:\mount"

$winApps = @("Microsoft.GetHelp_10.1706.1811.0_neutral_~_8wekyb3d8bbwe","Microsoft.MicrosoftOfficeHub_2017.715.118.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.MicrosoftSolitaireCollection_3.17.8162.0_neutral_~_8wekyb3d8bbwe","Microsoft.OneConnect_3.1708.2224.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.Print3D_1.0.2422.0_neutral_~_8wekyb3d8bbwe","Microsoft.SkypeApp_11.18.596.0_neutral_~_kzf8qxf38zg5c",
"Microsoft.StorePurchaseApp_11706.1707.7104.0_neutral_~_8wekyb3d8bbwe","Microsoft.Wallet_1.0.16328.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.WindowsFeedbackHub_1.1705.2121.0_neutral_~_8wekyb3d8bbwe","Microsoft.WindowsStore_11706.1002.94.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.Xbox.TCUI_1.8.24001.0_neutral_~_8wekyb3d8bbwe","Microsoft.XboxApp_31.32.16002.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.XboxGameOverlay_1.20.25002.0_neutral_~_8wekyb3d8bbwe","Microsoft.XboxIdentityProvider_2017.605.1240.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.XboxSpeechToTextOverlay_1.17.29001.0_neutral_~_8wekyb3d8bbwe","Microsoft.ZuneMusic_2019.17063.24021.0_neutral_~_8wekyb3d8bbwe",
"Microsoft.ZuneVideo_2019.17063.24021.0_neutral_~_8wekyb3d8bbwe")

if (!(Test-Path $mount)) {
    New-Item $mount -ItemType Directory
}

Start-BitsTransfer -Source $origWim -Destination $newWim

Mount-WindowsImage -ImagePath $newWim -Index 1 -Path $mount
Add-WindowsPackage -Path $mount -PackagePath $update
foreach ($w in $winApps) {
    Remove-AppxProvisionedPackage -Path $mount -PackageName $w
    Start-Sleep -Seconds 1
}
Save-WindowsImage -Path $mount
Dismount-WindowsImage -Path $mount -Save

Remove-Item -Path $mount -Recurse -Force

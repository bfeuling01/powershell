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

$ieRegKey = @("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingmaps",
"HKCU:SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingmoney","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingnews",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingsports","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingweather",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\calculator","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\maps",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft.windows.camera",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft.windows.camera.picker",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft.windows.photos.crop",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft.windows.photos.picker",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoftmusic","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoftvideo",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mk","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-actioncenter",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-call","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-chat",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-clock","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-contact-support",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-cxh","\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-drive-to",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-get-started","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-ipmessaging",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-ipmessaging-name","HKCU:\\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-people",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-phone-companion","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-photos",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-unistore-email","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-voip-call",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-voip-video","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-walk-to",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-wcrv","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-windows-store",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-windows-store2","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-wpc",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ms-wpdrmv","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\msnmoney",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\msnnews","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\msnsports",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\msnweather","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mswindowsmusic",
"HKCU:HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mswindowsvideo",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\onenote","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\onenote-cmd",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\outlookcal","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\outlookmail",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\read","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\skypepage",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\skypesettings","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\skypesetup",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\windows-feedback","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xbls",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xbox","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xbox-tcui",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xboxgames","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\res",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xboxliveapp-1297287741",
"HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\xboxmusic","HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\zune")

$ieRegSettings = @("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingmaps\UserChoice","Hash","m3VgSnMjShQ="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\bingmaps\UserChoice","ProgId","AppXp9gkwccvk6fa6yyfq3tmsk8ws2nprk1p"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","Hash","gHWzGroUvNI="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","IE.FTP"),
@("\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice","Hash","5EsGSwlWsk0="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","IE.HTTP"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice","Hash","DisableOSUpgrade"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","IE.HTTPS"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge\UserChoice","Hash","18fXwycrO10="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","AppX7rm9drdg8sk7vqndwj3sdjw11x96jc0y"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mk\UserChoice","Hash","C1FBnogv0L8="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","IE.HTTP"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mswindowsmusic\UserChoice","Hash","EvtoJp4Lq9M="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","AppXtggqqtcfspt6ks3fjzyfppwc05yxwtwy"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\mswindowsvideo\UserChoice","Hash","s6tWDNbKQ1g="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","AppX6w6n4f8xch1s3vzwf3af6bfe88qhxbza"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\read\UserChoice","Hash","oTTKwdHDqf4="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","AppXe862j7twqs4aww05211jaakwxyfjx4da"),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\res\UserChoice","Hash","kkM/KHZyOfc="),
@("HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice","ProgId","IE.HTTP")

foreach ($ieKey in $ieRegKey) {Make-HiveKey $ieKey}
foreach ($ieSetting in $ieRegSettings) {Set-ItemProperty -Path $ieSetting[0] -Name $ieSetting[1] -Value $ieSetting[2] -ErrorAction SilentlyContinue}

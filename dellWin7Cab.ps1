Import-Module BitsTransfer
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
$search="https://www.google.com/search?q="

New-PSDrive -Name "DS003" -PSProvider MDTProvider -Root ""

$dellLatModels = @(<Latitude Models>, <As Strings>, <Comma Seperated>)

$dellOptiModels = @(<Latitude Models>, <As Strings>, <Comma Seperated>)

$dellPrecModels = @(<Latitude Models>, <As Strings>, <Comma Seperated>)

Write-Host "The following Latitude models are being covered" -BackgroundColor "yellow" -ForegroundColor "black"
foreach ($lat in $dellLatModels) {
    Write-Host $lat
}

Write-Host "The following Optiplex models are being covered" -BackgroundColor "yellow" -ForegroundColor "black"
foreach ($opt in $dellOptiModels) {
    Write-Host $opt
}

Write-Host "The following Precision models are being covered" -BackgroundColor "yellow" -ForegroundColor "black"
foreach ($pre in $dellPrecModels) {
    Write-Host $pre
}

# Download Drivers
foreach ($lat in $dellLatModels) {
    Write-Host "  *********************************************************$lat CAB DOWNLOAD********************************************  " -background "yellow" -foreground "black"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Latitude+$lat+Windows+7+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    Write-Host "Dell Link: $dellSourceLink"
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href | Select -First 1
    Write-Host "Download Link: $downloadLink"
    Remove-Item "<Destination>\Dell\Latitude $lat\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Latitude $lat\$lat.cab"
    (ls "<Destination>\Dell\Latitude $lat\$lat.cab").LastWriteTime = Get-Date
}

foreach ($opti in $dellOptiModels) {
    Write-Host "  *********************************************************$opti CAB DOWNLOAD********************************************  " -background "yellow" -foreground "black"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Optiplex+$opti+Windows+7+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    Write-Host "Download Link: $dellSourceLink"
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href | Select -First 1
    Write-Host "Download Link: $downloadLink"
    Remove-Item "<Destination>\Dell\Optiplex $opti\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Optiplex $opti\$opti.cab"
    (ls "<Destination>\Dell\Optiplex $opti\$opti.cab").LastWriteTime = Get-Date
}

foreach ($prec in $dellPrecModels) {
    Write-Host "  *********************************************************$prec CAB DOWNLOAD********************************************  " -background "yellow" -foreground "black"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Precision+$prec+Windows+7+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    Write-Host "Download Link: $dellSourceLink"
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href | Select -First 1
    if ($prec -eq "3620" -or $prec -eq "7910") {
        Remove-Item "<Destination>\Dell\Precision Tower $prec\*" -Recurse
        Write-Host "Download Link: $downloadLink"
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Precision Tower $prec\$prec.cab"
        (ls "<Destination>\Dell\Precision Tower $prec\$prec.cab").LastWriteTime = Get-Date
    } elseif ($prec -eq "T3500") {
        Remove-Item "<Destination>\Dell\Precision Workstation $prec\*" -Recurse
        Write-Host "Download Link: $downloadLink"
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Precision Workstation $prec\$prec.cab"
        (ls "<Destination>\Dell\Precision Workstation $prec\$prec.cab").LastWriteTime = Get-Date
    } else {
        Remove-Item "<Destination>\Dell\Precision $prec\*" -Recurse
        Write-Host "Download Link: $downloadLink"
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Precision $prec\$prec.cab"
        (ls "<Destination>\Dell\Precision $prec\$prec.cab").LastWriteTime = Get-Date
    }
}

# Adding Drivers
foreach ($lat in $dellLatModels) {
    Write-Host "  *********************************************************$lat CAB IMPORT********************************************  " -background "yellow" -foreground "black"
    Import-MdtDriver -Path "DS003:\Out-of-Box Drivers\Windows7\Dell Inc.\Latitude $lat" -SourcePath "<Source>\Dell\Latitude $lat" -Verbose
    Start-Sleep -Seconds 2
    Remove-Item <User Home Folder>\AppData\Local\Temp\* -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}

foreach ($opti in $dellOptiModels) {
    Write-Host "  *********************************************************$opti CAB IMPORT********************************************  " -background "yellow" -foreground "black"
    Import-MdtDriver -Path "DS003:\Out-of-Box Drivers\Windows7\Dell Inc.\Optiplex $opti" -SourcePath "<Source>\Dell\Optiplex $opti" -Verbose
    Start-Sleep -Seconds 2
    Remove-Item <User Home Folder>\Local\Temp\* -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}

foreach ($prec in $dellPrecModels) {
    if ($prec -eq "3620" -or $prec -eq "7910") {
        Write-Host "  *********************************************************$prec CAB IMPORT********************************************  " -background "yellow" -foreground "black"
        Import-MdtDriver -Path "DS003:\Out-of-Box Drivers\Windows7\Dell Inc.\Precision Tower $prec" -SourcePath "<Source>\Dell\Precision Tower $prec" -Verbose
        Start-Sleep -Seconds 2
        Remove-Item <User Home Folder>\AppData\Local\Temp\* -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    } elseif ($prec -eq "T3500") {
        Write-Host "  *********************************************************$prec CAB IMPORT********************************************  " -background "yellow" -foreground "black"
        Import-MdtDriver -Path "DS003:\Out-of-Box Drivers\Windows7\Dell Inc.\Precision WorkStation $prec" -SourcePath "<Source>\Dell\Precision Workstation $prec" -Verbose
        Start-Sleep -Seconds 2
        Remove-Item <User Home Folder>\AppData\Local\Temp\* -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    } else {
        Write-Host "  *********************************************************$prec CAB IMPORT********************************************  " -background "yellow" -foreground "black"
        Import-MdtDriver -Path "DS003:\Out-of-Box Drivers\Windows7\Dell Inc.\Precision $prec" -SourcePath "<Source>\Dell\Precision $prec" -Verbose
        Start-Sleep -Seconds 2
        Remove-Item <User Home Folder>\AppData\Local\Temp\* -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
}

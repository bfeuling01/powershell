Import-Module BitsTransfer
$search="https://www.google.com/search?q="

$dellLatModels = @("E6430","E6530","E6540","E7240","E7440","E6230","E6330","E5440","E7450","E7250",
"E5250","E5450","E5470","E5570","E7270","E7470","7275","7370","5580","7480","7280","5289","5285","5480")

$dellOptiModels = @("7010","7020","3020M","5040","3040","5050","3050")

$dellPrecModels = @("T1650","T1700","M2800","M3800","M4800","7510","T3620","7710","5510","5520")

# Download Drivers
foreach ($lat in $dellLatModels) {
    "*********************************************************$lat DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Latitude+$lat+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    Remove-Item "<Destination>\MDT\win10Drivers\Dell\Latitude $lat\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\MDT\win10Drivers\Dell\Latitude $lat\$lat.cab"
}

foreach ($opti in $dellOptiModels) {
    "*********************************************************$opti DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Optiplex+$opti+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    Remove-Item "<Destination>\MDT\win10Drivers\Dell\Optiplex $opti\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\MDT\win10Drivers\Dell\Optiplex $opti\$opti.cab"
}

foreach ($prec in $dellPrecModels) {
    "*********************************************************$prec DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Precision+$prec+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    if ($prec -eq "T3620") {
        Remove-Item "<Destination>\MDT\win10Drivers\Dell\Precision Tower 3620\*" -Recurse
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\MDT\win10Drivers\Dell\Precision Tower 3620\$prec.cab"
    } else {
        Remove-Item "<Destination>\MDT\win10Drivers\Dell\Precision $prec\*" -Recurse
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\MDT\win10Drivers\Dell\Precision $prec\$prec.cab"
    }
}

# Adding Drivers
## Dell Drivers
foreach ($lat in $dellLatModels) {
    "*********************************************************$lat EMPTYING********************************************"
    Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$lat IMPORT********************************************"
    Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat" -SourcePath "<Destination>\MDT\win10Drivers\Dell\Latitude $lat" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($opti in $dellOptiModels) {
    "*********************************************************$opti EMPTYING********************************************"
    Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$opti IMPORT********************************************"
    Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti" -SourcePath "<Destination>\MDT\win10Drivers\Dell\Optiplex $opti" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($prec in $dellPrecModels) {
    if ($prec -eq "T3620") {
        "*********************************************************$prec EMPTYING********************************************"
        Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620" -SourcePath "<Destination>\MDT\win10Drivers\Dell\Precision Tower 3620" -Verbose
        Start-Sleep -Seconds 2
    } else {
        "*********************************************************$prec EMPTY********************************************"
        Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec" -SourcePath "<Destination>\MDT\win10Drivers\Dell\Precision $prec" -Verbose
        Start-Sleep -Seconds 2
    }
}

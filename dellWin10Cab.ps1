Import-Module BitsTransfer
$search="https://www.google.com/search?q="

$dellLatModels = @(<Latitude Models>, <As Strings>, <Seperated by commas>)

$dellOptiModels = @(<Optiplex Models>, <As Strings>, <Seperated by commas>)

$dellPrecModels = @(<Precision Models>, <As Strings>, <Seperated by commas>)

# Download Drivers
foreach ($lat in $dellLatModels) {
    "*********************************************************$lat DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Latitude+$lat+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    Remove-Item "<Destination>\Dell\Latitude $lat\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Latitude $lat\$lat.cab"
}

foreach ($opti in $dellOptiModels) {
    "*********************************************************$opti DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Optiplex+$opti+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    Remove-Item "<Destination>\Dell\Optiplex $opti\*" -Recurse
    Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Optiplex $opti\$opti.cab"
}

foreach ($prec in $dellPrecModels) {
    "*********************************************************$prec DOWNLOAD********************************************"
    $dellSourceLink = (((Invoke-WebRequest -Uri ($search + "Dell+Precision+$prec+Windows+10+Cab+Download")).Links | Where {$_.href -match "en.community.dell"} | Select href -First 1).href).Substring(7)
    $dellSourceLink = ($dellSourceLink -split "&amp")[0]
    $downloadLink = ((Invoke-WebRequest -Uri $dellSourceLink).Links | Where {$_.href -like "*.cab*"}).href
    if ($prec -eq "T3620") {
        Remove-Item "<Destination>\Dell\Precision Tower 3620\*" -Recurse
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Precision Tower 3620\$prec.cab"
    } else {
        Remove-Item "<Destination>\Dell\Precision $prec\*" -Recurse
        Start-BitsTransfer -Source $downloadLink -Destination "<Destination>\Dell\Precision $prec\$prec.cab"
    }
}

# Adding Drivers
## Dell Drivers
foreach ($lat in $dellLatModels) {
    "*********************************************************$lat EMPTYING********************************************"
    Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$lat IMPORT********************************************"
    Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Latitude $lat" -SourcePath "<Destination>\Dell\Latitude $lat" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($opti in $dellOptiModels) {
    "*********************************************************$opti EMPTYING********************************************"
    Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti\*" -Recurse -Force -Verbose
    Start-Sleep -Seconds 2
    "*********************************************************$opti IMPORT********************************************"
    Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Optiplex $opti" -SourcePath "<Destination>\Dell\Optiplex $opti" -Verbose
    Start-Sleep -Seconds 2
}

foreach ($prec in $dellPrecModels) {
    if ($prec -eq "T3620") {
        "*********************************************************$prec EMPTYING********************************************"
        Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision Tower 3620" -SourcePath "<Destination>\Dell\Precision Tower 3620" -Verbose
        Start-Sleep -Seconds 2
    } else {
        "*********************************************************$prec EMPTY********************************************"
        Remove-Item -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec\*" -Recurse -Force -Verbose
        Start-Sleep -Seconds 2
        "*********************************************************$prec IMPORT********************************************"
        Import-MdtDriver -Path "<MDTLocation>\Out-of-Box Drivers\Windows10\Dell Inc.\Precision $prec" -SourcePath "<Destination>\Dell\Precision $prec" -Verbose
        Start-Sleep -Seconds 2
    }
}

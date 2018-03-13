Import-Module BitsTransfer
$month = (Get-Date -Format M).Split(" ")[0]
$search="https://www.google.com/search?q=itechtics+Windows+10+1709+$month+Cumulative+update+download"

$downloadSite = (((Invoke-WebRequest -Uri $search).Links | Where {$_.href -match "www.itechtics.com"} | Select href -First 1).href).Substring(7)
$downloadSite = ($downloadSite -split "&amp")[0]
Start-BitsTransfer -Source ((Invoke-WebRequest -Uri $downloadSite -Verbose).Links | Where {$_.href -match "download.windowsupdate.com"} | Select href -First 1).href -Destination "<Destination>\1709$month.msu" -Verbose

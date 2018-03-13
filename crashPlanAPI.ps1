[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cpURL = ""
$initUri = "$cpURL/api/DeviceBackupReport?pgSize=30000"
$username = ""
$password = ""
$credPair = "$($username):$($password)"
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credPair))
$headers = @{ Authorization = "Basic $auth" }
$path = "<Output Path>"

$computer = (Invoke-RestMethod -Uri $initUri -Method Get -Headers $headers -UseBasicParsing).data

$computerID = @()
foreach ($comp in $computer) {
    $computerID += $comp.deviceUid
}

$computerID = $computerID | select -Unique

$compInfo = @()
foreach ($computer in $computerID) {
    $compUri = "$cpURL/api/DeviceBackupReport?deviceUid=$computer"
    $compIDUri = "$cpURL/api/Computer?guid=$computer"
    $computerFull = (Invoke-RestMethod -Uri $compUri -Method Get -Headers $headers -UseBasicParsing).data[0]
    $compID = (((Invoke-RestMethod -Uri $compIDUri -Method Get -Headers $headers -UseBasicParsing).data).computers).computerId

    $lcd = (($computerFull.lastConnectedDate) -split "T")[0]
    if ($lcd -eq "") {$lcd = "None"}
    $lcbd = (($computerFull.lastCompletedBackupDate) -split "T")[0]
    if ($lcbd -eq "") {$lcbd = "None"}
    $la = (($computerFull.lastActivity) -split "T")[0]
    if ($la -eq "") {$la = "None"}
    $devID = $computerFull.deviceUid
    $user = $computerFull.username
    $devName = $computerFull.deviceName
    $status = $computerFull.status
    $os = $computerFull.os
    $coldStore = $computerFull.coldStorage
    $currDate = (Get-Date -UFormat "%Y-%m-%d")
    if ($lcd -eq "None") {$dslc = "Never"} else {
        $dslc = New-TimeSpan -Start $lcd -End $currDate
        $dslc = $dslc.Days
    }
    if ($lcbd -eq "None") {$dslb = "Never"} else {
        $dslb = New-TimeSpan -Start $lcbd -End $currDate
        $dslb = $dslb.Days
    }
    if ($la -eq "None") {$dsla = "Never"} else {
        $dsla = New-TimeSpan -Start $la -End $currDate
        $dsla = $dsla.Days
    }
    if ($dslc -gt 30) {$del = "YES"} else {$del = "NO"}

    $info = New-Object PSCustomObject -Property @{
        Computer_ID = $compID
        Device_GUID = $devID
        User = $user
        Computer = $devName
        Status = $status
        OS = $os
        Cold_Storage = $coldStore
        Last_Connection = $lcd
        Last_Completed_Backup = $lcbd
        Last_Activity = $la
        Days_Since_Last_Connection = $dslc
        Days_Since_Last_Completed_Backup = $dslb
        Days_Since_Last_Activity = $dsla
        Delinquent = $del
    }
    $compInfo += $info
}

$compInfo | Export-CSV -Path $path -NoTypeInformation

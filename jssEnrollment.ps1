$uri = "<URL>/JSSResource/computers"
$headers = @{}
$headers.Add("Accept","application/json")
$creds = (Get-Credential)
$path = "<Output File>"
$lWeekInit = [DateTime]::Today.AddDays(-7)
$lWeek = Get-Date($lWeekInit) -UFormat "%Y-%m-%d"

$computerID = @()
foreach ($comp in ((Invoke-RestMethod -Uri $uri -Method Get -Credential $creds -Headers $headers).computers).id) {
	$computerID += $comp
}

$compInfo = @()
foreach ($comp in $computerID) {
    $computerInfo = (Invoke-RestMethod -Uri "$uri/id/$comp" -Method Get -Credential $creds -Headers $headers).computer
    if ((($computerInfo.general).initial_entry_date) -gt $lWeek) {
        $computerInfo = (Invoke-RestMethod -Uri "$uri/id/$comp" -Method Get -Credential $creds -Headers $headers).computer
        $userID = ($computerInfo.location).username
        $comp = ($computerInfo.general).name
        $real = ($computerInfo.location).real_name
        $enrolled = ($computerInfo.general).initial_entry_date
        $info = New-Object PSCustomObject -Property @{
            UserID = $userID
            Computer = $comp
            UserName = $real
            EnrollDate = $enrolled
        }
        $compInfo += $info
    }
}

$compInfo | Export-CSV -Path $path -NoTypeInformation

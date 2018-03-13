$uri = "<URL>/JSSResource/computers"
$headers = @{}
$headers.Add("Accept","application/json")
$creds = (Get-Credential)
$path = "<Output File>"

$computerID = @()
foreach ($comp in ((Invoke-RestMethod -Uri $uri -Method Get -Credential $creds -Headers $headers).computers).id) {
	$computerID += $comp
}

$compInfo = @()
foreach ($comp in $computerID) {
	$user = (((Invoke-RestMethod -Uri "$uri/id/$comp" -Method Get -Credential $creds -Headers $headers).computer).location).username
	$name = (((Invoke-RestMethod -Uri "$uri/id/$comp" -Method Get -Credential $creds -Headers $headers).computer).general).name
	$info = New-Object PSCustomObject -Property @{
		user = $user
		name = $name
	}
	$compInfo += $info
}

$compInfo | Export-CSV -Path $path -NoTypeInformation

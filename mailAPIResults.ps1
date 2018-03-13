$jssUsersScript = ""
$jssEnrollScript = ""
$cpDataScript = ""
$jssUsers = ""
$jssEnroll = ""
$cpData = ""

$jssTo = "User Name <user@email.com>"
$jssCc = "User Name <user@email.com>"
$cpTo = "User Name <user@email.com>"
$cpCc = "User Name <user@email.com>"

$from = "User Name <user@email.com>"

$mailServer = "<Mail Server>"


$jssMessage = @"

"@

$cpMessage = @"

"@

Write-Host "Running the JSS Users Script"
Invoke-Expression -Command $jssUsersScript

Write-Host "Running the JSS Enrollment Script"
Invoke-Expression -Command $jssEnrollScript

Write-Host "Running the Crash Plan Data Script"
Invoke-Expression -Command $cpDataScript

Send-MailMessage -To $jssTo -Cc $jssCc -Bcc $from  -From $from -Subject "" -Body $jssMessage -Attachments $jssEnroll -SmtpServer $mailServer
Send-MailMessage -To $cpTo -Cc $cpCc -Bcc $from -From $from -Subject "" -Body $cpMessage -Attachments $cpData, $jssUsers -SmtpServer $mailServer

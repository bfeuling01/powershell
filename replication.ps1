$from = "User Name <user@email.com>"
$mailServer = ""

$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $false
$workbook = $objExcel.Workbooks.Open("<Excel Document>")

$worksheet = $workbook.sheets.item("Sheet1")

$rowMax = ($worksheet.UsedRange.Rows).Count

for ($r = 1; $r -le $rowMax; $r++) {
    $src = $worksheet.cells.item($r,1).value2
    $dest = $worksheet.cells.item($r,2).value2
    $to = $worksheet.cells.item($r,3).value2
    $log = ($worksheet.cells.item($r,4).value2 + "\" + $worksheet.cells.item($r,5).value2 + ".txt")
    $title = ($worksheet.cells.item($r,5).value2)
    $options = @("/MIR","/R:5","/LOG:$log","/V")
    $cmdArgs = @("$src","$dest",$options)
    $from = "User Name <user@email.com>"
    
    $replSuccessMessage = @"

"@

    $replFailMessage = @"

"@

    Robocopy.exe @cmdArgs

    if ($LASTEXITCODE -lt 3) {
        Send-MailMessage -To $to -Cc $from -From $from -Subject "SUCCESS: $title Replication $LASTEXITCODE" -Body $replSuccessMessage -SmtpServer $mailServer
    } else {
        Send-MailMessage -To $to -Cc $from -From $from -Subject "FAILURE: $title Replication $LASTEXITCODE" -Body $replFailMessage -SmtpServer $mailServer
    }

}

$workbook.close()
$objExcel.quit()

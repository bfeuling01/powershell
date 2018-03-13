$SrcServer = ""
$SrcDb = ""
$SrcTable = ""
$DestServer = ""
$DestDb = ""
$DestTable = ""
$UID = ""
$PWD = ""

[parameter(Mandatory = $true)]
[string] $SrcServer,
[parameter(Mandatory = $true)]
[string]$SrcDb,
[parameter(Mandatory = $true)]
[string]$SrcTable,
[parameter(Mandatory = $true)]
[string]$DestServer,
[string]$DestDb,
[string]$DestTable,
[switch]$Truncate

If($DestDb.Length -eq 0) {
    $DestDb = $SrcDb
    }

If($DestTable.Length -eq 0){
    $DestTable = $SrcTable
    }

If($Truncate){
    $TruncateSql = "TRUNCATE TABLE " + $DestTable
    Sqlcmd -S $DestServer -d $DestDb -Q $TruncateSql
    }

Function ConnectionString([string]$ServerName, [string]$DbName)
{
    "Data Source=$ServerName;Initial Catalog=$DbName;Integrated Security=True;User ID=$UID;Password=$PWD"
}

$SrcConnStr = ConnectionString $SrcServer $SrcDb
$SrcConn = New-Object System.Data.SqlClient.SqlConnection($SrcConnStr)
$CmdText = "SELECT * FROM " + $SrcTable
$SqlCommand = New-Object System.Data.SqlClient.SqlCommand($CmdText, $SrcConn)
$SrcConn.Open()

[System.Data.SqlClient.SqlDataReader] $SqlReader = $SqlCommand.ExecuteReader()

Try
{
    $DestConnStr = ConnectionString $DestServer $DestDb
    $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($DestConnStr, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
    $bulkCopy.DestinationTableName = $DestTable
    $bulkCopy.WriteToServer($sqlReader)
}
Catch [System.Exception]
{
    $ex = $_.Exception
    Write-Host $ex.Message    
}
Finally
{
    Write-Host "Table $SrcTable in $SrcDb database on $SrcServer has been copied to table
    $DestTable in $DestDb database on $DestServer"

    $SqlReader.Close()
    $SrcConn.Close()
    $SrcConn.Dispose()
    $bulkCopy.Close()
}

$confirmation = Read-Host "Are you sure you want to PULL the latest save from the server? This will overwrite local changes! (y/N)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

$ServerUser = "joshua"
$ServerIP = "100.85.235.29"
$RemoteSaveDir = "/mnt/fastdata/palworld-data/Pal/Saved/SaveGames/0"
$WorldFolderID = "72597299B08041C5A9572392CEF9D3B1"
$LocalWorkDir = "C:\Users\Joshua\Desktop\pal"
$ZipName = "world_backup.zip"
$LocalTargetFolder = "$LocalWorkDir\world_backup"

Write-Host "--- Step 1: Connecting to server to create a fresh backup ---" -ForegroundColor Cyan
$RemoteCommands = @"
cd $RemoteSaveDir
zip -r $ZipName $WorldFolderID -x '$WorldFolderID/backup/*'
"@
$UnixRemoteCommands = $RemoteCommands -replace "`r`n", "`n"
ssh "${ServerUser}@${ServerIP}" $UnixRemoteCommands

Write-Host "--- Step 2: Cleaning up old local workspace ---" -ForegroundColor Cyan
if (Test-Path $LocalTargetFolder) {
    Remove-Item -Path $LocalTargetFolder -Recurse -Force
}
if (!(Test-Path $LocalTargetFolder)) {
    New-Item -ItemType Directory -Path $LocalTargetFolder | Out-Null
}

Write-Host "--- Step 3: Downloading the backup zip to local machine ---" -ForegroundColor Cyan
scp "${ServerUser}@${ServerIP}:${RemoteSaveDir}/$ZipName" "$LocalWorkDir\$ZipName"

Write-Host "--- Step 4: Extracting files locally ---" -ForegroundColor Cyan
Expand-Archive -Path "$LocalWorkDir\$ZipName" -DestinationPath "$LocalTargetFolder" -Force
Remove-Item -Path "$LocalWorkDir\$ZipName" -Force

Write-Host "--- Step 5: Cleaning up remote zip ---" -ForegroundColor Cyan
ssh "${ServerUser}@${ServerIP}" "rm $RemoteSaveDir/$ZipName"

Write-Host "`n[SUCCESS] Backup downloaded and extracted to: $LocalTargetFolder\$WorldFolderID" -ForegroundColor Green
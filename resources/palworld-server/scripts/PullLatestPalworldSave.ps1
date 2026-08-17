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
$RemoteZipPath = "$RemoteSaveDir/$ZipName"
$LocalZipPath = "$LocalWorkDir\$ZipName"

Write-Host "--- Step 1: Creating fresh backup zip on remote server ---" -ForegroundColor Cyan
Write-Host "Target remote directory: $RemoteSaveDir"
Write-Host "Archiving world folder: $WorldFolderID (excluding backups)"
ssh "${ServerUser}@${ServerIP}" "cd $RemoteSaveDir && rm -f $ZipName && zip -r $ZipName $WorldFolderID -x '$WorldFolderID/backup/*'"

Write-Host "--- Step 2: Preparing local workspace ---" -ForegroundColor Cyan
if (Test-Path $LocalTargetFolder) {
    Write-Host "Removing existing local target folder: $LocalTargetFolder"
    Remove-Item -Path $LocalTargetFolder -Recurse -Force
}
Write-Host "Creating local target directory: $LocalTargetFolder"
New-Item -ItemType Directory -Path $LocalTargetFolder -Force | Out-Null

Write-Host "--- Step 3: Downloading remote backup package ---" -ForegroundColor Cyan
Write-Host "Downloading from ${ServerUser}@${ServerIP}:$RemoteZipPath"
Write-Host "Saving to local path: $LocalZipPath"
scp "${ServerUser}@${ServerIP}:$RemoteZipPath" $LocalZipPath

Write-Host "--- Step 4: Extracting and cleaning up ---" -ForegroundColor Cyan
Write-Host "Extracting archive to: $LocalTargetFolder"
Expand-Archive -Path $LocalZipPath -DestinationPath $LocalTargetFolder -Force
Write-Host "Removing temporary local zip file..."
Remove-Item -Path $LocalZipPath -Force
Write-Host "Removing temporary remote zip file..."
ssh "${ServerUser}@${ServerIP}" "rm -v $RemoteZipPath"

Write-Host "`n[SUCCESS] Backup downloaded and extracted to: $LocalTargetFolder\$WorldFolderID" -ForegroundColor Green
$confirmation = Read-Host "Are you sure you want to DEPLOY edited saves to the live server? This will restart the container! (y/N)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

$ServerUser = "joshua"
$ServerIP = "100.85.235.29"
$RemoteSaveDir = "/mnt/fastdata/palworld-data/Pal/Saved/SaveGames/0"
$LocalWorldFolder = "C:\Users\Joshua\Desktop\pal\world_backup\72597299B08041C5A9572392CEF9D3B1"
$ZipPath = "C:\Users\Joshua\Desktop\pal\updated_world.zip"

Write-Host "--- Step 1: Preparing local archive ---" -ForegroundColor Cyan
if (Test-Path $ZipPath) {
    Write-Host "Removing existing local zip package: $ZipPath"
    Remove-Item $ZipPath -Force
}
Write-Host "Compressing local world folder: $LocalWorldFolder"
Write-Host "Destination archive: $ZipPath"
Compress-Archive -Path $LocalWorldFolder -DestinationPath $ZipPath -Force

Write-Host "--- Step 2: Uploading package to remote server ---" -ForegroundColor Cyan
Write-Host "Uploading from: $ZipPath"
Write-Host "Uploading to: ${ServerUser}@${ServerIP}:${RemoteSaveDir}/"
scp $ZipPath "${ServerUser}@${ServerIP}:${RemoteSaveDir}/"

Write-Host "--- Step 3: Executing remote deployment sequence ---" -ForegroundColor Cyan
Write-Host "Target remote directory: $RemoteSaveDir"
Write-Host "Stopping container stack, unpacking update, cleaning archive, and restarting..."
$RemoteCommands = @"
cd $RemoteSaveDir
docker compose -f ~/palworld/docker-compose.yml stop palworld
unzip -o updated_world.zip
rm -v updated_world.zip
docker compose -f ~/palworld/docker-compose.yml start palworld
docker logs -f --tail 50 palworld-server
"@

$UnixRemoteCommands = $RemoteCommands -replace "`r`n", "`n"
ssh "${ServerUser}@${ServerIP}" $UnixRemoteCommands

Write-Host "`n[SUCCESS] Deployment complete and server logs active." -ForegroundColor Green
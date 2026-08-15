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

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Write-Host "Compressing local save folder..." -ForegroundColor Cyan
Compress-Archive -Path $LocalWorldFolder -DestinationPath $ZipPath -Force

Write-Host "Uploading updated save package to server..." -ForegroundColor Cyan
scp $ZipPath "${ServerUser}@${ServerIP}:${RemoteSaveDir}/"

Write-Host "Executing remote deployment sequence..." -ForegroundColor Cyan
$RemoteCommands = @"
cd $RemoteSaveDir
docker stop palworld-server
unzip -o updated_world.zip
rm updated_world.zip
docker start palworld-server
"@

$UnixRemoteCommands = $RemoteCommands -replace "`r`n", "`n"
ssh "${ServerUser}@${ServerIP}" $UnixRemoteCommands

Write-Host "Deployment complete." -ForegroundColor Green
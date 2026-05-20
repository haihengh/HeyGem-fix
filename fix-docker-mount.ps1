$ErrorActionPreference = "Stop"

Write-Host "=== HeyGem Docker restart + mount recheck ===" -ForegroundColor Cyan

$composeFile = "c:\Users\hai\Desktop\code\HeyGem\deploy\docker-compose.yml"
$hostRoot = "D:\heygem_data\voice\data"
$originDir = Join-Path $hostRoot "origin_audio"
$containerName = "heygem-tts"

if (-not (Test-Path $composeFile)) {
  throw "Compose file not found: $composeFile"
}

Write-Host "`n[1] Ensure host directories exist..."
if (-not (Test-Path $hostRoot)) {
  New-Item -ItemType Directory -Path $hostRoot -Force | Out-Null
  Write-Host "Created: $hostRoot"
} else {
  Write-Host "Exists:   $hostRoot"
}

if (-not (Test-Path $originDir)) {
  New-Item -ItemType Directory -Path $originDir -Force | Out-Null
  Write-Host "Created: $originDir"
} else {
  Write-Host "Exists:   $originDir"
}

Write-Host "`n[2] Restart docker compose stack..."
docker compose -f $composeFile down
docker compose -f $composeFile up -d

Write-Host "`n[3] Wait for containers to initialize..."
Start-Sleep -Seconds 8

Write-Host "`n[4] Check running containers..."
docker ps

Write-Host "`n[5] Show mount config for $containerName..."
docker inspect $containerName --format "{{json .Mounts}}"

Write-Host "`n[6] Verify container can access mounted folders..."
docker exec $containerName sh -lc "ls -la /code/data || true; ls -la /code/data/origin_audio || true"

Write-Host "`n[7] Write host test file and verify visibility inside container..."
$testFile = Join-Path $originDir "mount_test_$(Get-Date -Format yyyyMMddHHmmss).txt"
"ok $(Get-Date -Format o)" | Out-File -FilePath $testFile -Encoding utf8
Write-Host "Created host test file: $testFile"
docker exec $containerName sh -lc "ls -la /code/data/origin_audio | tail -n 10 || true"

Write-Host "`n[8] Tail recent TTS logs..."
docker logs --tail 200 $containerName

Write-Host "`nDone." -ForegroundColor Green
Write-Host "If /code/data/origin_audio is still missing or empty in container, verify Docker Desktop drive sharing for D: and volume path spelling."

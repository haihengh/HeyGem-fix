$ErrorActionPreference = "Stop"

Write-Host "=== HeyGem TTS mount check ===" -ForegroundColor Cyan

$hostRoot = "D:\heygem_data\voice\data"
$originDir = Join-Path $hostRoot "origin_audio"
$containerName = "heygem-tts"

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

Write-Host "`n[2] Show current container mount config..."
docker inspect $containerName --format "{{json .Mounts}}"

Write-Host "`n[3] Verify container can see /code/data and /code/data/origin_audio..."
docker exec $containerName sh -lc "ls -la /code/data || true; ls -la /code/data/origin_audio || true"

Write-Host "`n[4] Write a test file on host and confirm container sees it..."
$testFile = Join-Path $originDir "mount_test_$(Get-Date -Format yyyyMMddHHmmss).txt"
"ok $(Get-Date -Format o)" | Out-File -FilePath $testFile -Encoding utf8
Write-Host "Created host test file: $testFile"

docker exec $containerName sh -lc "ls -la /code/data/origin_audio | tail -n 5 || true"

Write-Host "`n[5] Show latest TTS logs..."
docker logs --tail 120 $containerName

Write-Host "`nDone. If step [3]/[4] fails, restart containers with updated compose config."

# Build release APK for Learn Anything.
# Run from an elevated/normal PowerShell AFTER:
# 1) Closing other Flutter/Dart terminals and IDE debug sessions
# 2) Ending leftover dart.exe in Task Manager (if engine.stamp is locked)
# 3) Pausing OneDrive sync (recommended for this folder)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\build_apk.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$flutterRoot = "C:\Users\hassan.fareed.O2XVENTURES\flutter_windows_3.41.9-stable\flutter"
$engineVersionFile = Join-Path $flutterRoot "bin\internal\engine.version"
$env:FLUTTER_PREBUILT_ENGINE_VERSION = (Get-Content $engineVersionFile -Raw).Trim()

Write-Host "Project: $projectRoot"
Write-Host "Engine:  $env:FLUTTER_PREBUILT_ENGINE_VERSION"
Write-Host ""

flutter pub get
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "flutter pub get failed (often engine.stamp lock)."
  Write-Host "Close other terminals, end dart.exe in Task Manager, then retry."
  exit $LASTEXITCODE
}

flutter build apk
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Build failed. If you see AccessDeniedException under build\,"
  Write-Host "pause OneDrive or copy the project to C:\dev\learn-anything and build there."
  exit $LASTEXITCODE
}

$apk = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"
Write-Host ""
Write-Host "APK: $apk"
if (Test-Path $apk) {
  Get-Item $apk | Format-List FullName, Length, LastWriteTime
}

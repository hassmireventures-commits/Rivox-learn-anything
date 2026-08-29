# Package MLC LLM Android runtime (mlc4j) into this repo.
# Prerequisites: Python venv with mlc_llm (or mlc_llm on PATH), Android NDK, Rust — see docs/MLC_ANDROID_SETUP.md
#
# Usage (PowerShell):
#   $env:MLC_LLM_SOURCE_DIR = "C:\path\to\mlc-llm"
#   $env:ANDROID_NDK = "...\android-ndk-r27d"
#   # optional: $env:MLC_PYTHON = "C:\src\mlc-venv\Scripts\python.exe"
#   powershell -ExecutionPolicy Bypass -File scripts\package_mlc.ps1
#
# After success, rebuild:
#   flutter build apk --release --target-platform=android-arm64
# Gradle includes :mlc4j automatically when android/mlc/dist/lib/mlc4j exists.

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$mlcDir = Join-Path $projectRoot "android\mlc"
$distDir = Join-Path $mlcDir "dist\lib\mlc4j"
$config = Join-Path $mlcDir "mlc-package-config.json"

Write-Host "Project: $projectRoot"
Write-Host "MLC dir: $mlcDir"
Write-Host ""

if (-not $env:MLC_LLM_SOURCE_DIR -or -not (Test-Path $env:MLC_LLM_SOURCE_DIR)) {
  Write-Host "ERROR: Set MLC_LLM_SOURCE_DIR to your mlc-llm checkout (with submodules)."
  Write-Host "  git clone https://github.com/mlc-ai/mlc-llm.git"
  Write-Host "  cd mlc-llm; git submodule update --init --recursive"
  Write-Host "  `$env:MLC_LLM_SOURCE_DIR = (Resolve-Path .).Path"
  exit 1
}

if (-not (Test-Path $config)) {
  Write-Host "ERROR: Missing $config"
  exit 1
}

function Invoke-MlcPackage {
  $py = $null
  if ($env:MLC_PYTHON -and (Test-Path $env:MLC_PYTHON)) {
    $py = $env:MLC_PYTHON
  } elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $py = (Get-Command python).Source
  }

  if (-not $py) {
    Write-Host "ERROR: Set MLC_PYTHON to your venv python.exe (mlc-llm + mlc-ai nightlies)."
    Write-Host "  pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cpu mlc-ai-nightly-cpu"
    return 1
  }

  # Prefer launcher: applies Windows TVM/mlc_llm nightlies shims, then runs package CLI.
  $launcher = Join-Path $PSScriptRoot "mlc_package_launch.py"
  if (Test-Path $launcher) {
    Write-Host "Running: $py $launcher (cwd=$mlcDir)"
    & $py $launcher
    return $LASTEXITCODE
  }

  Write-Host "Running: $py -m mlc_llm package (cwd=$mlcDir)"
  & $py -m mlc_llm package
  return $LASTEXITCODE
}

Write-Host "MLC_LLM_SOURCE_DIR=$env:MLC_LLM_SOURCE_DIR"
Write-Host ""

# Windows DIY installs often keep PortableGit off PATH; MLC downloads models via `git clone`.
$portableGitBin = Join-Path $env:USERPROFILE "PortableGit\bin"
if ((Test-Path (Join-Path $portableGitBin "git.exe")) -and ($env:Path -notlike "*$portableGitBin*")) {
  $env:Path = "$portableGitBin;$env:Path"
  Write-Host "Prepended PortableGit to PATH: $portableGitBin"
}

Push-Location $mlcDir
try {
  $code = Invoke-MlcPackage
  if ($code -ne 0) {
    exit $code
  }
} finally {
  Pop-Location
}

$hasGradle = (Test-Path (Join-Path $distDir "build.gradle")) -or (Test-Path (Join-Path $distDir "build.gradle.kts"))
if (-not (Test-Path $distDir) -or -not $hasGradle) {
  Write-Host ""
  Write-Host "ERROR: Expected $distDir with build.gradle(.kts) after packaging."
  exit 1
}

Write-Host ""
Write-Host "OK: mlc4j packaged at $distDir"
Write-Host "Next:"
Write-Host "  1. flutter clean  (optional)"
Write-Host "  2. ALLOW_DEBUG_SIGNING=true flutter build apk --release --target-platform=android-arm64"
Write-Host "  3. Install on a physical arm64 device (6GB+ RAM), download the model in Settings."
Write-Host ""
Write-Host "Without this package the app still builds using the MLC stub (cloud-only local generate)."

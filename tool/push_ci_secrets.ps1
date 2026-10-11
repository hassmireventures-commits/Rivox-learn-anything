# Uploads every key in the gitignored tool/.local_dart_defines.json to the
# GitHub repository's Actions secrets (same names). Values go straight to
# `gh secret set` (encrypted client-side by gh) and are never printed.
#
# One-time:  gh auth login        (GitHub.com, HTTPS, browser)
# Then:      powershell -ExecutionPolicy Bypass -File tool/push_ci_secrets.ps1
#
# Re-run after rotating a key. Use -DryRun to list what would be set.

param(
    [string]$Repo = "hassmireventures-commits/Rivox-learn-anything",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$definesFile = Join-Path $root "tool/.local_dart_defines.json"
if (-not (Test-Path $definesFile)) { throw "Missing $definesFile" }

$gh = (Get-Command gh -ErrorAction SilentlyContinue).Source
if (-not $gh) { $gh = "C:\Program Files\GitHub CLI\gh.exe" }
if (-not (Test-Path $gh)) { throw "GitHub CLI not found. Install: winget install GitHub.cli" }

if (-not $DryRun) {
    $ErrorActionPreference = "Continue"
    & $gh auth status 2>&1 | Out-Null
    $signedIn = $LASTEXITCODE -eq 0
    $ErrorActionPreference = "Stop"
    if (-not $signedIn) { throw "Not signed in. Run: gh auth login" }
}

$defines = Get-Content -Raw $definesFile | ConvertFrom-Json
$count = 0
foreach ($p in $defines.PSObject.Properties) {
    $value = [string]$p.Value
    if ([string]::IsNullOrWhiteSpace($value)) { Write-Host "skip  $($p.Name) (empty)"; continue }
    if ($DryRun) { Write-Host "would set  $($p.Name)"; $count++; continue }
    # --body, not a pipe: PowerShell appends a newline when piping to a
    # native exe, which would end up inside the secret.
    & $gh secret set $p.Name --repo $Repo --body $value.Trim()
    if ($LASTEXITCODE -ne 0) { throw "Failed to set $($p.Name)" }
    Write-Host "set   $($p.Name)"
    $count++
}
Write-Host "$count secret(s) $(if ($DryRun) { 'listed' } else { 'set' }) on $Repo"

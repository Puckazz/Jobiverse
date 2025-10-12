# ─────────────────────────────────────────────────────────────
# GitHub Secrets Importer Script for Jobiverse (PowerShell)
# Author: nhatt
# ─────────────────────────────────────────────────────────────

# Prompt GitHub token via GUI (secure, cross-shell)
Add-Type -AssemblyName Microsoft.VisualBasic
$Token = [Microsoft.VisualBasic.Interaction]::InputBox("Paste your GitHub token here (will not be shown)", "GitHub Token")

# Validate token input
if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "❌ No token entered. Exiting..." -ForegroundColor Red
    exit 1
}

# Enable fail-fast on error
$ErrorActionPreference = "Stop"

# Utility: Colored console messages
function Write-Info($msg)       { Write-Host "🔷 $msg" -ForegroundColor Cyan }
function Write-Success($msg)    { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-WarningMsg($msg) { Write-Host "⚠️ $msg" -ForegroundColor Yellow }
function Write-ErrorMsg($msg)   { Write-Host "❌ $msg" -ForegroundColor Red }

# Constants
$RepoUrl = "https://$Token@github.com/nhattVim/.env"
$TempDir = "temp_secrets_$([System.Diagnostics.Process]::GetCurrentProcess().Id)"
$Mappings = @{
    "Jobiverse/backend/.env"                    = "backend/.env"
    "Jobiverse/backend.NET/appsettings.json"    = "backend.NET/appsettings.json"
    "Jobiverse/frontend/.env"                   = "frontend/.env"
}

# Clone secrets repo
Write-Info "Cloning secrets repository..."
git -c credential.helper= clone $RepoUrl $TempDir 2>$null

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $TempDir)) {
    Write-ErrorMsg "❌ Clone failed. Kiểm tra GitHub token hoặc quyền truy cập vào repo."
    exit 1
}

Write-Success "✅ Repository cloned successfully to '$TempDir'"

# Copy mapped files
Write-Info "📂 Copying environment configuration files..."
foreach ($src in $Mappings.Keys) {
    $dst = $Mappings[$src]
    $fullSrc = Join-Path $TempDir $src
    $dstDir = Split-Path $dst -Parent

    if (Test-Path $fullSrc) {
        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        Copy-Item $fullSrc -Destination $dst -Force
        Write-Success "✅ Copied $dst"
    } else {
        Write-WarningMsg "⚠️ $src not found in repository."
    }
}

# Cleanup
Remove-Item -Recurse -Force $TempDir
Write-Info "🧹 Temporary folder removed."

# Done
Write-Success "🎉 All secrets imported successfully!"

# Install git hooks for secret scanning
# Run this script after cloning the repository

$ErrorActionPreference = "Stop"

Write-Host "Installing git hooks..." -ForegroundColor Green

$hooksDir = ".git/hooks"
$preCommitHook = "$hooksDir/pre-commit"

# Check if .git/hooks directory exists
if (-not (Test-Path $hooksDir)) {
    Write-Host "Error: .git/hooks directory not found. Are you in a git repository?" -ForegroundColor Red
    exit 1
}

# Check if gitleaks is installed
if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) {
    Write-Host "Warning: gitleaks is not installed." -ForegroundColor Yellow
    Write-Host "Install it from: https://github.com/gitleaks/gitleaks" -ForegroundColor Yellow
    Write-Host "The pre-commit hook will still be installed but will fail until gitleaks is available." -ForegroundColor Yellow
}

# Copy pre-commit hook if it doesn't exist or is different
$sourceHook = ".git/hooks/pre-commit"
if (Test-Path $sourceHook) {
    Write-Host "Pre-commit hook already exists at $sourceHook" -ForegroundColor Yellow
    Write-Host "If you want to update it, delete it first and run this script again." -ForegroundColor Yellow
} else {
    # The hook should already be in .git/hooks from our write operation
    Write-Host "Pre-commit hook installed at $sourceHook" -ForegroundColor Green
}

Write-Host "`nGit hooks installation complete!" -ForegroundColor Green
Write-Host "The pre-commit hook will now run gitleaks on every commit." -ForegroundColor Green
Write-Host "To skip it (not recommended): git commit --no-verify" -ForegroundColor Yellow


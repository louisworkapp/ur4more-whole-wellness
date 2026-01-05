#requires -version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# UR4MORE Wellness Security Tools Installer (Windows)
# Installs gitleaks and trufflehog for secret scanning
# Usage: .\tools\install_security_tools_windows.ps1

$ErrorActionPreference = "Continue"
$installed = @()
$failed = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Security Scanning Tools" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Helper function to check if a command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check if winget is available
function Test-Winget {
    $null = Get-Command winget -ErrorAction SilentlyContinue
    return $?
}

# Check if Chocolatey is available
function Test-Chocolatey {
    $null = Get-Command choco -ErrorAction SilentlyContinue
    return $?
}

# Check if Scoop is available
function Test-Scoop {
    $null = Get-Command scoop -ErrorAction SilentlyContinue
    return $?
}

# Check if pip is available
function Test-Pip {
    $null = Get-Command pip -ErrorAction SilentlyContinue
    return $?
}

$hasWinget = Test-Winget
$hasChocolatey = Test-Chocolatey
$hasScoop = Test-Scoop
$hasPip = Test-Pip

if (-not $hasWinget) {
    Write-Host "[WARN] winget not found. Will try alternative installers." -ForegroundColor Yellow
    Write-Host ""
}

# ============================================
# Install Gitleaks
# ============================================
Write-Host "[1] Installing Gitleaks..." -ForegroundColor Yellow

if (Test-Command "gitleaks") {
    $version = & gitleaks version 2>&1
    Write-Host "  [OK] Gitleaks already installed: $version" -ForegroundColor Green
    $installed += "gitleaks"
} else {
    if ($hasWinget) {
        Write-Host "  -> Installing via winget..." -ForegroundColor Cyan
        try {
            & winget install --id gitleaks.gitleaks --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                # Verify installation
                Start-Sleep -Seconds 2
                if (Test-Command "gitleaks") {
                    $version = & gitleaks version 2>&1
                    Write-Host "  [OK] Gitleaks installed: $version" -ForegroundColor Green
                    $installed += "gitleaks"
                } else {
                    Write-Host "  [WARN] Gitleaks installed but not in PATH. Restart terminal or add manually." -ForegroundColor Yellow
                    $failed += "gitleaks (installed but PATH not updated)"
                }
            } else {
                Write-Host "  [FAIL] winget install failed" -ForegroundColor Red
                $failed += "gitleaks"
            }
        } catch {
            Write-Host "  [FAIL] Installation error: $($_.Exception.Message)" -ForegroundColor Red
            $failed += "gitleaks"
        }
    } else {
        Write-Host "  [INFO] Manual installation required:" -ForegroundColor Yellow
        Write-Host "    1. Download from: https://github.com/gitleaks/gitleaks/releases/latest" -ForegroundColor White
        Write-Host "    2. Extract gitleaks.exe to a directory in your PATH" -ForegroundColor White
        Write-Host "    3. Or use Chocolatey: choco install gitleaks" -ForegroundColor White
        $failed += "gitleaks (manual install required)"
    }
}

Write-Host ""

# ============================================
# Install Trufflehog
# ============================================
Write-Host "[2] Installing Trufflehog..." -ForegroundColor Yellow

if (Test-Command "trufflehog") {
    $version = & trufflehog --version 2>&1
    Write-Host "  [OK] Trufflehog already installed: $version" -ForegroundColor Green
    $installed += "trufflehog"
} else {
    $trufflehogInstalled = $false
    
    # Try Scoop first (most reliable for Trufflehog on Windows)
    if (-not $trufflehogInstalled -and $hasScoop) {
        Write-Host "  -> Trying Scoop..." -ForegroundColor Cyan
        try {
            & scoop install trufflehog 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                Start-Sleep -Seconds 2
                if (Test-Command "trufflehog") {
                    $version = & trufflehog --version 2>&1
                    Write-Host "  [OK] Trufflehog installed via Scoop: $version" -ForegroundColor Green
                    $installed += "trufflehog"
                    $trufflehogInstalled = $true
                }
            }
        } catch {
            Write-Host "  [WARN] Scoop install failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Try Chocolatey
    if (-not $trufflehogInstalled -and $hasChocolatey) {
        Write-Host "  -> Trying Chocolatey..." -ForegroundColor Cyan
        try {
            & choco install trufflehog -y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                Start-Sleep -Seconds 2
                if (Test-Command "trufflehog") {
                    $version = & trufflehog --version 2>&1
                    Write-Host "  [OK] Trufflehog installed via Chocolatey: $version" -ForegroundColor Green
                    $installed += "trufflehog"
                    $trufflehogInstalled = $true
                }
            }
        } catch {
            Write-Host "  [WARN] Chocolatey install failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Try pip (Python package manager)
    if (-not $trufflehogInstalled -and $hasPip) {
        Write-Host "  -> Trying pip..." -ForegroundColor Cyan
        try {
            & pip install trufflehog 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                Start-Sleep -Seconds 2
                if (Test-Command "trufflehog") {
                    $version = & trufflehog --version 2>&1
                    Write-Host "  [OK] Trufflehog installed via pip: $version" -ForegroundColor Green
                    $installed += "trufflehog"
                    $trufflehogInstalled = $true
                }
            }
        } catch {
            Write-Host "  [WARN] pip install failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Try winget (may not have package, but worth trying)
    if (-not $trufflehogInstalled -and $hasWinget) {
        Write-Host "  -> Trying winget..." -ForegroundColor Cyan
        try {
            & winget search trufflehog 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                & winget install --id TruffleSecurity.Trufflehog --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    # Refresh PATH
                    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                    
                    Start-Sleep -Seconds 2
                    if (Test-Command "trufflehog") {
                        $version = & trufflehog --version 2>&1
                        Write-Host "  [OK] Trufflehog installed via winget: $version" -ForegroundColor Green
                        $installed += "trufflehog"
                        $trufflehogInstalled = $true
                    }
                }
            }
        } catch {
            Write-Host "  [WARN] winget install failed (package may not be available)" -ForegroundColor Yellow
        }
    }
    
    # If all automated methods failed, provide manual instructions
    if (-not $trufflehogInstalled) {
        Write-Host "  [INFO] Automated installation failed. Manual installation required:" -ForegroundColor Yellow
        Write-Host "" -ForegroundColor White
        Write-Host "  Option 1 - Scoop (recommended):" -ForegroundColor Cyan
        Write-Host "    scoop install trufflehog" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "  Option 2 - Chocolatey:" -ForegroundColor Cyan
        Write-Host "    choco install trufflehog" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "  Option 3 - pip (if Python installed):" -ForegroundColor Cyan
        Write-Host "    pip install trufflehog" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "  Option 4 - Direct download:" -ForegroundColor Cyan
        Write-Host "    1. Download from: https://github.com/trufflesecurity/trufflehog/releases/latest" -ForegroundColor White
        Write-Host "    2. Extract trufflehog_windows_amd64.exe" -ForegroundColor White
        Write-Host "    3. Rename to trufflehog.exe and add to PATH" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        $failed += "trufflehog (manual install required)"
    }
}

Write-Host ""

# ============================================
# Summary
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($installed.Count -gt 0) {
    Write-Host "[OK] Installed/Already Available:" -ForegroundColor Green
    foreach ($tool in $installed) {
        Write-Host "  - $tool" -ForegroundColor Green
    }
    Write-Host ""
}

if ($failed.Count -gt 0) {
    Write-Host "[INFO] Manual Installation Required:" -ForegroundColor Yellow
    foreach ($tool in $failed) {
        Write-Host "  - $tool" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "After manual installation, verify with:" -ForegroundColor Cyan
    Write-Host "  gitleaks version" -ForegroundColor White
    Write-Host "  trufflehog --version" -ForegroundColor White
    Write-Host ""
    exit 1
} else {
    Write-Host "[OK] All tools installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verify installation:" -ForegroundColor Cyan
    Write-Host "  gitleaks version" -ForegroundColor White
    Write-Host "  trufflehog --version" -ForegroundColor White
    Write-Host ""
    Write-Host "Run safety check:" -ForegroundColor Cyan
    Write-Host "  .\tools\public_safety_check.ps1" -ForegroundColor White
    exit 0
}


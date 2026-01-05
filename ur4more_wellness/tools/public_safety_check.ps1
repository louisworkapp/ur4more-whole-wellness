[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

param(
    [switch]$Strict,
    [switch]$CI
)

$ErrorActionPreference = if ($Strict -or $CI) { "Stop" } else { "Continue" }
$script:HasFailures = $false
$script:HasWarnings = $false

function Write-Status {
    param([string]$Level, [string]$Message)
    $prefix = switch ($Level) {
        "OK" { "[OK]" }
        "WARN" { "[WARN]" }
        "FAIL" { "[FAIL]" }
        "INFO" { "[INFO]" }
        default { "[INFO]" }
    }
    Write-Host "$prefix $Message"
    if ($Level -eq "FAIL") { $script:HasFailures = $true }
    if ($Level -eq "WARN") { $script:HasWarnings = $true }
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Invoke-GitleaksScan {
    Write-Status "INFO" "Checking for gitleaks..."
    
    if (-not (Test-Command "gitleaks")) {
        $msg = "gitleaks not found in PATH"
        if ($Strict -or $CI) {
            Write-Status "FAIL" $msg
            return $false
        } else {
            Write-Status "WARN" "$msg - skipping gitleaks scan"
            return $true
        }
    }
    
    Write-Status "INFO" "Running gitleaks detect..."
    
    $configFile = if (Test-Path "gitleaks.toml") { "gitleaks.toml" } 
                  elseif (Test-Path ".gitleaks.toml") { ".gitleaks.toml" }
                  else { $null }
    
    $gitleaksArgs = @("detect", "--no-banner", "--source", ".")
    if ($configFile) {
        $gitleaksArgs += "--config", $configFile
        Write-Status "INFO" "Using config: $configFile"
    }
    
    if ($CI) {
        $gitleaksArgs += "--exit-code", "1"
    }
    
    $gitleaksOutput = & gitleaks $gitleaksArgs 2>&1
    $gitleaksExitCode = $LASTEXITCODE
    
    if ($gitleaksExitCode -eq 0) {
        Write-Status "OK" "gitleaks scan passed - no secrets detected"
        return $true
    } else {
        Write-Host $gitleaksOutput
        $msg = "gitleaks detected potential secrets"
        if ($Strict -or $CI) {
            Write-Status "FAIL" $msg
            return $false
        } else {
            Write-Status "WARN" $msg
            return $true
        }
    }
}

function Invoke-TrufflehogScan {
    Write-Status "INFO" "Checking for trufflehog..."
    
    if (-not (Test-Command "trufflehog")) {
        $msg = "trufflehog not found in PATH"
        if ($Strict -or $CI) {
            Write-Status "FAIL" $msg
            return $false
        } else {
            Write-Status "WARN" "$msg - skipping trufflehog scan"
            return $true
        }
    }
    
    Write-Status "INFO" "Running trufflehog git scan..."
    
    $excludePaths = @()
    
    if (Test-Path ".trufflehogignore") {
        Write-Status "INFO" "Reading .trufflehogignore..."
        $ignoreContent = Get-Content ".trufflehogignore" -Raw
        $ignoreLines = $ignoreContent -split "`n" | Where-Object { $_ -match '^\s*[^#]' -and $_.Trim() -ne "" }
        foreach ($line in $ignoreLines) {
            $pattern = $line.Trim()
            if ($pattern -and -not $pattern.StartsWith("#")) {
                $excludePaths += $pattern
            }
        }
    }
    
    $trufflehogArgs = @("git", "file://.", "--json")
    if ($excludePaths.Count -gt 0) {
        $excludeFile = [System.IO.Path]::GetTempFileName()
        $excludePaths | Set-Content $excludeFile
        $trufflehogArgs += "--exclude-paths", $excludeFile
        Write-Status "INFO" "Using exclude patterns from .trufflehogignore"
    }
    
    $trufflehogOutput = & trufflehog $trufflehogArgs 2>&1
    $trufflehogExitCode = $LASTEXITCODE
    
    if ($excludePaths.Count -gt 0) {
        Remove-Item $excludeFile -ErrorAction SilentlyContinue
    }
    
    if ($trufflehogExitCode -eq 0 -and $trufflehogOutput -match '^\s*$') {
        Write-Status "OK" "trufflehog scan passed - no secrets detected"
        return $true
    } else {
        if ($trufflehogOutput -and $trufflehogOutput.Trim() -ne "") {
            Write-Host $trufflehogOutput
        }
        $msg = "trufflehog detected potential secrets"
        if ($Strict -or $CI) {
            Write-Status "FAIL" $msg
            return $false
        } else {
            Write-Status "WARN" $msg
            return $true
        }
    }
}

function Invoke-LightweightRegexScan {
    Write-Status "INFO" "Running lightweight regex scan for obvious secrets..."
    
    $secretPatterns = @(
        @{ Pattern = '(?i)(password|passwd|pwd)\s*[=:]\s*["'']?[^"'']{8,}["'']?'; Name = "Hardcoded password" }
        @{ Pattern = '(?i)(api[_-]?key|apikey)\s*[=:]\s*["'']?[A-Za-z0-9_-]{20,}["'']?'; Name = "API key" }
        @{ Pattern = '(?i)(secret[_-]?key|secretkey)\s*[=:]\s*["'']?[A-Za-z0-9_-]{20,}["'']?'; Name = "Secret key" }
        @{ Pattern = 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'; Name = "JWT token" }
        @{ Pattern = 'sk_live_[A-Za-z0-9]{24,}'; Name = "Stripe live key" }
        @{ Pattern = 'sk_test_[A-Za-z0-9]{24,}'; Name = "Stripe test key" }
        @{ Pattern = 'AKIA[0-9A-Z]{16}'; Name = "AWS access key" }
    )
    
    $excludeDirs = @(
        "build",
        ".dart_tool",
        "windows\flutter\ephemeral",
        "ios\Runner.xcodeproj\project.pbxproj",
        "docs"
    )
    
    $excludePatterns = $excludeDirs | ForEach-Object { 
        if ($_ -match '\\') { $_ -replace '\\', '[\\/]' } else { $_ }
    }
    
    $foundSecrets = @()
    
    Get-ChildItem -Recurse -File | Where-Object {
        $relPath = $_.FullName.Replace((Get-Location).Path + "\", "").Replace((Get-Location).Path + "/", "")
        $shouldExclude = $false
        
        # Exclude .venv directories
        if ($relPath -match '[\\/]\.venv[\\/]') {
            $shouldExclude = $true
        }
        
        # Exclude based on patterns
        foreach ($exclude in $excludePatterns) {
            if ($relPath -match $exclude) {
                $shouldExclude = $true
                break
            }
        }
        
        # Exclude markdown files in docs directory
        if ($relPath -match '\.md$' -and $relPath -match '^docs[\\/]') {
            $shouldExclude = $true
        }
        
        -not $shouldExclude
    } | ForEach-Object {
        try {
            $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            if ($content) {
                foreach ($patternInfo in $secretPatterns) {
                    if ($content -match $patternInfo.Pattern) {
                        $foundSecrets += @{
                            File = $_.FullName.Replace((Get-Location).Path + "\", "").Replace((Get-Location).Path + "/", "")
                            Pattern = $patternInfo.Name
                        }
                    }
                }
            }
        } catch {
        }
    }
    
    if ($foundSecrets.Count -eq 0) {
        Write-Status "OK" "Lightweight regex scan passed - no obvious secrets found"
        return $true
    } else {
        Write-Status "WARN" "Lightweight regex scan found potential secrets:"
        foreach ($secret in $foundSecrets) {
            Write-Host "  - $($secret.File): $($secret.Pattern)"
        }
        if ($Strict -or $CI) {
            Write-Status "FAIL" "Regex scan found potential secrets (strict mode)"
            return $false
        }
        return $true
    }
}

Write-Status "INFO" "Starting public safety check..."
Write-Status "INFO" "Mode: $(if ($Strict) { 'STRICT' } else { 'WARN' })"
Write-Status "INFO" "CI: $(if ($CI) { 'YES' } else { 'NO' })"
Write-Host ""

$results = @()

$results += Invoke-GitleaksScan
$results += Invoke-TrufflehogScan
$results += Invoke-LightweightRegexScan

Write-Host ""
if ($script:HasFailures) {
    Write-Status "FAIL" "Safety check FAILED - one or more scans detected issues"
    exit 1
} elseif ($script:HasWarnings -and ($Strict -or $CI)) {
    Write-Status "FAIL" "Safety check FAILED - warnings in strict/CI mode"
    exit 1
} else {
    Write-Status "OK" "Safety check completed successfully"
    exit 0
}

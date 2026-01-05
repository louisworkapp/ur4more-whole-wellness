param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$JwtToken = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ApiBaseUrl = "http://127.0.0.1:8080",
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowDebug
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Continue"

# Debug mode: Show parameter parsing details
if ($ShowDebug) {
    Write-Host "[DEBUG] Parameter Parsing Debug:" -ForegroundColor Cyan
    Write-Host "  JwtToken: '$JwtToken'" -ForegroundColor Yellow
    Write-Host "  JwtToken type: $($JwtToken.GetType().Name)" -ForegroundColor Gray
    Write-Host "  JwtToken length: $($JwtToken.Length)" -ForegroundColor Gray
    Write-Host "  JwtToken is empty: $([string]::IsNullOrEmpty($JwtToken))" -ForegroundColor Gray
    Write-Host "  PSBoundParameters:" -ForegroundColor Yellow
    $PSBoundParameters.GetEnumerator() | ForEach-Object {
        Write-Host "    $($_.Key): $($_.Value)" -ForegroundColor Gray
    }
    Write-Host "  Raw args: $($args -join ', ')" -ForegroundColor Gray
    Write-Host ""
}

# Build Flutter arguments
$flutterArgs = @(
    "run",
    "-d", "web-server",
    "--web-hostname", "127.0.0.1",
    "--web-port", "59844",
    "--dart-define=UR4MORE_API_BASE_URL=$ApiBaseUrl"
)

# Check if JwtToken was provided (handle both empty string and null)
$hasJwt = $false
if ($PSBoundParameters.ContainsKey('JwtToken') -and -not [string]::IsNullOrWhiteSpace($JwtToken)) {
    $flutterArgs += "--dart-define=UR4MORE_DEV_JWT=$JwtToken"
    $hasJwt = $true
    if ($ShowDebug) {
        Write-Host "[DEBUG] JWT token value: $JwtToken" -ForegroundColor Gray
    }
} elseif ($ShowDebug) {
    Write-Host "[DEBUG] No JWT token provided or token is empty/whitespace" -ForegroundColor Gray
}

# Print startup information
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Flutter Web Development Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter Web URL:  http://127.0.0.1:59844" -ForegroundColor Green
Write-Host "API Base URL:     $ApiBaseUrl" -ForegroundColor Green
Write-Host "JWT Token:        $(if ($hasJwt) { 'Present (yes)' } else { 'Not provided (no)' })" -ForegroundColor $(if ($hasJwt) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Starting Flutter..." -ForegroundColor Cyan
Write-Host ""

& flutter $flutterArgs

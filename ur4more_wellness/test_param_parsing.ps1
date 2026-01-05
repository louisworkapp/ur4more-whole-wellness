# PowerShell Parameter Parsing Debug Script
# Tests different invocation methods to understand how PowerShell handles parameters

param(
    [string]$JwtToken = "",
    [switch]$ShowDebug
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== PowerShell Parameter Parsing Debug ===" -ForegroundColor Cyan
Write-Host ""

# Display received parameters
Write-Host "Parameters received:" -ForegroundColor Yellow
Write-Host "  JwtToken: '$JwtToken'" -ForegroundColor White
Write-Host "  JwtToken type: $($JwtToken.GetType().Name)" -ForegroundColor Gray
Write-Host "  JwtToken length: $($JwtToken.Length)" -ForegroundColor Gray
Write-Host "  JwtToken is empty: $([string]::IsNullOrEmpty($JwtToken))" -ForegroundColor Gray
Write-Host "  ShowDebug: $ShowDebug" -ForegroundColor White
Write-Host ""

# Display all bound parameters
Write-Host "All bound parameters:" -ForegroundColor Yellow
$PSBoundParameters.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor White
}
Write-Host ""

# Display command line arguments
Write-Host "Command line arguments (raw):" -ForegroundColor Yellow
$args | ForEach-Object {
    Write-Host "  '$_' (type: $($_.GetType().Name))" -ForegroundColor White
}
Write-Host ""

# Test different scenarios
Write-Host "=== Testing Parameter Scenarios ===" -ForegroundColor Cyan
Write-Host ""

# Scenario 1: No parameters
Write-Host "Scenario 1: No parameters" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = ''" -ForegroundColor Gray
Write-Host ""

# Scenario 2: Named parameter
Write-Host "Scenario 2: Named parameter" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 -JwtToken 'test123'" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = 'test123'" -ForegroundColor Gray
Write-Host ""

# Scenario 3: Positional parameter
Write-Host "Scenario 3: Positional parameter" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 'test123'" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = 'test123' (if positional)" -ForegroundColor Gray
Write-Host ""

# Scenario 4: Switch parameter
Write-Host "Scenario 4: Switch parameter" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 -ShowDebug" -ForegroundColor Gray
Write-Host "  Expected: ShowDebug = True" -ForegroundColor Gray
Write-Host ""

# Scenario 5: Both parameters
Write-Host "Scenario 5: Both parameters" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 -JwtToken 'test123' -ShowDebug" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = 'test123', ShowDebug = True" -ForegroundColor Gray
Write-Host ""

# Scenario 6: Quoted empty string
Write-Host "Scenario 6: Quoted empty string" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 -JwtToken ''" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = ''" -ForegroundColor Gray
Write-Host ""

# Scenario 7: Using equals sign
Write-Host "Scenario 7: Using equals sign" -ForegroundColor Green
Write-Host "  Command: .\test_param_parsing.ps1 -JwtToken='test123'" -ForegroundColor Gray
Write-Host "  Expected: JwtToken = 'test123'" -ForegroundColor Gray
Write-Host ""

# Display PowerShell version info
Write-Host "=== PowerShell Environment ===" -ForegroundColor Cyan
Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "  Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor White
Write-Host "  Script Path: $PSCommandPath" -ForegroundColor White
Write-Host ""

# Test actual usage (simulating run_flutter.ps1 behavior)
Write-Host "=== Simulating run_flutter.ps1 Usage ===" -ForegroundColor Cyan
$flutterArgs = @(
    "run",
    "-d", "web-server",
    "--web-hostname", "127.0.0.1",
    "--web-port", "59844",
    "--dart-define=UR4MORE_API_BASE_URL=http://127.0.0.1:8080"
)

if ($JwtToken -ne "") {
    $flutterArgs += "--dart-define=UR4MORE_DEV_JWT=$JwtToken"
    Write-Host "[INFO] Using provided JWT token for dev mode" -ForegroundColor Green
    Write-Host "[INFO] JWT token value: $JwtToken" -ForegroundColor Gray
} else {
    Write-Host "[INFO] No JWT token provided, running without dev JWT" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Flutter arguments that would be used:" -ForegroundColor Yellow
$flutterArgs | ForEach-Object {
    Write-Host "  $_" -ForegroundColor White
}
Write-Host ""

Write-Host "=== Debug Complete ===" -ForegroundColor Cyan


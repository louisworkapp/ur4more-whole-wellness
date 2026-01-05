[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Continue"

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
}

function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("127.0.0.1", $Port)
        $connected = $connection.Connected
        $connection.Close()
        return $connected
    } catch {
        return $false
    }
}

function Test-HttpEndpoint {
    param([string]$Url, [string]$Method = "GET")
    try {
        $request = [System.Net.WebRequest]::Create($Url)
        $request.Method = $Method
        $request.Timeout = 3000
        $response = $request.GetResponse()
        $statusCode = [int]$response.StatusCode
        $response.Close()
        return @{ Success = $true; StatusCode = $statusCode }
    } catch {
        return @{ Success = $false; StatusCode = 0; Error = $_.Exception.Message }
    }
}

function Test-CorsPreflight {
    param([string]$Url)
    try {
        $request = [System.Net.WebRequest]::Create($Url)
        $request.Method = "OPTIONS"
        $request.Timeout = 3000
        $request.Headers.Add("Origin", "http://127.0.0.1:59844")
        $request.Headers.Add("Access-Control-Request-Method", "GET")
        $request.Headers.Add("Access-Control-Request-Headers", "Authorization,Content-Type")
        
        $response = $request.GetResponse()
        $headers = $response.Headers
        
        $corsHeaders = @{
            "Access-Control-Allow-Origin" = $headers["Access-Control-Allow-Origin"]
            "Access-Control-Allow-Methods" = $headers["Access-Control-Allow-Methods"]
            "Access-Control-Allow-Headers" = $headers["Access-Control-Allow-Headers"]
        }
        
        $response.Close()
        return @{ Success = $true; Headers = $corsHeaders }
    } catch {
        return @{ Success = $false; Headers = @{}; Error = $_.Exception.Message }
    }
}

function Get-ApiBaseUrl {
    $gatewayServicePath = "lib\services\gateway_service.dart"
    if (-not (Test-Path $gatewayServicePath)) {
        return $null
    }
    
    $content = Get-Content $gatewayServicePath -Raw
    if ($content -match 'UR4MORE_API_BASE_URL') {
        # Match both const and getter patterns: String.fromEnvironment('UR4MORE_API_BASE_URL', ...)
        if ($content -match 'String\.fromEnvironment\s*\(\s*[''"]UR4MORE_API_BASE_URL[''"]') {
            # Extract defaultValue from the String.fromEnvironment call
            # Match: defaultValue: 'http://...' or defaultValue: "http://..."
            if ($content -match 'defaultValue:\s*[''"]([^''"]+)[''"]') {
                $defaultUrl = $matches[1]
                return $defaultUrl
            }
            return "configured via dart-define"
        }
    }
    return $null
}

Write-Status "INFO" "Starting self-diagnosis..."
Write-Host ""

Write-Status "INFO" "Checking gateway ports..."
$port8080 = Test-Port -Port 8080
$port8000 = Test-Port -Port 8000

if ($port8080) {
    Write-Status "OK" "Port 8080 is listening"
    $healthResult = Test-HttpEndpoint -Url "http://127.0.0.1:8080/health"
    if ($healthResult.Success) {
        Write-Status "OK" "Gateway /health endpoint responded: $($healthResult.StatusCode)"
    } else {
        Write-Status "WARN" "Gateway /health endpoint failed: $($healthResult.Error)"
    }
    
    $manifestResult = Test-HttpEndpoint -Url "http://127.0.0.1:8080/content/manifest"
    if ($manifestResult.Success) {
        Write-Status "OK" "Gateway /content/manifest endpoint responded: $($manifestResult.StatusCode)"
    } else {
        Write-Status "WARN" "Gateway /content/manifest endpoint failed: $($manifestResult.Error)"
    }
    
    Write-Status "INFO" "Testing CORS preflight for /content/manifest..."
    $corsResult = Test-CorsPreflight -Url "http://127.0.0.1:8080/content/manifest"
    if ($corsResult.Success) {
        Write-Status "OK" "CORS preflight successful"
        if ($corsResult.Headers["Access-Control-Allow-Origin"]) {
            Write-Status "INFO" "  Access-Control-Allow-Origin: $($corsResult.Headers['Access-Control-Allow-Origin'])"
        }
        if ($corsResult.Headers["Access-Control-Allow-Methods"]) {
            Write-Status "INFO" "  Access-Control-Allow-Methods: $($corsResult.Headers['Access-Control-Allow-Methods'])"
        }
        if ($corsResult.Headers["Access-Control-Allow-Headers"]) {
            Write-Status "INFO" "  Access-Control-Allow-Headers: $($corsResult.Headers['Access-Control-Allow-Headers'])"
        }
    } else {
        Write-Status "WARN" "CORS preflight failed: $($corsResult.Error)"
    }
} else {
    Write-Status "FAIL" "Port 8080 is not listening - gateway may not be running"
}

if ($port8000) {
    Write-Status "OK" "Port 8000 is listening"
    $healthResult8000 = Test-HttpEndpoint -Url "http://127.0.0.1:8000/health"
    if ($healthResult8000.Success) {
        Write-Status "OK" "Gateway /health endpoint on port 8000 responded: $($healthResult8000.StatusCode)"
    } else {
        Write-Status "WARN" "Gateway /health endpoint on port 8000 failed: $($healthResult8000.Error)"
    }
} else {
    Write-Status "INFO" "Port 8000 is not listening (this is OK if gateway uses 8080)"
}

Write-Host ""
Write-Status "INFO" "Checking Flutter and API configuration..."

# Expected ports section
Write-Status "INFO" "Expected Ports (this is normal):"
Write-Status "INFO" "  FLUTTER_WEB_URL: http://127.0.0.1:59844 (Flutter web app)"
Write-Status "INFO" "  API_BASE_URL: http://127.0.0.1:8080 (Gateway API)"
Write-Status "INFO" "  Note: These are different ports by design - Flutter web runs on 59844, Gateway API on 8080"

Write-Host ""
Write-Status "INFO" "Detected Configuration:"

# Get API base URL from code
$apiBaseUrl = Get-ApiBaseUrl
if ($apiBaseUrl) {
    Write-Status "INFO" "  API_BASE_URL (from code): $apiBaseUrl"
    
    # Extract port from API base URL
    $apiPort = $null
    if ($apiBaseUrl -match ':(8\d{3})') {
        $apiPort = [int]$matches[1]
    } elseif ($apiBaseUrl -match 'localhost:(\d+)') {
        $apiPort = [int]$matches[1]
    }
    
    # Only warn if API_BASE_URL points to a port where gateway is NOT listening
    if ($apiPort -eq 8080 -and -not $port8080) {
        Write-Status "WARN" "  API_BASE_URL points to port 8080, but gateway is not listening"
        Write-Status "INFO" "    Fix: Start the gateway server on port 8080"
    } elseif ($apiPort -eq 8000 -and -not $port8000) {
        Write-Status "WARN" "  API_BASE_URL points to port 8000, but gateway is not listening"
        Write-Status "INFO" "    Fix: Start the gateway server on port 8000"
    } elseif ($apiPort -eq 8080 -and $port8080) {
        Write-Status "OK" "  API_BASE_URL (8080) matches gateway port"
    } elseif ($apiPort -eq 8000 -and $port8000) {
        Write-Status "OK" "  API_BASE_URL (8000) matches gateway port"
    }
} else {
    Write-Status "WARN" "  Could not detect UR4MORE_API_BASE_URL in gateway_service.dart"
}

Write-Host ""
Write-Status "INFO" "Self-diagnosis complete"

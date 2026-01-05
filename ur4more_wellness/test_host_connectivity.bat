@echo off
if "%~1"=="" (
    echo Usage: test_host_connectivity.bat ^<host^>
    exit /b 1
)

set HOST=%~1
echo Testing connectivity to: %HOST%
echo.

REM DNS resolution
echo ========================================
echo [1/5] DNS Resolution
echo ========================================
nslookup %HOST%
echo.

REM Port 443 connectivity test
echo ========================================
echo [2/5] Port 443 Connectivity Test
echo ========================================
powershell -NoProfile -Command "Test-NetConnection %HOST% -Port 443"
echo.

REM TLS + HTTP headers (verbose)
echo ========================================
echo [3/5] HTTPS/TLS Test (Verbose)
echo ========================================
curl -Iv https://%HOST%/
echo.

REM IPv4 test
echo ========================================
echo [4/5] IPv4 HTTPS Test
echo ========================================
curl -4 -I https://%HOST%/
echo.

REM IPv6 test
echo ========================================
echo [5/5] IPv6 HTTPS Test
echo ========================================
curl -6 -I https://%HOST%/
echo.

echo ========================================
echo Troubleshooting Hints:
echo ========================================
echo If IPv6 test fails but IPv4 works:
echo   - Likely IPv6 preference issue
echo   - Try setting NODE_OPTIONS="--dns-result-order=ipv4first"
echo   - Restart Cursor after setting the environment variable
echo.
echo If Test-NetConnection fails:
echo   - Check firewall settings
echo   - Check antivirus software
echo   - Check proxy configuration
echo   - Verify DNS resolution
echo ========================================

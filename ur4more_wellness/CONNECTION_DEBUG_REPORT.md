# Connection Debug Report
## UR4MORE Wellness - Flutter Web + Local Gateway

**Date**: Generated automatically  
**Issue**: "Connection failed. If the problem persists, please check your internet connection or VPN."

---

## Root Cause Analysis

### Primary Root Causes (in order of likelihood):

1. **Port Mismatch** ⚠️ **MOST COMMON**
   - **Issue**: API_BASE_URL points to a port where gateway is not listening
   - **Location**: `lib/services/gateway_service.dart` (defaults to `http://127.0.0.1:8080`)
   - **Note**: Flutter web runs on port 59844, Gateway API on port 8080 - these are different by design
   - **Fix**: Use `--dart-define=UR4MORE_API_BASE_URL=http://127.0.0.1:8080` when running Flutter

2. **Gateway Not Running**
   - **Issue**: Gateway server not started or crashed
   - **Detection**: Port 8080 not listening (check with `netstat -ano | findstr :8080`)
   - **Fix**: Start gateway with `uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload`

3. **CORS Blocking Browser Requests**
   - **Issue**: Browser blocks cross-origin requests due to missing CORS headers
   - **Location**: `gateway/app/main.py` CORS middleware
   - **Fix**: Already implemented - dev mode uses regex pattern to allow localhost/127.0.0.1 with any port
   - **Status**: ✅ Fixed in code (dev mode only)

4. **JWT Token Missing/Expired**
   - **Issue**: Gateway requires authentication, but token is missing or expired
   - **Detection**: 401 Unauthorized responses
   - **Fix**: Generate new token and pass via `--dart-define=UR4MORE_DEV_JWT=<token>`

5. **Network/Firewall Blocking**
   - **Issue**: Windows Firewall or antivirus blocking localhost connections
   - **Fix**: Temporarily disable firewall for testing, or add exception for port 8080

---

## Steps to Reproduce

1. Start gateway server:
   ```powershell
   cd gateway
   .venv\Scripts\Activate.ps1
   uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
   ```

2. Run Flutter web WITHOUT specifying base URL:
   ```powershell
   flutter run -d web-server --dart-define=UR4MORE_DEV_JWT=<token>
   ```
   **Expected**: Connection fails because Flutter defaults to port 8000, gateway runs on 8080

3. Open browser console - see CORS or connection errors

---

## Code Changes Made

### 1. Self-Diagnostic Script (`tools/self_diagnose_windows.ps1`)
   - **Purpose**: Automated detection of common connection issues
   - **Checks**:
     - Project structure validation
     - Backend type detection (FastAPI/Flask)
     - Port configuration mismatch
     - Gateway reachability (health endpoint)
     - CORS header detection
     - Provider/external API status
   - **Output**: Clear root cause diagnosis with solution steps

### 2. Enhanced Logging (`lib/services/gateway_service.dart`)
   - **Added**: `_logRequest()`, `_logResponse()`, `_logException()` helper methods
   - **Features**:
     - Logs resolved baseUrl, endpoint path, HTTP method
     - Logs status code and response body (truncated to 500 chars)
     - Logs exception type and error details
     - **Security**: Only logs in debug mode (`kDebugMode` check)
     - **Security**: Never logs full tokens (truncated preview only)
   - **Impact**: Easier debugging of connection issues via Flutter console

### 3. CORS Fix (`gateway/app/main.py`)
   - **Change**: Dev mode now uses regex pattern to allow localhost/127.0.0.1 with any port
   - **Pattern**: `r"http://(localhost|127\.0\.0\.1)(:\d+)?"`
   - **Security**: Only applies in dev mode (`ENV=dev`). Production requires explicit `CORS_ORIGINS` env var
   - **Impact**: Flutter web-server can connect from any dynamic port (e.g., localhost:12345)

### 4. Documentation Updates (`docs/DEV_RUN.md`)
   - **Added**: Self-diagnostic script usage section
   - **Added**: Expected "good" output example
   - **Added**: Root cause explanations
   - **Added**: Flutter console logging guidance

---

## Files Changed

1. ✅ `tools/self_diagnose_windows.ps1` - **NEW FILE**
2. ✅ `lib/services/gateway_service.dart` - Enhanced logging
3. ✅ `gateway/app/main.py` - CORS regex pattern for dev mode
4. ✅ `docs/DEV_RUN.md` - Self-diagnostic script documentation
5. ✅ `CONNECTION_DEBUG_REPORT.md` - **THIS FILE** (root cause report)

---

## Validation Steps

### Run Self-Diagnostic Script:
```powershell
.\tools\self_diagnose_windows.ps1
```

**Expected Output** (if gateway is running correctly):
- ✓ All checks passed
- Port 8080 is listening
- Health endpoint returns 200
- CORS headers present

### Run Flutter with Correct Base URL:
```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 59844 --dart-define=UR4MORE_API_BASE_URL=http://127.0.0.1:8080 --dart-define=UR4MORE_DEV_JWT=<token>
```

**Note**: Flutter web runs on port 59844, Gateway API on port 8080 - these are different ports by design.

**Expected Console Output** (in debug mode):
```
🌐 GatewayService: Resolved base URL: http://127.0.0.1:8080
🌐 [GatewayService] GET http://127.0.0.1:8080/health
📡 [GatewayService] Response: 200 (/health)
```

### Test Gateway Health Endpoint:
```powershell
curl http://127.0.0.1:8080/health
```

**Expected Response**:
```json
{"ok": true, "env": "dev", "redis": false}
```

---

## Security Considerations

1. **CORS Configuration**:
   - ✅ Dev mode: Regex pattern allows localhost/127.0.0.1 (any port)
   - ✅ Production: Requires explicit `CORS_ORIGINS` env var (defaults to "*" if not set)
   - ⚠️ **Action Required**: Set `CORS_ORIGINS` in production to restrict origins

2. **Logging**:
   - ✅ Only logs in debug mode (`kDebugMode`)
   - ✅ Never logs full tokens (truncated preview)
   - ✅ Response bodies truncated to 500 chars

3. **JWT Tokens**:
   - ✅ Dev tokens only used in debug mode (`kReleaseMode` guard)
   - ✅ Never stored in code or committed to git

---

## Next Steps

1. **Immediate**: Run self-diagnostic script to identify current issue
2. **If port mismatch**: Use correct `UR4MORE_API_BASE_URL` in Flutter command
3. **If gateway not running**: Start gateway server
4. **If CORS issues**: Verify gateway is running in dev mode (`ENV=dev`)
5. **If still failing**: Check Flutter console logs for detailed error messages

---

## Quick Reference

### Start Gateway:
```powershell
cd gateway
.venv\Scripts\Activate.ps1
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

### Generate JWT Token:
```powershell
cd gateway
.venv\Scripts\Activate.ps1
python -c "import time, jwt, os; from dotenv import load_dotenv; load_dotenv(); kid=os.getenv('JWT_KID','v1'); sec=os.getenv('JWT_SECRET_V1','dev-secret-change-me'); iss=os.getenv('JWT_ISS','ur4more-gateway'); aud=os.getenv('JWT_AUD','ur4more-apps'); now=int(time.time()); payload={'sub':'debug','iss':iss,'aud':aud,'iat':now,'exp':now+3600}; print(jwt.encode(payload, sec, algorithm='HS256', headers={'kid':kid}))"
```

### Run Flutter Web:
```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 59844 --dart-define=UR4MORE_API_BASE_URL=http://127.0.0.1:8080 --dart-define=UR4MORE_DEV_JWT=<TOKEN>
```

**Ports:**
- Flutter Web: `http://127.0.0.1:59844` (user interface)
- Gateway API: `http://127.0.0.1:8080` (backend services)

### Run Diagnostic:
```powershell
.\tools\self_diagnose_windows.ps1
```


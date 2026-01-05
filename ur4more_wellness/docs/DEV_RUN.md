# Development Run Guide

This guide explains how to run the UR4MORE Wellness application in development mode.

## Prerequisites

- Python 3.8+ installed
- Flutter SDK installed
- Gateway dependencies installed (`pip install -r gateway/requirements.txt`)

## Step 1: Start the Gateway Server

Open a terminal and navigate to the gateway directory:

```powershell
cd gateway
python -m uvicorn app.main:app --host 127.0.0.1 --port 8080 --reload
```

The gateway will start on `http://127.0.0.1:8080`.

Verify it's running by visiting `http://127.0.0.1:8080/health` in your browser.

## Step 2: Run Flutter Web Server

Open a **new** terminal in the repository root and run:

```powershell
.\run_flutter.ps1
```

Or if you need to provide a JWT token for development:

```powershell
.\run_flutter.ps1 -JwtToken "your-token-here"
```

Or if you need to override the API base URL:

```powershell
.\run_flutter.ps1 -ApiBaseUrl "http://127.0.0.1:8080" -JwtToken "your-token-here"
```

The Flutter web server will start on `http://127.0.0.1:59844`.

**Important:** The Flutter web app runs on port **59844**, while the Gateway API runs on port **8080**. These are different ports by design:
- **59844** = Flutter web application (user interface)
- **8080** = Gateway API server (backend services)

The Flutter app communicates with the Gateway API using the `UR4MORE_API_BASE_URL` environment variable (default: `http://127.0.0.1:8080`).

**Note:** If Edge device fails to launch automatically, the script uses `-d web-server` flag. You can manually open `http://127.0.0.1:59844` in your browser.

## Step 3: Verify Setup

In a third terminal, run the self-diagnosis script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\self_diagnose_windows.ps1
```

This will check:
- Gateway ports (8080 and 8000)
- Gateway health and manifest endpoints
- CORS configuration
- Flutter base URL configuration

## Troubleshooting

### Gateway not responding

- Check that the gateway process is running
- Verify port 8080 is not blocked by firewall
- Check gateway logs for errors

### Flutter cannot connect to gateway

- Ensure gateway is running on port 8080
- Verify `UR4MORE_API_BASE_URL` matches gateway port (default: `http://127.0.0.1:8080`)
- Remember: Flutter web runs on port 59844, Gateway API on port 8080 - this is expected
- Run `self_diagnose_windows.ps1` to check configuration

### CORS errors in browser

- Gateway should automatically allow `http://127.0.0.1:59844` in dev mode
- Check gateway logs for CORS-related errors
- Verify `ENV=dev` is set in gateway environment

### Edge device fails to launch

- The script uses `-d web-server` to avoid device launch issues
- Manually open `http://127.0.0.1:59844` in your browser
- Ensure Flutter web support is enabled: `flutter config --enable-web`

## Quick Reference

**Start Gateway (port 8080):**
```powershell
cd gateway
python -m uvicorn app.main:app --host 127.0.0.1 --port 8080 --reload
```

**Start Flutter (port 59844):**
```powershell
.\run_flutter.ps1
```

**Manual Flutter command (if needed):**
```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 59844 --dart-define=UR4MORE_API_BASE_URL=http://127.0.0.1:8080
```

**Diagnose:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\self_diagnose_windows.ps1
```

**Port Summary:**
- Flutter Web: `http://127.0.0.1:59844` (user interface)
- Gateway API: `http://127.0.0.1:8080` (backend services)
- These are different ports by design - this is normal and expected

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

## Testing Connection Diagnostics

The app includes comprehensive connection diagnostics to help debug gateway connectivity issues.

### Testing Gateway Failure Scenarios

#### 1. Test with Gateway Down (Local Development)

1. **Stop the gateway server** (Ctrl+C in the gateway terminal)
2. **Run the Flutter app**:
   ```powershell
   .\run_flutter.ps1
   ```
3. **Expected behavior:**
   - App loads successfully (no crash)
   - Error banner appears at top: "Gateway request failed: [kind] [url]"
   - App falls back to demo mode with local fallback data
   - In debug mode: "Copy details" button available to copy full error info

#### 2. Test CORS Errors (Web Only)

1. **Run Flutter web app** pointing to a different origin:
   ```powershell
   flutter run -d web-server --web-hostname 127.0.0.1 --web-port 59844 --dart-define=UR4MORE_API_BASE_URL=http://localhost:8080
   ```
2. **Expected behavior:**
   - Error banner shows: "Gateway not reachable from this origin" (CORS error)
   - Error kind is detected as `cors`
   - Web origin is logged in debug console

#### 3. Test Auto Demo Mode on HTTPS Origin

1. **Deploy to GitHub Pages** (or any HTTPS origin)
2. **Expected behavior:**
   - Startup health probe runs automatically
   - If gateway unreachable AND origin is HTTPS → Auto Demo Mode enabled
   - Banner shows: "Demo Mode: gateway offline or not reachable from this origin"
   - App uses local fallback data

#### 4. Test Error Types

The app categorizes errors into these types:
- **CORS**: Cross-origin request blocked (common on GitHub Pages)
- **DNS**: Cannot resolve gateway hostname
- **Refused**: Connection refused (gateway not running)
- **Timeout**: Request timed out (gateway slow/unresponsive)
- **Unauthorized**: 401/403 HTTP status (authentication required)
- **HTTP**: Other HTTP errors (4xx/5xx)
- **Unknown**: Unrecognized error

#### 5. View Error Details (Debug Mode)

1. **Run in debug mode**:
   ```powershell
   flutter run -d web-server --web-hostname 127.0.0.1 --web-port 59844
   ```
2. **When error occurs:**
   - Error banner shows short message
   - Click "Copy details" button (debug mode only)
   - Full error details copied to clipboard:
     - URL
     - Error kind
     - Status code (if HTTP error)
     - Web origin (if web platform)
     - Full exception message

### Verifying Diagnostics Work

1. **Check debug console** for diagnostic logs:
   - `🌐 GatewayService: Startup - Base URL: [url]`
   - `🌐 GatewayService: Web origin: [origin]` (web only)
   - `❌ GatewayService: Exception during [method]`
   - `❌ GatewayService: Exception type: [type]`
   - `❌ GatewayService: Target URL: [url]`

2. **Verify error banner appears** in MainScaffold when `GatewayService.lastError != null`

3. **Verify graceful degradation:**
   - App never crashes
   - Fallback data is used
   - UI remains functional

### Security Notes

- **JWT tokens are never fully logged** - only first 20 characters shown in debug logs
- **Debug-only logging** - All diagnostic prints are wrapped in `kDebugMode` checks
- **No sensitive data** in error messages shown to users

<<<<<<< HEAD
=======

## Deploy to GitHub Pages

The Flutter web app is automatically deployed to GitHub Pages on every push to `main` branch.

### Automatic Deployment

The GitHub Actions workflow (`.github/workflows/deploy-gh-pages.yml`) automatically:
1. Builds the Flutter web app with the correct base href
2. Deploys to the `gh-pages` branch
3. Makes the app available at: `https://louisworkapp.github.io/ur4more-whole-wellness/`

### Manual Setup (One-time)

If Pages isn't enabled yet, follow these steps:

1. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` / `root`
   - Click Save

2. **Wait for first deployment:**
   - After pushing to `main`, the workflow will run automatically
   - Check Actions tab to see deployment status
   - Once complete, the app will be live at the URL above

### Expected Public URL

After deployment, the app will be available at:
```
https://louisworkapp.github.io/ur4more-whole-wellness/
```

### Demo Mode

When deployed to GitHub Pages, the app runs in **Demo Mode** because the gateway backend isn't available. The app will:
- Show a small "Demo Mode (gateway offline)" banner
- Use local fallback data for quotes, scriptures, and content
- Allow full UI/UX exploration without backend connectivity

This is perfect for UI/UX review and flow exploration.

### Manual Deployment (if needed)

To manually trigger deployment:
1. Go to repository Actions tab
2. Select "Deploy to GitHub Pages" workflow
3. Click "Run workflow" → "Run workflow"

### Troubleshooting Pages Deployment

- **404 errors on refresh:** The `404.html` file handles routing redirects automatically
- **Assets not loading:** Ensure base href is set to `/ur4more-whole-wellness/` in workflow
- **Build fails:** Check Actions logs for Flutter build errors
>>>>>>> main-remote

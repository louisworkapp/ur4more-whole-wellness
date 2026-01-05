# Cursor Windows Connection Fix

## Symptom

Cursor shows "Connection failed... check internet/VPN" error messages even though:
- Your internet connection works fine
- You can browse websites normally
- Other applications connect successfully

## Cause

This issue occurs when IPv6 DNS resolution fails on Windows, but IPv4 works correctly. Node.js (which powers Cursor/Electron) may attempt to resolve hostnames using IPv6 first. When IPv6 DNS resolution fails, Node.js cannot establish connections even though IPv4 connectivity is working.

## Fix

Force Node.js to prefer IPv4 over IPv6 by setting the `NODE_OPTIONS` environment variable:

### Step 1: Set the environment variable

Open Command Prompt (CMD) as Administrator and run:

```cmd
setx NODE_OPTIONS "--dns-result-order=ipv4first"
```

### Step 2: Restart Cursor

**Important:** You must fully quit Cursor (not just close the window) and reopen it for the change to take effect. The `setx` command sets the variable for future sessions, not the current one.

## Verification

After restarting Cursor, you can verify the fix by testing connectivity:

```cmd
curl -4 -I https://api.openai.com
curl -6 -I https://api.openai.com
```

**Expected results after the fix:**
- IPv4 test (`curl -4`) should succeed
- IPv6 test (`curl -6`) may still fail with "could not resolve host" - this is OK and expected

The key is that Node.js will now prefer IPv4, so even if IPv6 DNS fails, connections will work via IPv4.

## Rollback

If you need to remove this setting (for example, if IPv6 is fixed later), run:

```cmd
reg delete "HKCU\Environment" /v NODE_OPTIONS /f
```

Then restart Cursor again.

## Additional Diagnostics

For more detailed connectivity diagnostics, run:

```cmd
tools\self_diagnose_windows.ps1 -Host api.openai.com
```

This will check DNS resolution, port connectivity, and both IPv4/IPv6 connectivity.


# PowerShell Parameter Parsing Debug Guide

This document explains how PowerShell handles parameter parsing and demonstrates different invocation methods for `run_flutter.ps1`.

## Understanding PowerShell Parameter Parsing

PowerShell has several ways to handle parameters:

1. **Named Parameters**: `-ParameterName Value`
2. **Positional Parameters**: Values without parameter names (position matters)
3. **Switch Parameters**: Boolean flags without values
4. **Parameter Sets**: Different parameter combinations

## Test Script

Use `test_param_parsing.ps1` to debug parameter parsing:

```powershell
# Run with no parameters
.\test_param_parsing.ps1

# Run with JWT token
.\test_param_parsing.ps1 -JwtToken "your-token-here"

# Run with debug output
.\test_param_parsing.ps1 -Debug
```

## Invocation Methods for run_flutter.ps1

### Method 1: No Parameters (Default)
```powershell
.\run_flutter.ps1
```
- `JwtToken` will be empty string `""`
- Flutter runs without dev JWT token

### Method 2: Named Parameter (Recommended)
```powershell
.\run_flutter.ps1 -JwtToken "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```
- Explicitly sets `JwtToken` parameter
- Most reliable method
- Works with spaces in token (if quoted)

### Method 3: Named Parameter with Equals
```powershell
.\run_flutter.ps1 -JwtToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```
- Alternative syntax for named parameters
- Equally reliable as Method 2

### Method 4: Positional Parameter
```powershell
.\run_flutter.ps1 "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```
- Uses position (first parameter = JwtToken)
- Works because `Position=0` is set in param block
- Less explicit but shorter

### Method 5: With Debug Flag
```powershell
.\run_flutter.ps1 -JwtToken "token" -Debug
```
- Shows detailed parameter parsing information
- Useful for troubleshooting

### Method 6: Empty String Explicitly
```powershell
.\run_flutter.ps1 -JwtToken ""
```
- Explicitly passes empty string
- Useful to test empty string handling

## Common Issues and Solutions

### Issue 1: Token Contains Special Characters
**Problem**: JWT tokens may contain characters that PowerShell interprets specially (`$`, `` ` ``, `"`, etc.)

**Solution**: Always quote the token:
```powershell
.\run_flutter.ps1 -JwtToken "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Issue 2: Token Contains Spaces
**Problem**: Unquoted tokens with spaces are split into multiple arguments

**Solution**: Quote the entire token:
```powershell
.\run_flutter.ps1 -JwtToken "token with spaces"
```

### Issue 3: Token Starts with Dash
**Problem**: PowerShell may interpret token as a parameter name

**Solution**: Use `--` to indicate end of parameters, or quote:
```powershell
.\run_flutter.ps1 -JwtToken "--token-starting-with-dash"
```

### Issue 4: Execution Policy Blocks Script
**Problem**: PowerShell execution policy prevents script execution

**Solution**: 
```powershell
# Check current policy
Get-ExecutionPolicy

# For current session only
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Or run with bypass
powershell -ExecutionPolicy Bypass -File .\run_flutter.ps1 -JwtToken "token"
```

### Issue 5: Parameters Not Parsing Correctly
**Problem**: Parameters appear empty or incorrect

**Solution**: Use debug mode to see what PowerShell received:
```powershell
.\run_flutter.ps1 -JwtToken "token" -Debug
```

## Testing Different Scenarios

### Test 1: Verify Parameter Reception
```powershell
# Should show JWT token in debug output
.\run_flutter.ps1 -JwtToken "test123" -Debug
```

### Test 2: Verify Empty String Handling
```powershell
# Should show empty string, not null
.\run_flutter.ps1 -JwtToken "" -Debug
```

### Test 3: Verify No Parameter Default
```powershell
# Should use default empty string
.\run_flutter.ps1 -Debug
```

### Test 4: Verify Positional Parameter
```powershell
# Should parse first argument as JwtToken
.\run_flutter.ps1 "test123" -Debug
```

## PowerShell Parameter Binding Order

PowerShell binds parameters in this order:
1. **By Name** (exact match)
2. **By Position** (if Position attribute set)
3. **By Pipeline** (if using pipeline)
4. **By Partial Name** (if no exact match, uses partial matching)

## Best Practices

1. **Always quote string parameters** containing special characters
2. **Use named parameters** for clarity and reliability
3. **Test with -Debug flag** when troubleshooting
4. **Check PSBoundParameters** to see what was actually bound
5. **Use Parameter attributes** to make behavior explicit:
   - `[Parameter(Mandatory=$false)]` - Optional parameter
   - `[Parameter(Position=0)]` - Positional parameter
   - `[ValidateNotNullOrEmpty()]` - Validation

## Debugging Commands

```powershell
# Show all bound parameters
$PSBoundParameters

# Show all arguments (raw)
$args

# Show parameter value
$JwtToken

# Check if parameter was provided
$PSBoundParameters.ContainsKey('JwtToken')

# Check if parameter is empty/null
[string]::IsNullOrWhiteSpace($JwtToken)
```

## Example: Full Debug Session

```powershell
# 1. Test with no parameters
.\run_flutter.ps1 -Debug

# 2. Test with token
.\run_flutter.ps1 -JwtToken "test-token-123" -Debug

# 3. Test with empty string
.\run_flutter.ps1 -JwtToken "" -Debug

# 4. Test positional
.\run_flutter.ps1 "test-token-123" -Debug

# 5. Compare outputs to understand parsing behavior
```

## Related Files

- `run_flutter.ps1` - Main Flutter run script
- `test_param_parsing.ps1` - Parameter parsing test script
- `tools/public_safety_check.ps1` - Example with switch parameters
- `tools/self_diagnose_windows.ps1` - Example with no parameters


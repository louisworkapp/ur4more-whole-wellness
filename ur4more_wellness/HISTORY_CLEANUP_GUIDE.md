# Git History Cleanup Guide

**⚠️ READ THIS BEFORE PROCEEDING ⚠️**

The JWT token is still in git history (commit `3a599f24dd67f9e46b29f9d08c32fd42a615b475`). 
Follow these steps to remove it.

## Prerequisites

1. **Install git-filter-repo:**
   ```bash
   # Windows (with pip)
   pip install git-filter-repo
   
   # Or via Chocolatey
   choco install git-filter-repo
   
   # Mac
   brew install git-filter-repo
   
   # Linux
   sudo apt install git-filter-repo  # or use pip
   ```

2. **Backup your repository:**
   ```bash
   # Create a backup branch
   git branch backup-before-history-cleanup
   ```

3. **Coordinate with your team** - this will rewrite history and require everyone to re-clone

## Option A: Replace Token String (RECOMMENDED)

This removes only the token, preserving file history.

### Steps:

1. **Create replacement file:**
   
   **Windows (PowerShell):**
   ```powershell
   # Replace YOUR_ACTUAL_TOKEN_HERE with the token found in git history
   "YOUR_ACTUAL_TOKEN_HERE==>REDACTED_JWT_TOKEN" | Out-File -FilePath replacements.txt -Encoding utf8
   ```
   
   **Linux/Mac:**
   ```bash
   # Replace YOUR_ACTUAL_TOKEN_HERE with the token found in git history
   echo "YOUR_ACTUAL_TOKEN_HERE==>REDACTED_JWT_TOKEN" > replacements.txt
   ```

2. **Run git-filter-repo:**
   ```bash
   git filter-repo --replace-text replacements.txt
   ```

3. **Verify cleanup:**
   ```bash
   gitleaks detect -v --config gitleaks.toml
   ```
   *(Should show no leaks)*

4. **Force push (after coordinating with team):**
   ```bash
   git push --force --all --tags
   ```

5. **Clean up:**
   ```bash
   rm replacements.txt  # or del replacements.txt on Windows
   ```

## Option B: Remove File from History

Only use if Option A doesn't work. This removes the entire file from history.

```bash
git filter-repo --path lib/services/gateway_service.dart --invert-paths

# Verify
gitleaks detect -v --config gitleaks.toml

# Force push (after coordinating with team)
git push --force --all --tags
```

## After Cleanup

1. **Notify all team members** to re-clone the repository:
   ```bash
   # They should:
   git clone <repository-url>
   # (Not git pull - their local repo will be out of sync)
   ```

2. **Rotate the exposed JWT token** immediately - it was in git history

3. **Update CI/CD pipelines** if they reference specific commits

4. **Update any documentation** that references commit hashes

## Verification Commands

After cleanup, verify everything is clean:

```bash
# Check for tokens in working tree (should return nothing)
git grep -n "eyJ"

# Run gitleaks (should show no leaks)
gitleaks detect -v --config gitleaks.toml

# Check git log (old commit should be gone)
git log --oneline --all | grep 3a599f24
```

## Rollback (if something goes wrong)

If you need to rollback:

```bash
# Restore from backup branch
git reset --hard backup-before-history-cleanup
git push --force --all --tags
```


# Security Guidelines

This document outlines security practices for the UR4MORE Wellness repository, including secret management and scanning.

## Secret Detection

We use automated tools to prevent secrets from being committed to the repository:

- **Gitleaks**: Scans commits and working tree for secrets
- **Trufflehog**: Scans for high-entropy strings and verified secrets
- **Pre-commit hooks**: Automatically runs gitleaks before each commit

## Pre-commit Hook Setup

A pre-commit hook is provided at `.git/hooks/pre-commit` that runs gitleaks on staged changes.

### Installation

**Windows (PowerShell):**
```powershell
# Make the hook executable (if using Git Bash)
# Or ensure Git is configured to use the hook
git config core.hooksPath .git/hooks
```

**Linux/Mac:**
```bash
chmod +x .git/hooks/pre-commit
```

### Manual Execution

You can manually run the pre-commit hook:
```bash
.git/hooks/pre-commit
```

Or run gitleaks directly:
```bash
gitleaks protect --staged --verbose --config gitleaks.toml
```

## Development Token Configuration

The app uses JWT tokens for gateway authentication. **Never commit tokens to the repository.**

### For Development

Use the `--dart-define` flag when running the app:
```bash
flutter run --dart-define=UR4MORE_DEV_JWT=your_token_here
```

**Important:** 
- Dev tokens are **only** used in debug mode (checked via `kReleaseMode`)
- Release builds will **not** use dev tokens
- Store tokens in environment variables or local config files (gitignored)

### Generating Tokens

Use the gateway's token generation script:
```bash
cd gateway
python generate_token.py
```

## Running Secret Scans

### Gitleaks (Recommended for Commits)
```bash
# Scan staged changes
gitleaks protect --staged --verbose --config gitleaks.toml

# Scan entire repository
gitleaks detect -v --config gitleaks.toml

# Scan specific commit
gitleaks detect -v --commit <commit-hash>
```

### Trufflehog (High-Entropy Detection)
```bash
# Scan entire repository
trufflehog git file://. --only-verified

# Scan specific directory
trufflehog filesystem . --only-verified
```

## Ignored Files

The following files/directories are excluded from secret scans:

- **`.gitignore`**: Standard ignore patterns (build artifacts, dependencies, etc.)
- **`.trufflehogignore`**: Xcode metadata files (UUIDs in `.pbxproj`, `.xcscheme`)
- **`gitleaks.toml`**: Test files and example patterns

See `.gitignore` and `.trufflehogignore` for full lists.

## What to Do If You Find a Secret

1. **DO NOT commit** the file containing the secret
2. **Rotate the secret** immediately (if it's a real secret)
3. **Remove the secret** from your working directory
4. **Clean git history** if the secret was already committed (see below)

## Git History Cleanup

If a secret was committed to git history, it must be removed. The JWT token was found in commit `3a599f24dd67f9e46b29f9d08c32fd42a615b475` in file `lib/services/gateway_service.dart`.

**Prerequisites:**
- Install `git-filter-repo`: `pip install git-filter-repo` or `brew install git-filter-repo`
- **Backup your repository** before proceeding
- Coordinate with your team - this will rewrite history

**Option A: Replace specific token string (RECOMMENDED - Safer)**

Create a replacement file:
```bash
# Create replacement file (replace OLD_TOKEN with the actual leaked token)
echo "OLD_TOKEN==>REDACTED_JWT_TOKEN" > /tmp/replacements.txt
# Or use the known token from the commit:
# echo "eyJhbGciOiJIUzI1NiIsImtpZCI6InYxIiwidHlwIjoiSldUIn0.eyJzdWIiOiJkZWJ1ZyIsImlzcyI6InVyNG1vcmUtZ2F0ZXdheSIsImF1ZCI6InVyNG1vcmUtYXBwcyIsImlhdCI6MTczNTA0NDgwMCwiZXhwIjoxNzM1NjQ5NjAwfQ.8BnMneRLnfOvTaZwbGwyEwOhbgLwdOH6nNTBz977n8Q==>REDACTED_JWT_TOKEN" > /tmp/replacements.txt

# Run filter-repo
git filter-repo --replace-text /tmp/replacements.txt

# Clean up
rm /tmp/replacements.txt
```

**Option B: Remove file from history (Use only if Option A doesn't work)**

This removes the entire file from history at the commit where the token was added:
```bash
git filter-repo --path lib/services/gateway_service.dart --invert-paths
```

**After cleanup:**
1. Verify the secret is gone: `gitleaks detect -v`
2. Force push to remote: `git push --force --all --tags`
3. **Notify all team members** to re-clone the repository (their local copies will be out of sync)
4. **Rotate the exposed secret** immediately - it's been in git history
5. Update any CI/CD systems or documentation that referenced the old repository state

**⚠️ Critical Warning:** 
- History rewrites are **destructive** and cannot be undone
- All team members must re-clone after you force-push
- Any forks or clones will have conflicts
- Coordinate this with your entire team before executing

## Configuration Files

- **`gitleaks.toml`**: Gitleaks configuration with custom JWT detection rules
- **`.trufflehogignore`**: Patterns to exclude from Trufflehog scans
- **`.gitignore`**: Files/directories excluded from git tracking

## Additional Resources

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Trufflehog Documentation](https://github.com/trufflesecurity/trufflehog)
- [Git Filter-Repo Documentation](https://github.com/newren/git-filter-repo)


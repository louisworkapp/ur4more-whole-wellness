# Public Launch Safety Checklist

This checklist ensures the codebase is safe for public release. Complete all items before launching.

## Secrets Scanning

- [ ] Run `tools\public_safety_check.ps1 -Strict` locally
- [ ] Verify no secrets detected in codebase
- [ ] Check CI workflow passes public-launch-gate
- [ ] Review any warnings or false positives

**Command:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\public_safety_check.ps1 -Strict
```

## Git History Cleanup

- [ ] Audit git history for sensitive data using `git log --all --full-history --source`
- [ ] Use `git filter-branch` or BFG Repo-Cleaner if secrets found in history
- [ ] Verify cleaned history with `gitleaks detect --log-opts="--all"`
- [ ] Consider starting fresh history if cleanup is complex

**Tools:**
- `gitleaks detect --log-opts="--all"` - scan entire history
- BFG Repo-Cleaner - remove secrets from history
- `git filter-branch` - alternative history rewriting tool

## CI Gate Verification

- [ ] Verify `.github\workflows\public-launch-gate.yml` exists and is active
- [ ] Test workflow runs on push to main/master/develop branches
- [ ] Confirm workflow fails appropriately on secret detection
- [ ] Check workflow installs gitleaks and trufflehog correctly

**Test:**
```powershell
# Create a test PR or push to trigger workflow
git checkout -b test-ci-gate
# Make a commit
git push origin test-ci-gate
# Verify workflow runs in GitHub Actions
```

## File Permissions

- [ ] Review `.gitignore` excludes sensitive files
- [ ] Verify `env.json`, `.env`, and similar files are gitignored
- [ ] Check that build artifacts and temporary files are excluded
- [ ] Ensure no credentials files are tracked

**Check:**
```powershell
git ls-files | Select-String -Pattern "\.env|secret|credential|password"
```

## Environment Files

- [ ] Verify `env.json` is in `.gitignore`
- [ ] Check `gateway/env.example` or similar template exists
- [ ] Ensure no real credentials in example/template files
- [ ] Document required environment variables in README

**Files to check:**
- `env.json`
- `gateway/.env`
- `gateway/env.example`
- Any `*.example` or `*.template` files

## Release Mode Guards

- [ ] Verify Flutter release builds do not use dev tokens
- [ ] Check `gateway_service.dart` guards against release mode
- [ ] Ensure debug-only code paths are disabled in release
- [ ] Test release build does not expose debug endpoints

**Key checks:**
- `kReleaseMode` guards in Dart code
- Dev JWT tokens only used in debug mode
- No hardcoded credentials in release builds

## API Keys and External Services

- [ ] Audit all external API integrations
- [ ] Verify API keys are not hardcoded
- [ ] Check that API keys use environment variables
- [ ] Ensure production API keys are separate from dev keys

## Documentation Review

- [ ] Review all markdown files for accidental secret exposure
- [ ] Check code examples do not contain real tokens
- [ ] Verify README files are safe for public viewing
- [ ] Remove any internal-only documentation

## Final Verification

- [ ] Run full test suite
- [ ] Perform manual security scan
- [ ] Review recent commits for sensitive data
- [ ] Get second pair of eyes on security-critical changes

**Final check command:**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\public_safety_check.ps1 -Strict -CI
```

## Post-Launch Monitoring

- [ ] Set up secret scanning alerts (GitHub Advanced Security, etc.)
- [ ] Monitor for accidental secret commits
- [ ] Have rollback plan ready
- [ ] Document incident response procedures

---

**Remember:** When in doubt, err on the side of caution. It's better to delay launch than expose sensitive data.

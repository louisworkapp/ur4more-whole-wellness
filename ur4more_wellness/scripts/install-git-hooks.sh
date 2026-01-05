#!/bin/bash
# Install git hooks for secret scanning
# Run this script after cloning the repository

set -e

echo "Installing git hooks..."

HOOKS_DIR=".git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

# Check if .git/hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "Error: .git/hooks directory not found. Are you in a git repository?"
    exit 1
fi

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo "Warning: gitleaks is not installed."
    echo "Install it from: https://github.com/gitleaks/gitleaks"
    echo "The pre-commit hook will still be installed but will fail until gitleaks is available."
fi

# Make pre-commit hook executable
if [ -f "$PRE_COMMIT_HOOK" ]; then
    chmod +x "$PRE_COMMIT_HOOK"
    echo "Pre-commit hook installed and made executable at $PRE_COMMIT_HOOK"
else
    echo "Warning: Pre-commit hook not found at $PRE_COMMIT_HOOK"
    echo "Make sure the hook file exists in .git/hooks/"
fi

echo ""
echo "Git hooks installation complete!"
echo "The pre-commit hook will now run gitleaks on every commit."
echo "To skip it (not recommended): git commit --no-verify"


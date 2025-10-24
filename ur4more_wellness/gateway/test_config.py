#!/usr/bin/env python3
"""
Test script to verify configuration and allowlist
"""
import sys
import os

# Add the app directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.config import settings
from app.services.allowlist import ALLOWLISTED_PROVIDERS

def test_configuration():
    print("Testing Configuration")
    print(f"ENABLE_EXTERNAL: {settings.ENABLE_EXTERNAL}")
    print(f"ENV: {settings.ENV}")
    print(f"PORT: {settings.PORT}")
    
    print("\nAllowlisted Providers:")
    for name, config in ALLOWLISTED_PROVIDERS.items():
        enabled = config.get('enabled', False)
        status = "ENABLED" if enabled else "DISABLED"
        print(f"  {name}: {status}")
        print(f"    Base URL: {config.get('base_url', 'N/A')}")
        print(f"    License: {config.get('license', 'N/A')}")
        print(f"    Endpoints: {config.get('endpoints', {})}")
        print()

if __name__ == "__main__":
    test_configuration()

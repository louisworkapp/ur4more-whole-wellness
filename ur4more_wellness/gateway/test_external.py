#!/usr/bin/env python3
"""
Test script to verify external providers are working
"""
import asyncio
import sys
import os

# Add the app directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.providers.quotes_external import fetch_quotes_external
from app.config import settings

async def test_external_providers():
    print("Testing External Providers")
    print(f"ENABLE_EXTERNAL: {settings.ENABLE_EXTERNAL}")
    
    if not settings.ENABLE_EXTERNAL:
        print("External providers are disabled")
        return
    
    print("External providers are enabled")
    
    # Test fetching quotes
    print("\nFetching external quotes...")
    try:
        quotes = await fetch_quotes_external(
            allow_faith=False,  # Test secular quotes
            topic="wisdom",
            limit=5
        )
        
        print(f"Successfully fetched {len(quotes)} quotes:")
        for i, quote in enumerate(quotes, 1):
            print(f"  {i}. \"{quote.text[:50]}...\" - {quote.author} (Source: {quote.source})")
            
    except Exception as e:
        print(f"Error fetching quotes: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_external_providers())

#!/usr/bin/env python3
"""
Test script specifically for external scripture providers
"""
import asyncio
import sys
import os

# Add the app directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.providers.scripture_external import fetch_scripture_external, get_fallback_scripture
from app.config import settings

async def test_scripture_providers():
    print("=" * 60)
    print("Testing External Scripture Providers for 365-Day Rotation")
    print("=" * 60)
    print(f"ENABLE_EXTERNAL: {settings.ENABLE_EXTERNAL}")
    print()
    
    if not settings.ENABLE_EXTERNAL:
        print("External providers are disabled")
        return
    
    # Test external scripture providers
    print("Testing External Scripture Providers...")
    print("-" * 40)
    try:
        passages = await fetch_scripture_external(
            allow_faith=True,  # Test faith content
            theme="strength",
            limit=5
        )
        
        print(f"Successfully fetched {len(passages)} scripture passages:")
        for i, passage in enumerate(passages, 1):
            print(f"  {i}. {passage.ref}")
            print(f"     \"{passage.verses[0].t}\"")
            print(f"     Action: {passage.actNow}")
            print(f"     Source: {passage.source}")
            print()
            
    except Exception as e:
        print(f"Error fetching external scripture: {e}")
        import traceback
        traceback.print_exc()
    
    # Test fallback scripture
    print("Testing Fallback Scripture...")
    print("-" * 40)
    try:
        fallback_passage = await get_fallback_scripture("peace")
        print(f"Fallback scripture: {fallback_passage.ref}")
        print(f"\"{fallback_passage.verses[0].t}\"")
        print(f"Action: {fallback_passage.actNow}")
        print(f"Source: {fallback_passage.source}")
        
    except Exception as e:
        print(f"Error fetching fallback scripture: {e}")
    
    print()
    print("=" * 60)
    print("Scripture Provider Test Complete!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(test_scripture_providers())

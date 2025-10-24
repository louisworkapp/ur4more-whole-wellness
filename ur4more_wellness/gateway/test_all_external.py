#!/usr/bin/env python3
"""
Comprehensive test script for all external providers (quotes, scripture, prayers, devotionals)
"""
import asyncio
import sys
import os

# Add the app directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.providers.quotes_external import fetch_quotes_external
from app.providers.scripture_external import fetch_scripture_external, get_fallback_scripture
from app.providers.devotional_external import fetch_devotionals_external, get_fallback_prayer, get_fallback_devotional
from app.config import settings

async def test_all_external_providers():
    print("=" * 60)
    print("Testing All External Providers for 365-Day Content Rotation")
    print("=" * 60)
    print(f"ENABLE_EXTERNAL: {settings.ENABLE_EXTERNAL}")
    print()
    
    if not settings.ENABLE_EXTERNAL:
        print("External providers are disabled")
        return
    
    # Test 1: External Quotes
    print("1. Testing External Quotes...")
    print("-" * 30)
    try:
        quotes = await fetch_quotes_external(
            allow_faith=False,  # Test secular quotes
            topic="wisdom",
            limit=3
        )
        
        print(f"Successfully fetched {len(quotes)} quotes:")
        for i, quote in enumerate(quotes, 1):
            print(f"  {i}. \"{quote.text[:60]}...\" - {quote.author} (Source: {quote.source})")
            
    except Exception as e:
        print(f"Error fetching quotes: {e}")
    
    print()
    
    # Test 2: External Scripture
    print("2. Testing External Scripture...")
    print("-" * 30)
    try:
        passages = await fetch_scripture_external(
            allow_faith=True,  # Test faith content
            theme="strength",
            limit=2
        )
        
        print(f"Successfully fetched {len(passages)} scripture passages:")
        for i, passage in enumerate(passages, 1):
            print(f"  {i}. {passage.ref}")
            print(f"     \"{passage.verses[0].t[:60]}...\"")
            print(f"     Action: {passage.actNow}")
            print(f"     Source: {passage.source}")
            
    except Exception as e:
        print(f"Error fetching scripture: {e}")
    
    print()
    
    # Test 3: Fallback Scripture
    print("3. Testing Fallback Scripture...")
    print("-" * 30)
    try:
        fallback_passage = await get_fallback_scripture("peace")
        print(f"Fallback scripture: {fallback_passage.ref}")
        print(f"\"{fallback_passage.verses[0].t}\"")
        print(f"Action: {fallback_passage.actNow}")
        
    except Exception as e:
        print(f"Error fetching fallback scripture: {e}")
    
    print()
    
    # Test 4: External Prayers
    print("4. Testing External Prayers...")
    print("-" * 30)
    try:
        prayers = await fetch_devotionals_external(
            allow_faith=True,
            theme="strength",
            limit=2
        )
        
        print(f"Successfully fetched {len(prayers)} prayers:")
        for i, prayer in enumerate(prayers, 1):
            print(f"  {i}. {prayer.get('title', 'Untitled Prayer')}")
            print(f"     \"{prayer.get('prayer', '')[:60]}...\"")
            print(f"     Theme: {prayer.get('theme', 'N/A')}")
            
    except Exception as e:
        print(f"Error fetching prayers: {e}")
    
    print()
    
    # Test 5: Fallback Prayer
    print("5. Testing Fallback Prayer...")
    print("-" * 30)
    try:
        fallback_prayer = await get_fallback_prayer("peace")
        print(f"Fallback prayer: {fallback_prayer.get('title', 'Untitled')}")
        print(f"\"{fallback_prayer.get('prayer', '')[:80]}...\"")
        print(f"Theme: {fallback_prayer.get('theme', 'N/A')}")
        
    except Exception as e:
        print(f"Error fetching fallback prayer: {e}")
    
    print()
    
    # Test 6: Fallback Devotional
    print("6. Testing Fallback Devotional...")
    print("-" * 30)
    try:
        fallback_devotional = await get_fallback_devotional("love")
        print(f"Fallback devotional: {fallback_devotional.get('title', 'Untitled')}")
        print(f"Scripture: {fallback_devotional.get('scripture', 'N/A')}")
        print(f"Reflection: {fallback_devotional.get('reflection', '')[:80]}...")
        print(f"Theme: {fallback_devotional.get('theme', 'N/A')}")
        
    except Exception as e:
        print(f"Error fetching fallback devotional: {e}")
    
    print()
    print("=" * 60)
    print("365-Day Content Rotation Test Complete!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(test_all_external_providers())

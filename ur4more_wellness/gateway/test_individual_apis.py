#!/usr/bin/env python3
"""
Test individual Bible APIs to see which ones are working
"""
import asyncio
import httpx

async def test_individual_apis():
    print("=" * 60)
    print("Testing Individual Bible APIs")
    print("=" * 60)
    
    # Test 1: Bible.org Labs API
    print("1. Testing Bible.org Labs API...")
    print("-" * 30)
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # Test daily verse
            response = await client.get("https://labs.bible.org/api/?passage=votd&formatting=plain")
            if response.status_code == 200:
                print(f"Daily verse: {response.text}")
            else:
                print(f"Daily verse failed: {response.status_code}")
            
            # Test random verse
            response = await client.get("https://labs.bible.org/api/?passage=random&formatting=plain")
            if response.status_code == 200:
                print(f"Random verse: {response.text}")
            else:
                print(f"Random verse failed: {response.status_code}")
    except Exception as e:
        print(f"Bible.org Labs API error: {e}")
    
    print()
    
    # Test 2: Bible API by wldeh
    print("2. Testing Bible API by wldeh...")
    print("-" * 30)
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # Test random verse
            response = await client.get("https://bible-api.com/random")
            if response.status_code == 200:
                data = response.json()
                print(f"Random verse: {data.get('reference', 'N/A')} - {data.get('text', 'N/A')}")
            else:
                print(f"Random verse failed: {response.status_code}")
            
            # Test specific verse
            response = await client.get("https://bible-api.com/john+3:16")
            if response.status_code == 200:
                data = response.json()
                print(f"John 3:16: {data.get('reference', 'N/A')} - {data.get('text', 'N/A')}")
            else:
                print(f"John 3:16 failed: {response.status_code}")
    except Exception as e:
        print(f"Bible API wldeh error: {e}")
    
    print()
    
    # Test 3: ScriptureAPI.com
    print("3. Testing ScriptureAPI.com...")
    print("-" * 30)
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # Test random verse
            response = await client.get("https://scriptureapi.com/api/random")
            if response.status_code == 200:
                data = response.json()
                print(f"Random verse: {data.get('reference', 'N/A')} - {data.get('text', 'N/A')}")
            else:
                print(f"Random verse failed: {response.status_code}")
    except Exception as e:
        print(f"ScriptureAPI.com error: {e}")
    
    print()
    
    # Test 4: Bible Gateway VOTD
    print("4. Testing Bible Gateway VOTD...")
    print("-" * 30)
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get("https://www.biblegateway.com/votd/get/?format=json&version=KJV")
            if response.status_code == 200:
                data = response.json()
                if 'votd' in data:
                    votd = data['votd']
                    print(f"VOTD: {votd.get('display_ref', 'N/A')} - {votd.get('content', 'N/A')}")
                else:
                    print("VOTD data not found in response")
            else:
                print(f"VOTD failed: {response.status_code}")
    except Exception as e:
        print(f"Bible Gateway VOTD error: {e}")
    
    print()
    print("=" * 60)
    print("Individual API Test Complete!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(test_individual_apis())

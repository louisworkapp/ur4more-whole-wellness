import httpx
import asyncio
import random
from typing import List, Optional
from app.models import ScripturePassage, Verse
from app.config import settings
from app.services.allowlist import ALLOWLISTED_PROVIDERS

async def fetch_scripture_external(allow_faith: bool, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch scripture from external providers for 365-day rotation"""
    if not settings.ENABLE_EXTERNAL or not allow_faith:
        return []
    
    passages = []
    
    # Iterate allowlisted scripture providers
    for name, cfg in ALLOWLISTED_PROVIDERS.items():
        if not cfg.get("enabled") or not _is_scripture_provider(name):
            continue
            
        try:
            provider_passages = await _fetch_from_scripture_provider(name, cfg, theme, limit)
            passages.extend(provider_passages)
        except Exception as e:
            print(f"Error fetching scripture from {name}: {e}")
            continue
    
    return passages[:limit]

def _is_scripture_provider(name: str) -> bool:
    """Check if provider is a scripture provider"""
    scripture_providers = ["scripture_api", "bible_api_wldeh", "labs_bible", "bible_gateway_votd"]
    return name in scripture_providers

async def _fetch_from_scripture_provider(name: str, cfg: dict, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch scripture from a specific external provider"""
    
    if name == "labs_bible":
        return await _fetch_labs_bible(cfg, theme, limit)
    elif name == "bible_api_wldeh":
        return await _fetch_bible_api_wldeh(cfg, theme, limit)
    elif name == "scripture_api":
        return await _fetch_scripture_api(cfg, theme, limit)
    elif name == "bible_gateway_votd":
        return await _fetch_bible_gateway_votd(cfg, theme, limit)
    else:
        return []

async def _fetch_labs_bible(cfg: dict, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch from Bible.org Labs API (free, no API key required)"""
    passages = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            # Get daily verse
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['daily']}")
            if response.status_code == 200:
                data = response.text
                # Parse the response (format: "John 3:16 - For God so loved the world..."
                if " - " in data:
                    parts = data.split(" - ", 1)
                    if len(parts) == 2:
                        reference = parts[0].strip()
                        text = parts[1].strip()
                        
                        # Create a simple verse
                        verse = Verse(v=1, t=text)
                        passage = ScripturePassage(
                            ref=reference,
                            verses=[verse],
                            actNow=f"Reflect on {theme} through this scripture today.",
                            license=cfg['license'],
                            source="labs_bible"
                        )
                        passages.append(passage)
        except Exception as e:
            print(f"Labs Bible daily API error: {e}")
        
        # Get random verses for variety
        try:
            for _ in range(min(limit - 1, 2)):
                response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['random']}")
                if response.status_code == 200:
                    data = response.text
                    if " - " in data:
                        parts = data.split(" - ", 1)
                        if len(parts) == 2:
                            reference = parts[0].strip()
                            text = parts[1].strip()
                            
                            verse = Verse(v=1, t=text)
                            passage = ScripturePassage(
                                ref=reference,
                                verses=[verse],
                                actNow=f"Apply this wisdom to your {theme} journey.",
                                license=cfg['license'],
                                source="labs_bible"
                            )
                            passages.append(passage)
        except Exception as e:
            print(f"Labs Bible random API error: {e}")
    
    return passages

async def _fetch_bible_api_wldeh(cfg: dict, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch from Bible API by wldeh (free, no API key required)"""
    passages = []
    
    # Popular verses for variety
    popular_verses = [
        "john+3:16", "psalm+23:1", "jeremiah+29:11", "philippians+4:13",
        "romans+8:28", "proverbs+3:5", "matthew+11:28", "isaiah+40:31"
    ]
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            # Get specific verses instead of random (which returns 404)
            for verse_ref in popular_verses[:limit]:
                response = await client.get(f"{cfg['base_url']}/{verse_ref}")
                if response.status_code == 200:
                    data = response.json()
                    if 'reference' in data and 'text' in data:
                        reference = data['reference']
                        text = data['text']
                        
                        verse = Verse(v=1, t=text)
                        passage = ScripturePassage(
                            ref=reference,
                            verses=[verse],
                            actNow=f"Meditate on this scripture for {theme}.",
                            license=cfg['license'],
                            source="bible_api_wldeh"
                        )
                        passages.append(passage)
        except Exception as e:
            print(f"Bible API wldeh error: {e}")
    
    return passages

async def _fetch_scripture_api(cfg: dict, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch from ScriptureAPI.com (free, no API key required)"""
    passages = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            # Get random verse
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['random']}")
            if response.status_code == 200:
                data = response.json()
                if 'reference' in data and 'text' in data:
                    reference = data['reference']
                    text = data['text']
                    
                    verse = Verse(v=1, t=text)
                    passage = ScripturePassage(
                        ref=reference,
                        verses=[verse],
                        actNow=f"Apply this scripture to your {theme} journey.",
                        license=cfg['license'],
                        source="scripture_api"
                    )
                    passages.append(passage)
        except Exception as e:
            print(f"Scripture API error: {e}")
    
    return passages

async def _fetch_bible_gateway_votd(cfg: dict, theme: str, limit: int) -> List[ScripturePassage]:
    """Fetch from Bible Gateway Verse of the Day"""
    passages = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['verse_of_day']}")
            if response.status_code == 200:
                data = response.json()
                if 'votd' in data:
                    votd = data['votd']
                    if 'content' in votd and 'display_ref' in votd:
                        reference = votd['display_ref']
                        text = votd['content']
                        
                        verse = Verse(v=1, t=text)
                        passage = ScripturePassage(
                            ref=reference,
                            verses=[verse],
                            actNow=f"Reflect on this daily verse for {theme}.",
                            license=cfg['license'],
                            source="bible_gateway_votd"
                        )
                        passages.append(passage)
        except Exception as e:
            print(f"Bible Gateway VOTD error: {e}")
    
    return passages

# Fallback scripture passages for when external APIs are unavailable
FALLBACK_SCRIPTURE_PASSAGES = [
    ScripturePassage(
        ref="Proverbs 3:5-6 (KJV)",
        verses=[
            Verse(v=5, t="Trust in the Lord with all thine heart; and lean not unto thine own understanding."),
            Verse(v=6, t="In all thy ways acknowledge him, and he shall direct thy paths.")
        ],
        actNow="Trust God's guidance in your decisions today.",
        license="public_domain",
        source="fallback"
    ),
    ScripturePassage(
        ref="Philippians 4:13 (KJV)",
        verses=[
            Verse(v=13, t="I can do all things through Christ which strengtheneth me.")
        ],
        actNow="Draw strength from Christ for today's challenges.",
        license="public_domain",
        source="fallback"
    ),
    ScripturePassage(
        ref="Jeremiah 29:11 (KJV)",
        verses=[
            Verse(v=11, t="For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil, to give you an expected end.")
        ],
        actNow="Rest in God's good plans for your life.",
        license="public_domain",
        source="fallback"
    ),
    ScripturePassage(
        ref="Psalm 46:10 (KJV)",
        verses=[
            Verse(v=10, t="Be still, and know that I am God: I will be exalted among the heathen, I will be exalted in the earth.")
        ],
        actNow="Take time to be still and know God's presence.",
        license="public_domain",
        source="fallback"
    ),
    ScripturePassage(
        ref="Romans 8:28 (KJV)",
        verses=[
            Verse(v=28, t="And we know that all things work together for good to them that love God, to them who are the called according to his purpose.")
        ],
        actNow="Trust that God is working all things for your good.",
        license="public_domain",
        source="fallback"
    )
]

async def get_fallback_scripture(theme: str) -> ScripturePassage:
    """Get a random fallback scripture passage"""
    return random.choice(FALLBACK_SCRIPTURE_PASSAGES)

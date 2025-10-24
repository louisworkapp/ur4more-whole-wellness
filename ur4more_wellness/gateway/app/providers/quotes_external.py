import httpx
import asyncio
from typing import List
from app.models import QuoteItem
from app.config import settings
from app.services.allowlist import ALLOWLISTED_PROVIDERS

async def fetch_quotes_external(allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    if not settings.ENABLE_EXTERNAL: 
        return []
    
    quotes = []
    
    # Iterate allowlisted providers with enabled=True
    for name, cfg in ALLOWLISTED_PROVIDERS.items():
        if not cfg.get("enabled"): 
            continue
            
        try:
            provider_quotes = await _fetch_from_provider(name, cfg, allow_faith, topic, limit)
            quotes.extend(provider_quotes)
        except Exception as e:
            print(f"Error fetching from {name}: {e}")
            continue
    
    return quotes[:limit]

async def _fetch_from_provider(name: str, cfg: dict, allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    """Fetch quotes from a specific external provider"""
    
    if name == "quotable":
        return await _fetch_quotable(cfg, allow_faith, topic, limit)
    elif name == "zenquotes":
        return await _fetch_zenquotes(cfg, allow_faith, topic, limit)
    elif name == "quotegarden":
        return await _fetch_quotegarden(cfg, allow_faith, topic, limit)
    else:
        return []

async def _fetch_quotable(cfg: dict, allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    """Fetch from Quotable API (public domain quotes)"""
    quotes = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        # Fetch multiple random quotes
        for _ in range(min(limit, 5)):  # Limit API calls
            try:
                response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['random']}")
                if response.status_code == 200:
                    data = response.json()
                    quote = QuoteItem(
                        id=f"quotable_{data.get('_id', '')}",
                        text=data.get('content', ''),
                        author=data.get('author', 'Unknown'),
                        license=cfg['license'],
                        source="quotable",
                        tags=["secular", "wisdom"] + (data.get('tags', [])[:2])
                    )
                    quotes.append(quote)
            except Exception as e:
                print(f"Quotable API error: {e}")
                continue
    
    return quotes

async def _fetch_zenquotes(cfg: dict, allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    """Fetch from ZenQuotes API"""
    quotes = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            # Try today's quote first
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['today']}")
            if response.status_code == 200:
                data = response.json()
                if data and len(data) > 0:
                    quote_data = data[0]
                    quote = QuoteItem(
                        id=f"zenquotes_today_{quote_data.get('a', '').replace(' ', '_')}",
                        text=quote_data.get('q', ''),
                        author=quote_data.get('a', 'Unknown'),
                        license=cfg['license'],
                        source="zenquotes",
                        tags=["secular", "daily"]
                    )
                    quotes.append(quote)
        except Exception as e:
            print(f"ZenQuotes today API error: {e}")
        
        # Get random quotes
        try:
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['random']}")
            if response.status_code == 200:
                data = response.json()
                for quote_data in data[:min(limit, 3)]:
                    quote = QuoteItem(
                        id=f"zenquotes_random_{quote_data.get('a', '').replace(' ', '_')}",
                        text=quote_data.get('q', ''),
                        author=quote_data.get('a', 'Unknown'),
                        license=cfg['license'],
                        source="zenquotes",
                        tags=["secular", "random"]
                    )
                    quotes.append(quote)
        except Exception as e:
            print(f"ZenQuotes random API error: {e}")
    
    return quotes

async def _fetch_quotegarden(cfg: dict, allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    """Fetch from QuoteGarden API"""
    quotes = []
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['random']}")
            if response.status_code == 200:
                data = response.json()
                if data.get('statusCode') == 200:
                    quote_data = data.get('data', {})
                    quote = QuoteItem(
                        id=f"quotegarden_{quote_data.get('_id', '')}",
                        text=quote_data.get('quoteText', ''),
                        author=quote_data.get('quoteAuthor', 'Unknown'),
                        license=cfg['license'],
                        source="quotegarden",
                        tags=["secular", "wisdom"]
                    )
                    quotes.append(quote)
        except Exception as e:
            print(f"QuoteGarden API error: {e}")
    
    return quotes

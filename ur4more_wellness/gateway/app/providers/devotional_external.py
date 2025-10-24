import httpx
import asyncio
import random
from typing import List, Dict, Optional
from app.config import settings
from app.services.allowlist import ALLOWLISTED_PROVIDERS

async def fetch_devotionals_external(allow_faith: bool, theme: str, limit: int) -> List[Dict]:
    """Fetch devotionals and prayers from external providers for 365-day rotation"""
    if not settings.ENABLE_EXTERNAL or not allow_faith:
        return []
    
    devotionals = []
    
    # Iterate allowlisted devotional providers
    for name, cfg in ALLOWLISTED_PROVIDERS.items():
        if not cfg.get("enabled") or not _is_devotional_provider(name):
            continue
            
        try:
            provider_devotionals = await _fetch_from_devotional_provider(name, cfg, theme, limit)
            devotionals.extend(provider_devotionals)
        except Exception as e:
            print(f"Error fetching devotionals from {name}: {e}")
            continue
    
    return devotionals[:limit]

def _is_devotional_provider(name: str) -> bool:
    """Check if provider is a devotional/prayer provider"""
    devotional_providers = ["prayer_api", "devotional_api"]
    return name in devotional_providers

async def _fetch_from_devotional_provider(name: str, cfg: dict, theme: str, limit: int) -> List[Dict]:
    """Fetch devotionals from a specific external provider"""
    
    if name == "prayer_api":
        return await _fetch_prayer_api(cfg, theme, limit)
    elif name == "devotional_api":
        return await _fetch_devotional_api(cfg, theme, limit)
    else:
        return []

async def _fetch_prayer_api(cfg: dict, theme: str, limit: int) -> List[Dict]:
    """Fetch from Prayer API (placeholder implementation)"""
    prayers = []
    
    # Note: This is a placeholder for when prayer APIs become available
    # For now, we'll use our fallback prayers
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['daily_prayer']}")
            if response.status_code == 200:
                # This would need to be implemented based on their actual API response
                pass
        except Exception as e:
            print(f"Prayer API error: {e}")
    
    return prayers

async def _fetch_devotional_api(cfg: dict, theme: str, limit: int) -> List[Dict]:
    """Fetch from Devotional API (placeholder implementation)"""
    devotionals = []
    
    # Note: This is a placeholder for when devotional APIs become available
    # For now, we'll use our fallback devotionals
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(f"{cfg['base_url']}{cfg['endpoints']['daily']}")
            if response.status_code == 200:
                # This would need to be implemented based on their actual API response
                pass
        except Exception as e:
            print(f"Devotional API error: {e}")
    
    return devotionals

# Fallback prayers and devotionals for when external APIs are unavailable
FALLBACK_PRAYERS = [
    {
        "title": "Morning Prayer for Strength",
        "prayer": "Dear Lord, thank you for this new day. Grant me strength to face whatever challenges come my way. Help me to trust in your plan and find peace in your presence. Amen.",
        "theme": "strength",
        "source": "fallback"
    },
    {
        "title": "Prayer for Guidance",
        "prayer": "Heavenly Father, guide my steps today. Help me to make wise decisions and to be a light to others. May your will be done in my life. Amen.",
        "theme": "guidance",
        "source": "fallback"
    },
    {
        "title": "Prayer for Peace",
        "prayer": "Lord, in the midst of life's storms, grant me your peace that surpasses all understanding. Help me to rest in your love and trust in your timing. Amen.",
        "theme": "peace",
        "source": "fallback"
    },
    {
        "title": "Prayer for Healing",
        "prayer": "Merciful God, I pray for healing - physical, emotional, and spiritual. Touch me with your healing power and restore me to wholeness. Amen.",
        "theme": "healing",
        "source": "fallback"
    },
    {
        "title": "Prayer for Gratitude",
        "prayer": "Gracious God, thank you for all the blessings in my life. Help me to see your goodness in every moment and to live with a grateful heart. Amen.",
        "theme": "gratitude",
        "source": "fallback"
    }
]

FALLBACK_DEVOTIONALS = [
    {
        "title": "Daily Reflection: Trust in God's Timing",
        "scripture": "Ecclesiastes 3:1 - To every thing there is a season, and a time to every purpose under the heaven.",
        "reflection": "God's timing is perfect, even when we don't understand it. Trust that He is working all things together for your good.",
        "prayer": "Lord, help me to trust in your perfect timing and to be patient as you work in my life.",
        "theme": "patience",
        "source": "fallback"
    },
    {
        "title": "Daily Reflection: The Power of Love",
        "scripture": "1 Corinthians 13:4 - Love is patient, love is kind. It does not envy, it does not boast, it is not proud.",
        "reflection": "True love is not about what we receive, but about what we give. Let us love others as God loves us.",
        "prayer": "Father, help me to love others with the same unconditional love you have shown me.",
        "theme": "love",
        "source": "fallback"
    },
    {
        "title": "Daily Reflection: Finding Joy in Trials",
        "scripture": "James 1:2-3 - Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds, because you know that the testing of your faith produces perseverance.",
        "reflection": "Even in difficult times, we can find joy knowing that God is using our trials to strengthen our faith.",
        "prayer": "Lord, help me to see your purpose in my trials and to find joy in your presence.",
        "theme": "joy",
        "source": "fallback"
    },
    {
        "title": "Daily Reflection: The Light of the World",
        "scripture": "Matthew 5:14 - You are the light of the world. A town built on a hill cannot be hidden.",
        "reflection": "As followers of Christ, we are called to be a light in the darkness, showing others the way to God.",
        "prayer": "God, help me to shine your light in the world and to be a positive influence on those around me.",
        "theme": "purpose",
        "source": "fallback"
    },
    {
        "title": "Daily Reflection: Rest in God's Presence",
        "scripture": "Psalm 23:2 - He makes me lie down in green pastures, he leads me beside quiet waters.",
        "reflection": "God provides rest and refreshment for our souls. Take time to rest in His presence today.",
        "prayer": "Lord, help me to find rest in your presence and to be refreshed by your love.",
        "theme": "rest",
        "source": "fallback"
    }
]

async def get_fallback_prayer(theme: str) -> Dict:
    """Get a random fallback prayer"""
    # Filter prayers by theme if possible
    theme_prayers = [p for p in FALLBACK_PRAYERS if theme.lower() in p["theme"].lower()]
    if not theme_prayers:
        theme_prayers = FALLBACK_PRAYERS
    return random.choice(theme_prayers)

async def get_fallback_devotional(theme: str) -> Dict:
    """Get a random fallback devotional"""
    # Filter devotionals by theme if possible
    theme_devotionals = [d for d in FALLBACK_DEVOTIONALS if theme.lower() in d["theme"].lower()]
    if not theme_devotionals:
        theme_devotionals = FALLBACK_DEVOTIONALS
    return random.choice(theme_devotionals)

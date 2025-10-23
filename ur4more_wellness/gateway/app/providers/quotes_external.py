from typing import List
from app.models import QuoteItem
from app.config import settings
from app.services.allowlist import ALLOWLISTED_PROVIDERS

async def fetch_quotes_external(allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    if not settings.ENABLE_EXTERNAL: return []
    # Iterate allowlisted providers with enabled=True (future work)
    for name, cfg in ALLOWLISTED_PROVIDERS.items():
        if not cfg.get("enabled"): continue
        # TODO: call provider with httpx, validate license, normalize to QuoteItem
        # For now, return empty.
    return []

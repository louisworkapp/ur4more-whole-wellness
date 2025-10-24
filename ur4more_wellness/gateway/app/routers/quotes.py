from fastapi import APIRouter, Request, Depends
from typing import List
from app.models import QuoteRequest, QuoteItem
from app.services.gating import faith_allowed
from app.services.filters import filter_quote
from app.services.cache import cache
from app.services.rank import rank_quotes
from app.providers.quotes_local import fetch_quotes_local
from app.providers.quotes_external import fetch_quotes_external
from app.deps import limiter, make_cache_key
from app.services.auth import require_auth

router = APIRouter(prefix="/content", tags=["content"])

@router.post("/quotes", response_model=List[QuoteItem])
async def quotes_endpoint(req: Request, body: QuoteRequest, _claims = Depends(require_auth)):
    allow = faith_allowed(body.faithMode, body.lightConsentGiven, body.hideFaithOverlaysInMind)
    key = make_cache_key("/quotes", body.model_dump())
    cached = cache.get(key)
    if cached:
        import json
        return [QuoteItem(**x) for x in json.loads(cached)]

    items: List[QuoteItem] = []
    items += await fetch_quotes_external(allow, body.topic, body.limit)
    items += await fetch_quotes_local(allow, body.topic, body.limit)

    filtered, seen = [], set()
    for q in items:
        qq = filter_quote(q, allow)
        if not qq: continue
        sig = (qq.text.strip().lower(), qq.author.lower())
        if sig in seen: continue
        seen.add(sig); filtered.append(qq)

    ranked = rank_quotes(filtered, body.topic)[:max(1, body.limit)]
    cache.set(key, [r.model_dump() for r in ranked])
    return ranked

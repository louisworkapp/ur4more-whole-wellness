from fastapi import APIRouter, HTTPException, Request, Depends
from app.models import QuoteRequest
from app.services.gating import faith_allowed
from app.services.cache import cache
from app.providers.devotional_external import fetch_devotionals_external, get_fallback_prayer, get_fallback_devotional
from app.deps import limiter, make_cache_key
from app.services.auth import require_auth

router = APIRouter(prefix="/content", tags=["content"])

@router.post("/prayers")
async def prayers_endpoint(req: Request, body: QuoteRequest, _claims = Depends(require_auth)):
    """Get daily prayers for 365-day rotation"""
    allow = faith_allowed(body.faithMode, body.lightConsentGiven, body.hideFaithOverlaysInMind)
    if not allow:
        raise HTTPException(status_code=403, detail={"code":"FAITH_BLOCKED","hint":"Enable Faith Mode (Light with consent, Disciple, or Kingdom) and unhide in Mind."})

    key = make_cache_key("/prayers", body.model_dump())
    cached = cache.get(key)
    if cached:
        import json
        return json.loads(cached)

    # Try external providers first for 365-day rotation
    prayers = await fetch_devotionals_external(allow, body.topic, body.limit)
    
    # Fallback to local prayers
    if not prayers:
        fallback_prayer = await get_fallback_prayer(body.topic)
        prayers = [fallback_prayer]
    
    if not prayers:
        raise HTTPException(status_code=404, detail="No prayers available.")
    
    cache.set(key, prayers)
    return prayers

@router.post("/devotionals")
async def devotionals_endpoint(req: Request, body: QuoteRequest, _claims = Depends(require_auth)):
    """Get daily devotionals for 365-day rotation"""
    allow = faith_allowed(body.faithMode, body.lightConsentGiven, body.hideFaithOverlaysInMind)
    if not allow:
        raise HTTPException(status_code=403, detail={"code":"FAITH_BLOCKED","hint":"Enable Faith Mode (Light with consent, Disciple, or Kingdom) and unhide in Mind."})

    key = make_cache_key("/devotionals", body.model_dump())
    cached = cache.get(key)
    if cached:
        import json
        return json.loads(cached)

    # Try external providers first for 365-day rotation
    devotionals = await fetch_devotionals_external(allow, body.topic, body.limit)
    
    # Fallback to local devotionals
    if not devotionals:
        fallback_devotional = await get_fallback_devotional(body.topic)
        devotionals = [fallback_devotional]
    
    if not devotionals:
        raise HTTPException(status_code=404, detail="No devotionals available.")
    
    cache.set(key, devotionals)
    return devotionals

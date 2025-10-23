from fastapi import APIRouter, HTTPException, Request, Depends
from app.models import ScriptureRequest, ScripturePassage
from app.services.gating import faith_allowed
from app.services.filters import filter_scripture
from app.services.cache import cache
from app.providers.scripture_kjv_local import fetch_scripture_local
from app.deps import limiter, make_cache_key
from app.services.auth import require_auth

router = APIRouter(prefix="/content", tags=["content"])

@router.post("/scripture", response_model=ScripturePassage)
@limiter.limit("30/minute")
async def scripture_endpoint(req: Request, body: ScriptureRequest, _claims = Depends(require_auth)):
    allow = faith_allowed(body.faithMode, body.lightConsentGiven, body.hideFaithOverlaysInMind)
    if not allow:
        raise HTTPException(status_code=403, detail={"code":"FAITH_BLOCKED","hint":"Enable Faith Mode (Light with consent, Disciple, or Kingdom) and unhide in Mind."})

    key = make_cache_key("/scripture", body.model_dump())
    cached = cache.get(key)
    if cached:
        import json
        return ScripturePassage(**json.loads(cached))

    passages = await fetch_scripture_local(body.theme, body.limit)
    if not passages:
        raise HTTPException(status_code=404, detail="No scripture available for theme.")
    p = filter_scripture(passages[0])
    if not p:
        raise HTTPException(status_code=422, detail="Scripture failed filter policy.")
    cache.set(key, p.model_dump())
    return p

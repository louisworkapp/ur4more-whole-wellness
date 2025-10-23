from fastapi import APIRouter, Depends
from app.services.auth import require_auth
from app.services.manifest import build_manifest

router = APIRouter(prefix="/content", tags=["content"])

@router.get("/manifest")
async def manifest(_claims = Depends(require_auth)):
    return build_manifest()

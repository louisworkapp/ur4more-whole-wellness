from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import quotes, scripture, devotionals, manifest as manifest_router

app = FastAPI(title="UR4MORE Content Gateway v2", version="2.0.0")

# CORS
allow_origins = settings.CORS_ORIGINS if settings.CORS_ORIGINS != ["*"] else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def _timing(request: Request, call_next):
    return await call_next(request)

# Rate limiting temporarily disabled due to compatibility issues

@app.get("/health")
def health():
    return {"ok": True, "env": settings.ENV, "redis": bool(settings.REDIS_URL)}

# Routers
app.include_router(manifest_router.router)
app.include_router(quotes.router)
app.include_router(scripture.router)
app.include_router(devotionals.router)

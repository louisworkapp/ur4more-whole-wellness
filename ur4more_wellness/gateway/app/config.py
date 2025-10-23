import os
from typing import Optional, List
from pydantic import BaseModel

class Settings(BaseModel):
    PORT: int = int(os.getenv("PORT", "8080"))
    ENV: str = os.getenv("ENV", "dev")
    REDIS_URL: Optional[str] = os.getenv("REDIS_URL") or None
    CACHE_TTL_SEC: int = int(os.getenv("CACHE_TTL_SEC", "120"))
    RATE_LIMIT_PER_MIN: int = int(os.getenv("RATE_LIMIT_PER_MIN", "60"))
    ENABLE_EXTERNAL: bool = os.getenv("ENABLE_EXTERNAL", "0") == "1"
    ALLOW_FAITH_IN_LIGHT_BY_DEFAULT: bool = os.getenv("ALLOW_FAITH_IN_LIGHT_BY_DEFAULT","0") == "1"

    # Auth
    JWT_KID: str = os.getenv("JWT_KID", "v1")
    JWT_SECRET_V1: str = os.getenv("JWT_SECRET_V1", "dev-secret-change-me")
    JWT_SECRET_V0: Optional[str] = os.getenv("JWT_SECRET_V0") or None
    JWT_ISS: str = os.getenv("JWT_ISS", "ur4more-gateway")
    JWT_AUD: str = os.getenv("JWT_AUD", "ur4more-apps")

    # CORS
    CORS_ORIGINS: List[str] = [x.strip() for x in os.getenv("CORS_ORIGINS","*").split(",") if x.strip()]

settings = Settings()

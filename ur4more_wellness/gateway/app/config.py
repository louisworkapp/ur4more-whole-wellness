import os
from typing import Optional, List

class Settings:
    def __init__(self):
        self.PORT: int = int(os.getenv("PORT", "8080"))
        self.ENV: str = os.getenv("ENV", "dev")
        self.REDIS_URL: Optional[str] = os.getenv("REDIS_URL")
        self.CACHE_TTL_SEC: int = int(os.getenv("CACHE_TTL_SEC", "120"))
        self.RATE_LIMIT_PER_MIN: int = int(os.getenv("RATE_LIMIT_PER_MIN", "60"))
        self.ENABLE_EXTERNAL: bool = os.getenv("ENABLE_EXTERNAL", "1") == "1"
        self.ALLOW_FAITH_IN_LIGHT_BY_DEFAULT: bool = os.getenv("ALLOW_FAITH_IN_LIGHT_BY_DEFAULT","0") == "1"

        # Auth
        self.JWT_KID: str = os.getenv("JWT_KID", "v1")
        self.JWT_SECRET_V1: str = os.getenv("JWT_SECRET_V1", "dev-secret-change-me")
        self.JWT_SECRET_V0: Optional[str] = os.getenv("JWT_SECRET_V0")
        self.JWT_ISS: str = os.getenv("JWT_ISS", "ur4more-gateway")
        self.JWT_AUD: str = os.getenv("JWT_AUD", "ur4more-apps")

        # CORS
        self.CORS_ORIGINS: List[str] = [x.strip() for x in os.getenv("CORS_ORIGINS","*").split(",") if x.strip()]

settings = Settings()

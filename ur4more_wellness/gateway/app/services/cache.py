import time, json
from typing import Any, Optional
from app.config import settings
try:
    import redis
except Exception:
    redis = None

class CacheService:
    def __init__(self):
        self.ttl = settings.CACHE_TTL_SEC
        self.mem = {}
        self.r = redis.Redis.from_url(settings.REDIS_URL, decode_responses=True) if (redis and settings.REDIS_URL) else None

    def _mem_get(self, k: str) -> Optional[str]:
        rec = self.mem.get(k)
        if not rec: return None
        val, exp = rec
        if exp and exp < time.time():
            self.mem.pop(k, None)
            return None
        return val

    def _mem_set(self, k: str, v: str, ttl: int):
        self.mem[k] = (v, time.time()+ttl if ttl else None)

    def get(self, k: str) -> Optional[str]:
        return self.r.get(k) if self.r else self._mem_get(k)

    def set(self, k: str, value: Any, ttl: Optional[int]=None):
        s = json.dumps(value)
        ttl = ttl or self.ttl
        if self.r: self.r.setex(k, ttl, s)
        else: self._mem_set(k, s, ttl)

cache = CacheService()

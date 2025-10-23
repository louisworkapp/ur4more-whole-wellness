import hashlib, json
from slowapi import Limiter
from slowapi.util import get_remote_address
from app.config import settings

limiter = Limiter(key_func=get_remote_address, default_limits=[f"{settings.RATE_LIMIT_PER_MIN}/minute"])

def make_cache_key(path: str, payload: dict) -> str:
    s = json.dumps({"p": path, "b": payload}, sort_keys=True, separators=(",",":"))
    return "cg:" + hashlib.sha256(s.encode()).hexdigest()

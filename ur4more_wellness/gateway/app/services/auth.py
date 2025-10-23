import time, jwt
from fastapi import HTTPException, Header
from typing import Optional, Dict, Any
from app.config import settings

JWKS: Dict[str, str] = {
    settings.JWT_KID: settings.JWT_SECRET_V1
}
if settings.JWT_SECRET_V0:
    JWKS["v0"] = settings.JWT_SECRET_V0

class AuthError(HTTPException):
    def __init__(self, detail="Unauthorized"):
        super().__init__(status_code=401, detail=detail)

def require_auth(authorization: Optional[str] = Header(None)) -> Dict[str, Any]:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise AuthError("Missing bearer token")
    token = authorization.split(" ", 1)[1]
    try:
        header = jwt.get_unverified_header(token)
        kid = header.get("kid", settings.JWT_KID)
        secret = JWKS.get(kid)
        if not secret:
            raise AuthError("Unknown key id")
        payload = jwt.decode(
            token, secret, algorithms=["HS256"],
            audience=settings.JWT_AUD, issuer=settings.JWT_ISS
        )
        if payload.get("exp", 0) < int(time.time()):
            raise AuthError("Token expired")
        return payload
    except jwt.ExpiredSignatureError:
        raise AuthError("Token expired")
    except jwt.InvalidTokenError:
        raise AuthError("Invalid token")

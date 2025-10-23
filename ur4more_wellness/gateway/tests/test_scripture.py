from fastapi.testclient import TestClient
from app.main import app
import jwt, time
from app.config import settings

def token():
    now = int(time.time())
    payload = {"sub":"test","iss":settings.JWT_ISS,"aud":settings.JWT_AUD,"iat":now,"exp":now+3600}
    return jwt.encode(payload, settings.JWT_SECRET_V1, algorithm="HS256", headers={"kid":settings.JWT_KID})

client = TestClient(app)
HDR = lambda: {"Authorization": f"Bearer {token()}"}

def test_scripture_blocked_off():
    r = client.post("/content/scripture", headers=HDR(), json={
        "faithMode":"off","lightConsentGiven":False,"hideFaithOverlaysInMind":False,"theme":"gluttony","limit":1
    })
    assert r.status_code == 403

def test_scripture_light_ok():
    r = client.post("/content/scripture", headers=HDR(), json={
        "faithMode":"light","lightConsentGiven":True,"hideFaithOverlaysInMind":False,"theme":"gluttony","limit":1
    })
    assert r.status_code == 200
    assert r.json()["ref"].startswith("1 Corinthians 9")

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

def test_quotes_off_no_faith():
    r = client.post("/content/quotes", headers=HDR(), json={
        "faithMode":"off","lightConsentGiven":False,"hideFaithOverlaysInMind":False,"topic":"temperance","limit":5
    })
    assert r.status_code == 200
    for q in r.json():
        assert "faith" not in q.get("tags", [])

def test_quotes_disciple_allows_faith():
    r = client.post("/content/quotes", headers=HDR(), json={
        "faithMode":"disciple","lightConsentGiven":True,"hideFaithOverlaysInMind":False,"topic":"temperance","limit":5
    })
    assert r.status_code == 200
    assert len(r.json()) >= 1

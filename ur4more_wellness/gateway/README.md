# UR4MORE Content Gateway v2

## Quick start
```bash
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload

Issue a dev token
python - <<'PY'
import time, jwt, os
kid=os.getenv("JWT_KID","v1"); sec=os.getenv("JWT_SECRET_V1","dev-secret-change-me")
iss=os.getenv("JWT_ISS","ur4more-gateway"); aud=os.getenv("JWT_AUD","ur4more-apps")
now=int(time.time()); payload={"sub":"debug","iss":iss,"aud":aud,"iat":now,"exp":now+3600}
print(jwt.encode(payload, sec, algorithm="HS256", headers={"kid":kid}))
PY

Smoke tests (recommended: use 127.0.0.1, localhost also works)
TOK=<paste>
curl -s http://127.0.0.1:8080/health -H "Authorization: Bearer $TOK" | jq .
curl -s http://127.0.0.1:8080/content/manifest -H "Authorization: Bearer $TOK" | jq .
curl -s http://127.0.0.1:8080/content/quotes -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"off","topic":"temperance","limit":3}' | jq .
curl -s -o - -w "\n%{http_code}\n" http://127.0.0.1:8080/content/scripture \
  -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"off","lightConsentGiven":false,"hideFaithOverlaysInMind":false,"theme":"gluttony","limit":1}'
curl -s http://127.0.0.1:8080/content/scripture -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"light","lightConsentGiven":true,"hideFaithOverlaysInMind":false,"theme":"gluttony","limit":1}' | jq .

Tests
pytest -q

Docker
docker compose up --build


---

## After Cursor finishes
1) Run the README quick start; confirm health, quotes 200, scripture 403/200 as expected.  
2) Point Flutter to this new base URL and send the **Authorization: Bearer** header.  
3) When ready, enable an external provider by:
   - setting `ENABLE_EXTERNAL=1` in `.env`
   - flipping a provider to `enabled: true` in `allowlist.py`
   - implementing the actual HTTP call + license checks in `quotes_external.py`.

If you hit any error codes (401/403/404/CORS), tell me the exact response and I'll pinpoint the fix.

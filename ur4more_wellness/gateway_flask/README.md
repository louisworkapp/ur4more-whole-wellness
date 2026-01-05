# UR4MORE Content Gateway — Flask

## Quick start
```bash
cp env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python app.py

Issue a dev token (Python one-liner)
python - <<'PY'
import time, jwt, os
kid=os.getenv("JWT_KID","v1"); sec=os.getenv("JWT_SECRET_V1","dev-secret-change-me")
iss=os.getenv("JWT_ISS","ur4more-gateway"); aud=os.getenv("JWT_AUD","ur4more-apps")
now=int(time.time()); payload={"sub":"debug","iss":iss,"aud":aud,"iat":now,"exp":now+3600}
print(jwt.encode(payload, sec, algorithm="HS256", headers={"kid":kid}))
PY

Smoke tests
TOK=<paste token>

# health
curl -s http://127.0.0.1:8080/health -H "Authorization: Bearer $TOK" | jq .

# manifest
curl -s http://127.0.0.1:8080/content/manifest -H "Authorization: Bearer $TOK" | jq .

# quotes (OFF → secular only)
curl -s http://127.0.0.1:8080/content/quotes \
  -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"off","lightConsentGiven":false,"hideFaithOverlaysInMind":false,"topic":"temperance","limit":3}' | jq .

# scripture (OFF → 403)
curl -s -o - -w "\n%{http_code}\n" http://127.0.0.1:8080/content/scripture \
  -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"off","lightConsentGiven":false,"hideFaithOverlaysInMind":false,"theme":"gluttony","limit":1}'

# scripture (Light+consent → 200)
curl -s http://127.0.0.1:8080/content/scripture \
  -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"faithMode":"light","lightConsentGiven":true,"hideFaithOverlaysInMind":false,"theme":"gluttony","limit":1}' | jq .

## Notes

- No FastAPI/Pydantic; JSON is handled via Flask + orjson.
- Same request/response shapes as your previous gateway.
- Add more KJV themes under KJV_DB and expand LOCAL_QUOTES as needed.
- Set ENABLE_EXTERNAL=1 when you add an allowlisted provider adapter.

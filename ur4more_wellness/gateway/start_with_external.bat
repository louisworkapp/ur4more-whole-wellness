@echo off
set ENABLE_EXTERNAL=1
echo Starting gateway with external providers enabled...
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload

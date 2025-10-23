#!/usr/bin/env python3
"""
Generate a JWT token for testing the Flask gateway
"""
import time
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

# Get config from environment
kid = os.getenv("JWT_KID", "v1")
secret = os.getenv("JWT_SECRET_V1", "dev-secret-change-me")
iss = os.getenv("JWT_ISS", "ur4more-gateway")
aud = os.getenv("JWT_AUD", "ur4more-apps")

# Create token payload
now = int(time.time())
payload = {
    "sub": "debug",
    "iss": iss,
    "aud": aud,
    "iat": now,
    "exp": now + 3600  # 1 hour
}

# Generate token
token = jwt.encode(payload, secret, algorithm="HS256", headers={"kid": kid})

print("JWT Token for testing:")
print(token)
print("\nUse this token in your Authorization header:")
print(f"Authorization: Bearer {token}")

import os, time, json, hashlib, functools
from datetime import datetime, timezone
from typing import Dict, Any, Optional, List, Tuple

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

import jwt
from dotenv import load_dotenv
import requests

# -------------------------
# Config
# -------------------------
load_dotenv()

PORT = int(os.getenv("PORT", "8080"))
ENV = os.getenv("ENV", "dev")

REDIS_URL = os.getenv("REDIS_URL") or ""
CACHE_TTL_SEC = int(os.getenv("CACHE_TTL_SEC", "120"))

RATE_LIMIT_PER_MIN = int(os.getenv("RATE_LIMIT_PER_MIN", "60"))

ENABLE_EXTERNAL = os.getenv("ENABLE_EXTERNAL", "1") == "1"  # Enable by default for wisdom quotes
ALLOW_FAITH_IN_LIGHT_BY_DEFAULT = os.getenv("ALLOW_FAITH_IN_LIGHT_BY_DEFAULT", "0") == "1"

JWT_KID = os.getenv("JWT_KID", "v1")
JWT_SECRET_V1 = os.getenv("JWT_SECRET_V1", "dev-secret-change-me")
JWT_SECRET_V0 = os.getenv("JWT_SECRET_V0") or None
JWT_ISS = os.getenv("JWT_ISS", "ur4more-gateway")
JWT_AUD = os.getenv("JWT_AUD", "ur4more-apps")

CORS_ORIGINS = [x.strip() for x in os.getenv("CORS_ORIGINS", "*").split(",") if x.strip()]

# -------------------------
# Flask
# -------------------------
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": CORS_ORIGINS if CORS_ORIGINS != ["*"] else "*"}})

limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=[f"{RATE_LIMIT_PER_MIN}/minute"],
)

# -------------------------
# Cache (memory + optional Redis)
# -------------------------
try:
    import redis
    rds = redis.Redis.from_url(REDIS_URL, decode_responses=True) if REDIS_URL else None
except Exception:
    rds = None

_mem_cache: Dict[str, Tuple[str, float]] = {}

def cache_get(key: str) -> Optional[str]:
    if rds:
        return rds.get(key)
    rec = _mem_cache.get(key)
    if not rec: return None
    val, exp = rec
    if exp and exp < time.time():
        _mem_cache.pop(key, None)
        return None
    return val

def cache_set(key: str, value: Any, ttl: Optional[int] = None):
    s = json.dumps(value)
    ttl = ttl or CACHE_TTL_SEC
    if rds:
        rds.setex(key, ttl, s)
    else:
        _mem_cache[key] = (s, time.time() + ttl)

def make_cache_key(path: str, payload: Dict[str, Any]) -> str:
    body = json.dumps({"p": path, "b": payload}, sort_keys=True, separators=(",", ":"))
    return "cg:" + hashlib.sha256(body.encode()).hexdigest()

# -------------------------
# Auth (JWT HS256)
# -------------------------
JWKS = {JWT_KID: JWT_SECRET_V1}
if JWT_SECRET_V0:
    JWKS["v0"] = JWT_SECRET_V0

def require_auth(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        # DEVELOPMENT MODE: Skip auth for easier testing
        if ENV == "dev":
            request.jwt_claims = {"sub": "debug"}
            return fn(*args, **kwargs)
        
        auth = request.headers.get("Authorization", "")
        if not auth.lower().startswith("bearer "):
            return jsonify({"detail": "Missing bearer token"}), 401
        token = auth.split(" ", 1)[1]
        try:
            header = jwt.get_unverified_header(token)
            kid = header.get("kid", JWT_KID)
            secret = JWKS.get(kid)
            if not secret:
                return jsonify({"detail": "Unknown key id"}), 401
            payload = jwt.decode(
                token, secret, algorithms=["HS256"],
                audience=JWT_AUD, issuer=JWT_ISS
            )
            if payload.get("exp", 0) < int(time.time()):
                return jsonify({"detail": "Token expired"}), 401
            request.jwt_claims = payload
        except jwt.ExpiredSignatureError:
            return jsonify({"detail": "Token expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"detail": "Invalid token"}), 401
        return fn(*args, **kwargs)
    return wrapper

# -------------------------
# External Wisdom Quote Providers
# -------------------------
EXTERNAL_WISDOM_PROVIDERS = {
    "quotable": {
        "enabled": True,
        "url": "https://api.quotable.io/quotes",
        "params": {"tags": "wisdom", "limit": 10},
        "transform": lambda q: {
            "id": f"quotable_{q['_id']}",
            "text": q["content"],
            "author": q["author"],
            "license": "public_domain",
            "source": "Quotable API",
            "tags": ["wisdom", "external"]
        }
    },
    "zenquotes": {
        "enabled": True,
        "url": "https://zenquotes.io/api/quotes",
        "params": {},
        "transform": lambda q: {
            "id": f"zenquotes_{hash(q['q'])}",
            "text": q["q"],
            "author": q["a"],
            "license": "public_domain", 
            "source": "ZenQuotes API",
            "tags": ["wisdom", "external"]
        }
    },
    "quotegarden": {
        "enabled": True,
        "url": "https://quotegarden.herokuapp.com/api/v3/quotes",
        "params": {"limit": 10},
        "transform": lambda q: {
            "id": f"quotegarden_{q['_id']}",
            "text": q["quoteText"],
            "author": q["quoteAuthor"],
            "license": "public_domain",
            "source": "QuoteGarden API", 
            "tags": ["wisdom", "external"]
        }
    }
}

# -------------------------
# External Bible Scripture Providers
# -------------------------
EXTERNAL_BIBLE_PROVIDERS = {
    "bible_api": {
        "enabled": True,
        "url": "https://bible-api.com",
        "params": {},
        "transform": lambda ref, text: {
            "ref": ref,
            "verses": [{"v": 1, "t": text}],
            "actNow": "Reflect on this scripture today.",
            "license": "public_domain",
            "source": "Bible API"
        }
    },
    "bible_gateway_votd": {
        "enabled": True,
        "url": "https://www.biblegateway.com/votd/get",
        "params": {"format": "json", "version": "KJV"},
        "transform": lambda ref, text: {
            "ref": ref,
            "verses": [{"v": 1, "t": text}],
            "actNow": "Apply this truth to your life today.",
            "license": "public_domain", 
            "source": "Bible Gateway VOTD"
        }
    },
    "bible_org_labs": {
        "enabled": True,
        "url": "https://labs.bible.org/api",
        "params": {"formatting": "plain", "type": "json"},
        "transform": lambda ref, text: {
            "ref": ref,
            "verses": [{"v": 1, "t": text}],
            "actNow": "Meditate on this passage.",
            "license": "public_domain",
            "source": "Bible.org Labs"
        }
    }
}

# -------------------------
# External Wisdom Quote Fetching
# -------------------------
def fetch_external_wisdom_quotes() -> List[Dict[str, Any]]:
    """Fetch wisdom quotes from external APIs"""
    if not ENABLE_EXTERNAL:
        return []
    
    all_quotes = []
    
    for provider_name, config in EXTERNAL_WISDOM_PROVIDERS.items():
        if not config.get("enabled", False):
            continue
            
        try:
            print(f"Fetching wisdom quotes from {provider_name}...")
            response = requests.get(
                config["url"], 
                params=config["params"],
                timeout=10,
                headers={"User-Agent": "UR4More-Wellness/1.0"}
            )
            response.raise_for_status()
            
            data = response.json()
            quotes = data.get("results", data) if isinstance(data, dict) else data
            
            for quote in quotes[:10]:  # Limit to 10 per provider
                try:
                    transformed = config["transform"](quote)
                    all_quotes.append(transformed)
                except Exception as e:
                    print(f"Error transforming quote from {provider_name}: {e}")
                    continue
                    
            print(f"Fetched {len(quotes[:10])} quotes from {provider_name}")
            
        except Exception as e:
            print(f"Error fetching from {provider_name}: {e}")
            continue
    
    print(f"Total external wisdom quotes fetched: {len(all_quotes)}")
    return all_quotes

def get_daily_wisdom_quotes() -> List[Dict[str, Any]]:
    """Get wisdom quotes for today (local + external)"""
    # Get local wisdom quotes
    local_wisdom = [q for q in LOCAL_QUOTES if "wisdom" in q.get("tags", [])]
    
    # Get external wisdom quotes (cached for the day)
    cache_key = f"wisdom_external_{datetime.now().strftime('%Y-%m-%d')}"
    external_quotes = cache_get(cache_key)
    
    if external_quotes is None:
        external_quotes = fetch_external_wisdom_quotes()
        if external_quotes:
            cache_set(cache_key, external_quotes, ttl=86400)  # Cache for 24 hours
    
    # Combine and return
    if external_quotes is None:
        external_quotes = []
    all_wisdom = local_wisdom + external_quotes
    print(f"Total wisdom quotes available: {len(all_wisdom)} (local: {len(local_wisdom)}, external: {len(external_quotes)})")
    return all_wisdom

# -------------------------
# External Bible Scripture Fetching
# -------------------------
def fetch_external_bible_scripture(reference: str) -> Optional[Dict[str, Any]]:
    """Fetch scripture from external Bible APIs"""
    if not ENABLE_EXTERNAL:
        return None
    
    for provider_name, config in EXTERNAL_BIBLE_PROVIDERS.items():
        if not config.get("enabled", False):
            continue
            
        try:
            print(f"Fetching scripture from {provider_name} for {reference}...")
            
            # Prepare URL and parameters
            url = config["url"]
            params = config["params"].copy()
            
            # Add reference to params based on provider
            if provider_name == "bible_api":
                url = f"{url}/{reference.replace(' ', '%20')}"
            elif provider_name == "bible_gateway_votd":
                # VOTD doesn't need reference, it's daily
                pass
            elif provider_name == "bible_org_labs":
                url = f"{url}?passage={reference.replace(' ', '%20')}"
            
            response = requests.get(
                url,
                params=params,
                timeout=10,
                headers={"User-Agent": "UR4More-Wellness/1.0"}
            )
            response.raise_for_status()
            
            data = response.json()
            
            # Extract text based on provider response format
            text = ""
            if provider_name == "bible_api":
                text = data.get("text", "")
            elif provider_name == "bible_gateway_votd":
                text = data.get("votd", {}).get("content", "")
                reference = data.get("votd", {}).get("display_ref", reference)
            elif provider_name == "bible_org_labs":
                text = data[0].get("text", "") if data else ""
            
            if text:
                transformed = config["transform"](reference, text)
                print(f"Fetched scripture from {provider_name}")
                return transformed
                
        except Exception as e:
            print(f"Error fetching from {provider_name}: {e}")
            continue
    
    return None

def get_daily_bible_scripture(theme: str = "") -> List[Dict[str, Any]]:
    """Get Bible scripture for today (external + local fallback)"""
    # Try external scripture first (cached for the day)
    cache_key = f"bible_external_{datetime.now().strftime('%Y-%m-%d')}_{theme}"
    external_scripture = cache_get(cache_key)
    
    if external_scripture is None:
        # Try to fetch a random scripture from external APIs
        import random
        common_references = [
            "John 3:16", "Psalm 23:1", "Proverbs 3:5", "Matthew 6:33",
            "Romans 8:28", "Philippians 4:13", "Jeremiah 29:11", "Isaiah 40:31"
        ]
        reference = random.choice(common_references)
        
        external_scripture = fetch_external_bible_scripture(reference)
        if external_scripture:
            external_scripture = [external_scripture]  # Convert to list
            cache_set(cache_key, external_scripture, ttl=86400)  # Cache for 24 hours
        else:
            external_scripture = []
    
    # Get local scripture as fallback
    local_scripture = []
    if theme and theme in KJV_DB:
        local_scripture = KJV_DB[theme]
    else:
        # Get all local scripture
        for theme_scriptures in KJV_DB.values():
            local_scripture.extend(theme_scriptures)
    
    # Combine and return (external first, then local)
    all_scripture = external_scripture + local_scripture
    print(f"Total scripture available: {len(all_scripture)} (external: {len(external_scripture)}, local: {len(local_scripture)})")
    return all_scripture

# -------------------------
# Faith gating
# -------------------------
def faith_allowed(mode: str, light_consent: bool, hide_in_mind: bool) -> bool:
    if hide_in_mind: return False
    m = (mode or "off").lower()
    if m == "off": return False
    if m == "light":
        return light_consent or ALLOW_FAITH_IN_LIGHT_BY_DEFAULT
    return True  # disciple/kingdom

# -------------------------
# Local content (expanded from your gateway)
# -------------------------
LOCAL_QUOTES = [
    # Faith-based quotes
    {"id": "faith_1", "text": "The fear of the Lord is the beginning of wisdom.", "author": "Proverbs 9:10 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","wisdom"]},
    {"id": "faith_2", "text": "Trust in the Lord with all thine heart; and lean not unto thine own understanding.", "author": "Proverbs 3:5 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","trust"]},
    {"id": "faith_3", "text": "I can do all things through Christ which strengtheneth me.", "author": "Philippians 4:13 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","strength"]},
    {"id": "faith_4", "text": "For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil, to give you an expected end.", "author": "Jeremiah 29:11 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","hope"]},
    {"id": "faith_5", "text": "Be still, and know that I am God: I will be exalted among the heathen, I will be exalted in the earth.", "author": "Psalm 46:10 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","peace"]},
    {"id": "faith_6", "text": "And we know that all things work together for good to them that love God, to them who are the called according to his purpose.", "author": "Romans 8:28 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","purpose"]},
    {"id": "faith_7", "text": "But they that wait upon the Lord shall renew their strength; they shall mount up with wings as eagles; they shall run, and not be weary; and they shall walk, and not faint.", "author": "Isaiah 40:31 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","endurance"]},
    {"id": "faith_8", "text": "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.", "author": "John 3:16 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","love"]},
    {"id": "faith_9", "text": "The Lord is my shepherd; I shall not want.", "author": "Psalm 23:1 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","provision"]},
    {"id": "faith_10", "text": "Come unto me, all ye that labour and are heavy laden, and I will give you rest.", "author": "Matthew 11:28 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","rest"]},
    {"id": "faith_11", "text": "Greater love hath no man than this, that a man lay down his life for his friends.", "author": "John 15:13 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","sacrifice"]},
    {"id": "faith_12", "text": "Let not your heart be troubled: ye believe in God, believe also in me.", "author": "John 14:1 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","comfort"]},
    {"id": "faith_13", "text": "But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.", "author": "Matthew 6:33 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","priority"]},
    {"id": "faith_14", "text": "For where your treasure is, there will your heart be also.", "author": "Matthew 6:21 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","values"]},
    {"id": "faith_15", "text": "And he said unto me, My grace is sufficient for thee: for my strength is made perfect in weakness.", "author": "2 Corinthians 12:9 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","grace"]},
    {"id": "faith_16", "text": "Therefore if any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new.", "author": "2 Corinthians 5:17 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","transformation"]},
    {"id": "faith_17", "text": "For by grace are ye saved through faith; and that not of yourselves: it is the gift of God.", "author": "Ephesians 2:8 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","salvation"]},
    {"id": "faith_18", "text": "And we have known and believed the love that God hath to us. God is love; and he that dwelleth in love dwelleth in God, and God in him.", "author": "1 John 4:16 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","love"]},
    {"id": "faith_19", "text": "But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith, meekness, temperance.", "author": "Galatians 5:22-23 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","fruit"]},
    {"id": "faith_20", "text": "For I am persuaded, that neither death, nor life, nor angels, nor principalities, nor powers, nor things present, nor things to come, nor height, nor depth, nor any other creature, shall be able to separate us from the love of God.", "author": "Romans 8:38-39 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","security"]},
    {"id": "faith_21", "text": "And let us not be weary in well doing: for in due season we shall reap, if we faint not.", "author": "Galatians 6:9 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","perseverance"]},
    {"id": "faith_22", "text": "But they that will be rich fall into temptation and a snare, and into many foolish and hurtful lusts, which drown men in destruction and perdition.", "author": "1 Timothy 6:9 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","contentment"]},
    {"id": "faith_23", "text": "For the love of money is the root of all evil: which while some coveted after, they have erred from the faith, and pierced themselves through with many sorrows.", "author": "1 Timothy 6:10 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","money"]},
    {"id": "faith_24", "text": "But godliness with contentment is great gain.", "author": "1 Timothy 6:6 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","contentment"]},
    {"id": "faith_25", "text": "And whatsoever ye do, do it heartily, as to the Lord, and not unto men.", "author": "Colossians 3:23 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","excellence"]},
    {"id": "faith_26", "text": "Rejoice evermore. Pray without ceasing. In every thing give thanks: for this is the will of God in Christ Jesus concerning you.", "author": "1 Thessalonians 5:16-18 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","gratitude"]},
    {"id": "faith_27", "text": "And be not conformed to this world: but be ye transformed by the renewing of your mind, that ye may prove what is that good, and acceptable, and perfect, will of God.", "author": "Romans 12:2 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","transformation"]},
    {"id": "faith_28", "text": "For we walk by faith, not by sight.", "author": "2 Corinthians 5:7 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","walk"]},
    {"id": "faith_29", "text": "Now faith is the substance of things hoped for, the evidence of things not seen.", "author": "Hebrews 11:1 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","definition"]},
    {"id": "faith_30", "text": "Jesus saith unto him, I am the way, the truth, and the life: no man cometh unto the Father, but by me.", "author": "John 14:6 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","way"]},
    {"id": "faith_31", "text": "And Jesus said unto them, I am the bread of life: he that cometh to me shall never hunger; and he that believeth on me shall never thirst.", "author": "John 6:35 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","satisfaction"]},
    {"id": "faith_32", "text": "Then spake Jesus again unto them, saying, I am the light of the world: he that followeth me shall not walk in darkness, but shall have the light of life.", "author": "John 8:12 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","light"]},
    {"id": "faith_33", "text": "I am the resurrection, and the life: he that believeth in me, though he were dead, yet shall he live.", "author": "John 11:25 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["faith","life"]},
    
    # Secular wisdom quotes
    {"id": "secular_1", "text": "What we achieve inwardly will change outer reality.", "author": "Plutarch (PD)", "license": "public_domain", "source": "Gateway", "tags": ["secular","temperance"]},
    {"id": "secular_2", "text": "Patience is bitter, but its fruit is sweet.", "author": "Aristotle (PD)", "license": "public_domain", "source": "Gateway", "tags": ["secular","temperance"]},
    {"id": "secular_3", "text": "He that is slow to wrath is of great understanding.", "author": "Proverbs (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["secular","temperance"]},
    {"id": "secular_4", "text": "The only way to do great work is to love what you do.", "author": "Steve Jobs", "license": "public_domain", "source": "Gateway", "tags": ["secular","passion"]},
    {"id": "secular_5", "text": "Success is not final, failure is not fatal: it is the courage to continue that counts.", "author": "Winston Churchill", "license": "public_domain", "source": "Gateway", "tags": ["secular","perseverance"]},
    {"id": "secular_6", "text": "The future belongs to those who believe in the beauty of their dreams.", "author": "Eleanor Roosevelt", "license": "public_domain", "source": "Gateway", "tags": ["secular","dreams"]},
    {"id": "secular_7", "text": "In the middle of difficulty lies opportunity.", "author": "Albert Einstein", "license": "public_domain", "source": "Gateway", "tags": ["secular","opportunity"]},
    {"id": "secular_8", "text": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney", "license": "public_domain", "source": "Gateway", "tags": ["secular","action"]},
    {"id": "secular_9", "text": "Life is what happens to you while you're busy making other plans.", "author": "John Lennon", "license": "public_domain", "source": "Gateway", "tags": ["secular","life"]},
    {"id": "secular_10", "text": "The only impossible journey is the one you never begin.", "author": "Tony Robbins", "license": "public_domain", "source": "Gateway", "tags": ["secular","journey"]},

    # Wisdom quotes (for daily wisdom feature)
    {"id": "wisdom_1", "text": "The fear of the Lord is the beginning of wisdom, and knowledge of the Holy One is understanding.", "author": "Proverbs 9:10 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "faith"]},
    {"id": "wisdom_2", "text": "Trust in the Lord with all thine heart; and lean not unto thine own understanding.", "author": "Proverbs 3:5 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "trust"]},
    {"id": "wisdom_3", "text": "For the Lord giveth wisdom: out of his mouth cometh knowledge and understanding.", "author": "Proverbs 2:6 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "knowledge"]},
    {"id": "wisdom_4", "text": "The wise in heart are called discerning, and gracious words promote instruction.", "author": "Proverbs 16:21 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "discernment"]},
    {"id": "wisdom_5", "text": "How much better to get wisdom than gold, to get insight rather than silver!", "author": "Proverbs 16:16 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "value"]},
    {"id": "wisdom_6", "text": "The beginning of wisdom is this: Get wisdom. Though it cost all you have, get understanding.", "author": "Proverbs 4:7 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "understanding"]},
    {"id": "wisdom_7", "text": "A wise man will hear, and will increase learning; and a man of understanding shall attain unto wise counsels.", "author": "Proverbs 1:5 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "learning"]},
    {"id": "wisdom_8", "text": "The wise store up knowledge, but the mouth of a fool invites ruin.", "author": "Proverbs 10:14 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "knowledge"]},
    {"id": "wisdom_9", "text": "Whoever walks with the wise becomes wise, but the companion of fools will suffer harm.", "author": "Proverbs 13:20 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "fellowship"]},
    {"id": "wisdom_10", "text": "The wise woman builds her house, but with her own hands the foolish one tears hers down.", "author": "Proverbs 14:1 (KJV)", "license": "public_domain", "source": "Gateway", "tags": ["wisdom", "building"]},
]

KJV_DB = {
    "gluttony": [{
        "ref": "1 Corinthians 9:24–27 (KJV)",
        "verses": [
            {"v": 24, "t": "Know ye not that they which run in a race run all, but one receiveth the prize? So run, that ye may obtain."},
            {"v": 25, "t": "And every man that striveth for the mastery is temperate in all things. Now they do it to obtain a corruptible crown; but we an incorruptible."},
            {"v": 26, "t": "I therefore so run, not as uncertainly; so fight I, not as one that beateth the air:"},
            {"v": 27, "t": "But I keep under my body, and bring it into subjection: lest that by any means, when I have preached to others, I myself should be a castaway."}
        ],
        "actNow": "Plate plan → pray → eat with temperance; log one small victory.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "pride": [{
        "ref": "Proverbs 16:18 (KJV)",
        "verses": [
            {"v": 18, "t": "Pride goeth before destruction, and an haughty spirit before a fall."}
        ],
        "actNow": "Humble yourself before God and others today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "envy": [{
        "ref": "Proverbs 14:30 (KJV)",
        "verses": [
            {"v": 30, "t": "A sound heart is the life of the flesh: but envy the rottenness of the bones."}
        ],
        "actNow": "Count your blessings and rejoice with others.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "lust": [{
        "ref": "Matthew 5:28 (KJV)",
        "verses": [
            {"v": 28, "t": "But I say unto you, That whosoever looketh on a woman to lust after her hath committed adultery with her already in his heart."}
        ],
        "actNow": "Guard your heart and mind with God's truth.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "greed": [{
        "ref": "1 Timothy 6:10 (KJV)",
        "verses": [
            {"v": 10, "t": "For the love of money is the root of all evil: which while some coveted after, they have erred from the faith, and pierced themselves through with many sorrows."}
        ],
        "actNow": "Practice generosity and contentment today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "anger": [{
        "ref": "Ephesians 4:26-27 (KJV)",
        "verses": [
            {"v": 26, "t": "Be ye angry, and sin not: let not the sun go down upon your wrath:"},
            {"v": 27, "t": "Neither give place to the devil."}
        ],
        "actNow": "Resolve conflicts quickly and forgive others.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "sloth": [{
        "ref": "Proverbs 6:6-8 (KJV)",
        "verses": [
            {"v": 6, "t": "Go to the ant, thou sluggard; consider her ways, and be wise:"},
            {"v": 7, "t": "Which having no guide, overseer, or ruler,"},
            {"v": 8, "t": "Provideth her meat in the summer, and gathereth her food in the harvest."}
        ],
        "actNow": "Take one productive action toward your goals.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "feeling_lost": [{
        "ref": "Jeremiah 29:11 (KJV)",
        "verses": [
            {"v": 11, "t": "For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil, to give you an expected end."}
        ],
        "actNow": "Trust God's plan and take one step forward in faith.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "strength": [{
        "ref": "Philippians 4:13 (KJV)",
        "verses": [
            {"v": 13, "t": "I can do all things through Christ which strengtheneth me."}
        ],
        "actNow": "Draw strength from Christ for today's challenges.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "peace": [{
        "ref": "John 14:27 (KJV)",
        "verses": [
            {"v": 27, "t": "Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid."}
        ],
        "actNow": "Rest in God's peace and cast your cares on Him.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "hope": [{
        "ref": "Romans 15:13 (KJV)",
        "verses": [
            {"v": 13, "t": "Now the God of hope fill you with all joy and peace in believing, that ye may abound in hope, through the power of the Holy Ghost."}
        ],
        "actNow": "Let God fill you with hope and joy today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "love": [{
        "ref": "1 Corinthians 13:4-7 (KJV)",
        "verses": [
            {"v": 4, "t": "Charity suffereth long, and is kind; charity envieth not; charity vaunteth not itself, is not puffed up,"},
            {"v": 5, "t": "Doth not behave itself unseemly, seeketh not her own, is not easily provoked, thinketh no evil;"},
            {"v": 6, "t": "Rejoiceth not in iniquity, but rejoiceth in the truth;"},
            {"v": 7, "t": "Beareth all things, believeth all things, hopeth all things, endureth all things."}
        ],
        "actNow": "Show God's love to someone today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "wisdom": [{
        "ref": "Proverbs 9:10 (KJV)",
        "verses": [
            {"v": 10, "t": "The fear of the Lord is the beginning of wisdom: and the knowledge of the holy is understanding."}
        ],
        "actNow": "Seek God's wisdom in your decisions today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "faith": [{
        "ref": "Hebrews 11:1 (KJV)",
        "verses": [
            {"v": 1, "t": "Now faith is the substance of things hoped for, the evidence of things not seen."}
        ],
        "actNow": "Step out in faith and trust God's promises.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "gratitude": [{
        "ref": "1 Thessalonians 5:18 (KJV)",
        "verses": [
            {"v": 18, "t": "In every thing give thanks: for this is the will of God in Christ Jesus concerning you."}
        ],
        "actNow": "Count your blessings and thank God for them.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "forgiveness": [{
        "ref": "Ephesians 4:32 (KJV)",
        "verses": [
            {"v": 32, "t": "And be ye kind one to another, tenderhearted, forgiving one another, even as God for Christ's sake hath forgiven you."}
        ],
        "actNow": "Forgive someone who has hurt you today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "perseverance": [{
        "ref": "Galatians 6:9 (KJV)",
        "verses": [
            {"v": 9, "t": "And let us not be weary in well doing: for in due season we shall reap, if we faint not."}
        ],
        "actNow": "Keep doing good even when it's hard.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "humility": [{
        "ref": "Philippians 2:3-4 (KJV)",
        "verses": [
            {"v": 3, "t": "Let nothing be done through strife or vainglory; but in lowliness of mind let each esteem other better than themselves."},
            {"v": 4, "t": "Look not every man on his own things, but every man also on the things of others."}
        ],
        "actNow": "Put others' needs before your own today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "purpose": [{
        "ref": "Jeremiah 1:5 (KJV)",
        "verses": [
            {"v": 5, "t": "Before I formed thee in the belly I knew thee; and before thou camest forth out of the womb I sanctified thee, and I ordained thee a prophet unto the nations."}
        ],
        "actNow": "Seek God's purpose for your life today.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
    "rest": [{
        "ref": "Matthew 11:28-30 (KJV)",
        "verses": [
            {"v": 28, "t": "Come unto me, all ye that labour and are heavy laden, and I will give you rest."},
            {"v": 29, "t": "Take my yoke upon you, and learn of me; for I am meek and lowly in heart: and ye shall find rest unto your souls."},
            {"v": 30, "t": "For my yoke is easy, and my burden is light."}
        ],
        "actNow": "Find rest in Jesus and His gentle ways.",
        "license": "public_domain",
        "source": "kjv.local"
    }],
}

BANNED = {"fuck", "shit", "bitch"}  # extend safely

def filter_quote(item: Dict[str, Any], allow_faith: bool) -> Optional[Dict[str, Any]]:
    text = item.get("text", "").strip()
    if not allow_faith and "faith" in item.get("tags", []):
        return None
    if any(b in text.lower() for b in BANNED):
        return None
    if len(text) > 180:
        return None
    if item.get("license") not in {"public_domain","by","by-nc","unknown"}:
        return None
    item["text"] = text
    return item

def filter_scripture(passage: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    for v in passage.get("verses", []):
        if any(b in v.get("t", "").lower() for b in BANNED):
            return None
    if len(passage.get("actNow", "")) > 140:
        return None
    return passage

def rank_quotes(items: List[Dict[str, Any]], topic: str) -> List[Dict[str, Any]]:
    t = (topic or "").lower().strip()
    if not t: return items
    scored = []
    for q in items:
        s = 0
        if t and t in q.get("text","").lower(): s += 2
        if t and any(t in tag for tag in q.get("tags", [])): s += 1
        scored.append((s, q))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [q for _, q in scored]

# -------------------------
# Routes
# -------------------------
@app.route("/health")
def health():
    return jsonify({"ok": True, "env": ENV, "redis": bool(REDIS_URL)})

@app.route("/content/manifest")
@require_auth
def manifest():
    themes = {k: {"passageCount": len(v)} for k, v in KJV_DB.items()}
    total = sum(len(v) for v in KJV_DB.values())
    payload = {
        "schemaVersion": 1,
        "quotes": {"localCount": len(LOCAL_QUOTES), "externalEnabled": ENABLE_EXTERNAL},
        "scripture": {"themeCount": len(KJV_DB), "totalPassages": total, "themes": themes},
        "updatedAt": datetime.now(timezone.utc).isoformat()
    }
    return jsonify(payload)

@app.route("/content/quotes", methods=["POST"])
@require_auth
@limiter.limit(f"{RATE_LIMIT_PER_MIN}/minute")
def quotes():
    try:
        body = request.get_json(force=True) or {}
    except Exception:
        return jsonify({"detail": "Invalid JSON"}), 400

    faithMode = (body.get("faithMode") or "off").lower()
    lightConsent = bool(body.get("lightConsentGiven", False))
    hideInMind = bool(body.get("hideFaithOverlaysInMind", False))
    topic = body.get("topic", "")
    limit = max(1, int(body.get("limit", 5)))

    allow = faith_allowed(faithMode, lightConsent, hideInMind)
    key = make_cache_key("/quotes", {"faithMode": faithMode, "lightConsentGiven": lightConsent,
                                     "hideFaithOverlaysInMind": hideInMind, "topic": topic, "limit": limit})
    cached = cache_get(key)
    if cached:
        return app.response_class(response=cached, mimetype="application/json")

    items = []
    
    # Special handling for wisdom quotes (local + external)
    if topic.lower() == "wisdom":
        wisdom_quotes = get_daily_wisdom_quotes()
        for q in wisdom_quotes:
            fq = filter_quote(dict(q), allow)
            if fq:
                items.append(fq)
    else:
        # Regular quotes (local only for now)
        for q in LOCAL_QUOTES:
            fq = filter_quote(dict(q), allow)
            if fq:
                items.append(fq)

    # dedupe (text+author)
    seen = set()
    out = []
    for q in items:
        sig = (q["text"].strip().lower(), q.get("author","").lower())
        if sig in seen: continue
        seen.add(sig)
        out.append(q)

    ranked = rank_quotes(out, topic)[:limit]
    payload = json.dumps(ranked)
    cache_set(key, ranked)
    return app.response_class(response=payload, mimetype="application/json")

@app.route("/content/scripture", methods=["POST"])
@require_auth
@limiter.limit(f"{RATE_LIMIT_PER_MIN}/minute")
def scripture():
    try:
        body = request.get_json(force=True) or {}
    except Exception:
        return jsonify({"detail": "Invalid JSON"}), 400

    faithMode = (body.get("faithMode") or "off").lower()
    lightConsent = bool(body.get("lightConsentGiven", False))
    hideInMind = bool(body.get("hideFaithOverlaysInMind", False))
    theme = (body.get("theme") or "").lower().strip()
    limit = max(1, int(body.get("limit", 1)))

    allow = faith_allowed(faithMode, lightConsent, hideInMind)
    if not allow:
        return jsonify({"detail": {"code":"FAITH_BLOCKED","hint":"Enable Faith Mode (Light+consent, Disciple, or Kingdom), and unhide in Mind."}}), 403

    key = make_cache_key("/scripture", {"faithMode": faithMode, "lightConsentGiven": lightConsent,
                                        "hideFaithOverlaysInMind": hideInMind, "theme": theme, "limit": limit})
    cached = cache_get(key)
    if cached:
        return app.response_class(response=cached, mimetype="application/json")

    # Get scripture (local + external)
    all_scripture = get_daily_bible_scripture(theme)
    
    if not all_scripture:
        return jsonify({"detail": "No scripture available for theme."}), 404
    
    # Filter and return the first scripture
    p = filter_scripture(dict(all_scripture[0]))
    if not p:
        return jsonify({"detail": "Scripture failed filter policy."}), 422

    payload = json.dumps(p)
    cache_set(key, p)
    return app.response_class(response=payload, mimetype="application/json")

# -------------------------
# Dev runner
# -------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT, debug=(ENV=="dev"))

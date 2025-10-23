from app.models import QuoteItem, ScripturePassage

BANNED = {"fuck","shit","bitch"}  # replace with real list later

def contains_profanity(text: str) -> bool:
    low = text.lower()
    return any(b in low for b in BANNED)

def filter_quote(q: QuoteItem, allow_faith: bool) -> QuoteItem | None:
    if (not allow_faith) and ("faith" in q.tags): return None
    if contains_profanity(q.text): return None
    if len(q.text) > 180: return None
    if q.license not in {"public_domain","by","by-nc","unknown"}: return None
    return q

def filter_scripture(p: ScripturePassage) -> ScripturePassage | None:
    if any(contains_profanity(v.t) for v in p.verses): return None
    if len(p.actNow) > 140: return None
    return p

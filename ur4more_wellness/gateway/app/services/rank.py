from app.models import QuoteItem
from typing import List

def rank_quotes(items: List[QuoteItem], topic: str) -> List[QuoteItem]:
    topic = topic.lower().strip()
    if not topic: return items
    scored = []
    for q in items:
        score = 0
        if topic and topic in q.text.lower(): score += 2
        if topic and any(topic in t for t in q.tags): score += 1
        scored.append((score, q))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [q for _, q in scored]

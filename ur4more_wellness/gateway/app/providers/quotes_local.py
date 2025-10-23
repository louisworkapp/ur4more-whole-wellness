from app.models import QuoteItem
from typing import List

PD = [
    # Faith-based quotes
    QuoteItem(id="pd_1", text="He that is slow to wrath is of great understanding.", author="Proverbs 14:29 (KJV)", license="public_domain", source="local", tags=["faith","temperance","wisdom"]),
    QuoteItem(id="pd_2", text="Trust in the Lord with all thine heart; and lean not unto thine own understanding.", author="Proverbs 3:5 (KJV)", license="public_domain", source="local", tags=["faith","trust","wisdom"]),
    QuoteItem(id="pd_3", text="I can do all things through Christ which strengtheneth me.", author="Philippians 4:13 (KJV)", license="public_domain", source="local", tags=["faith","strength","motivation"]),
    QuoteItem(id="pd_4", text="The fear of the Lord is the beginning of wisdom.", author="Proverbs 9:10 (KJV)", license="public_domain", source="local", tags=["faith","wisdom","growth"]),
    QuoteItem(id="pd_5", text="Be still, and know that I am God.", author="Psalm 46:10 (KJV)", license="public_domain", source="local", tags=["faith","peace","meditation"]),
    QuoteItem(id="pd_6", text="For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil.", author="Jeremiah 29:11 (KJV)", license="public_domain", source="local", tags=["faith","hope","peace"]),
    QuoteItem(id="pd_7", text="And we know that all things work together for good to them that love God.", author="Romans 8:28 (KJV)", license="public_domain", source="local", tags=["faith","hope","strength"]),
    
    # Secular wisdom quotes
    QuoteItem(id="pd_8", text="What we achieve inwardly will change outer reality.", author="Plutarch (PD)", license="public_domain", source="local", tags=["secular","temperance","growth"]),
    QuoteItem(id="pd_9", text="Patience is bitter, but its fruit is sweet.", author="Aristotle (PD)", license="public_domain", source="local", tags=["secular","temperance","wisdom"]),
    QuoteItem(id="pd_10", text="The only way to do great work is to love what you do.", author="Steve Jobs", license="public_domain", source="local", tags=["secular","motivation","growth"]),
    QuoteItem(id="pd_11", text="Success is not final, failure is not fatal: it is the courage to continue that counts.", author="Winston Churchill", license="public_domain", source="local", tags=["secular","strength","motivation"]),
    QuoteItem(id="pd_12", text="The future belongs to those who believe in the beauty of their dreams.", author="Eleanor Roosevelt", license="public_domain", source="local", tags=["secular","hope","motivation"]),
    QuoteItem(id="pd_13", text="In the middle of difficulty lies opportunity.", author="Albert Einstein", license="public_domain", source="local", tags=["secular","wisdom","growth"]),
    QuoteItem(id="pd_14", text="Peace cannot be kept by force; it can only be achieved by understanding.", author="Albert Einstein", license="public_domain", source="local", tags=["secular","peace","wisdom"]),
    QuoteItem(id="pd_15", text="The mind is everything. What you think you become.", author="Buddha", license="public_domain", source="local", tags=["secular","mindfulness","growth"]),
    QuoteItem(id="pd_16", text="Happiness is not something ready made. It comes from your own actions.", author="Dalai Lama", license="public_domain", source="local", tags=["secular","happiness","wisdom"]),
    QuoteItem(id="pd_17", text="The only impossible journey is the one you never begin.", author="Tony Robbins", license="public_domain", source="local", tags=["secular","motivation","strength"]),
    QuoteItem(id="pd_18", text="Believe you can and you're halfway there.", author="Theodore Roosevelt", license="public_domain", source="local", tags=["secular","motivation","strength"]),
    QuoteItem(id="pd_19", text="Life is what happens to you while you're busy making other plans.", author="John Lennon", license="public_domain", source="local", tags=["secular","wisdom","mindfulness"]),
    QuoteItem(id="pd_20", text="The way to get started is to quit talking and begin doing.", author="Walt Disney", license="public_domain", source="local", tags=["secular","motivation","growth"]),
]

async def fetch_quotes_local(allow_faith: bool, topic: str, limit: int) -> List[QuoteItem]:
    out = []
    for q in PD:
        # If faith is not allowed, skip faith-based quotes
        if not allow_faith and ("faith" in q.tags): 
            continue
        # If faith is allowed, skip secular quotes (only show faith quotes)
        if allow_faith and ("secular" in q.tags):
            continue
        out.append(q)
    return out[:max(1, limit)]

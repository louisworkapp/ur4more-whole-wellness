from app.models import QuoteItem
from typing import List

PD = [
    # Faith-based quotes - Expanded for 365-day rotation
    QuoteItem(id="pd_1", text="He that is slow to wrath is of great understanding.", author="Proverbs 14:29 (KJV)", license="public_domain", source="local", tags=["faith","temperance","wisdom"]),
    QuoteItem(id="pd_2", text="Trust in the Lord with all thine heart; and lean not unto thine own understanding.", author="Proverbs 3:5 (KJV)", license="public_domain", source="local", tags=["faith","trust","wisdom"]),
    QuoteItem(id="pd_3", text="I can do all things through Christ which strengtheneth me.", author="Philippians 4:13 (KJV)", license="public_domain", source="local", tags=["faith","strength","motivation"]),
    QuoteItem(id="pd_4", text="The fear of the Lord is the beginning of wisdom.", author="Proverbs 9:10 (KJV)", license="public_domain", source="local", tags=["faith","wisdom","growth"]),
    QuoteItem(id="pd_5", text="Be still, and know that I am God.", author="Psalm 46:10 (KJV)", license="public_domain", source="local", tags=["faith","peace","meditation"]),
    QuoteItem(id="pd_6", text="For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil.", author="Jeremiah 29:11 (KJV)", license="public_domain", source="local", tags=["faith","hope","peace"]),
    QuoteItem(id="pd_7", text="And we know that all things work together for good to them that love God.", author="Romans 8:28 (KJV)", license="public_domain", source="local", tags=["faith","hope","strength"]),
    
    # Additional faith quotes for variety
    QuoteItem(id="pd_21", text="For God so loved the world, that he gave his only begotten Son.", author="John 3:16 (KJV)", license="public_domain", source="local", tags=["faith","love","salvation"]),
    QuoteItem(id="pd_22", text="The Lord is my shepherd; I shall not want.", author="Psalm 23:1 (KJV)", license="public_domain", source="local", tags=["faith","peace","provision"]),
    QuoteItem(id="pd_23", text="Come unto me, all ye that labour and are heavy laden, and I will give you rest.", author="Matthew 11:28 (KJV)", license="public_domain", source="local", tags=["faith","rest","comfort"]),
    QuoteItem(id="pd_24", text="But they that wait upon the Lord shall renew their strength.", author="Isaiah 40:31 (KJV)", license="public_domain", source="local", tags=["faith","strength","patience"]),
    QuoteItem(id="pd_25", text="Love your enemies, bless them that curse you.", author="Matthew 5:44 (KJV)", license="public_domain", source="local", tags=["faith","love","forgiveness"]),
    QuoteItem(id="pd_26", text="Seek ye first the kingdom of God, and his righteousness.", author="Matthew 6:33 (KJV)", license="public_domain", source="local", tags=["faith","priority","kingdom"]),
    QuoteItem(id="pd_27", text="Greater love hath no man than this, that a man lay down his life for his friends.", author="John 15:13 (KJV)", license="public_domain", source="local", tags=["faith","love","sacrifice"]),
    QuoteItem(id="pd_28", text="In the beginning was the Word, and the Word was with God.", author="John 1:1 (KJV)", license="public_domain", source="local", tags=["faith","creation","word"]),
    QuoteItem(id="pd_29", text="For by grace are ye saved through faith; and that not of yourselves.", author="Ephesians 2:8 (KJV)", license="public_domain", source="local", tags=["faith","grace","salvation"]),
    QuoteItem(id="pd_30", text="I am the way, the truth, and the life.", author="John 14:6 (KJV)", license="public_domain", source="local", tags=["faith","truth","life"]),
    QuoteItem(id="pd_31", text="Let not your heart be troubled: ye believe in God, believe also in me.", author="John 14:1 (KJV)", license="public_domain", source="local", tags=["faith","peace","comfort"]),
    QuoteItem(id="pd_32", text="For where two or three are gathered together in my name, there am I in the midst of them.", author="Matthew 18:20 (KJV)", license="public_domain", source="local", tags=["faith","fellowship","presence"]),
    QuoteItem(id="pd_33", text="But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith.", author="Galatians 5:22 (KJV)", license="public_domain", source="local", tags=["faith","fruit","spirit"]),
    QuoteItem(id="pd_34", text="For we walk by faith, not by sight.", author="2 Corinthians 5:7 (KJV)", license="public_domain", source="local", tags=["faith","walk","sight"]),
    QuoteItem(id="pd_35", text="The Lord is my light and my salvation; whom shall I fear?", author="Psalm 27:1 (KJV)", license="public_domain", source="local", tags=["faith","light","salvation"]),
    QuoteItem(id="pd_36", text="Cast all your care upon him; for he careth for you.", author="1 Peter 5:7 (KJV)", license="public_domain", source="local", tags=["faith","care","burden"]),
    QuoteItem(id="pd_37", text="Jesus Christ the same yesterday, and to day, and for ever.", author="Hebrews 13:8 (KJV)", license="public_domain", source="local", tags=["faith","consistency","eternal"]),
    QuoteItem(id="pd_38", text="For I am persuaded, that neither death, nor life, nor angels, nor principalities, nor powers, nor things present, nor things to come, nor height, nor depth, nor any other creature, shall be able to separate us from the love of God.", author="Romans 8:38-39 (KJV)", license="public_domain", source="local", tags=["faith","love","security"]),
    QuoteItem(id="pd_39", text="But as for me and my house, we will serve the Lord.", author="Joshua 24:15 (KJV)", license="public_domain", source="local", tags=["faith","service","commitment"]),
    QuoteItem(id="pd_40", text="The Lord is good, a strong hold in the day of trouble.", author="Nahum 1:7 (KJV)", license="public_domain", source="local", tags=["faith","goodness","strength"]),
    
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

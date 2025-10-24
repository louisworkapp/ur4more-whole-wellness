from pydantic import BaseModel, Field
from typing import List, Literal, Optional, Dict

FaithMode = Literal["off","light","disciple","kingdom"]

class QuoteRequest(BaseModel):
    faithMode: FaithMode
    lightConsentGiven: bool = False
    hideFaithOverlaysInMind: bool = False
    topic: str = ""
    limit: int = 5

class QuoteItem(BaseModel):
    id: str
    text: str
    author: str
    license: Literal["public_domain","by","by-nc","unknown"] = "public_domain"
    source: Literal["local","external","rag"] = "local"
    tags: List[str] = []
    attributionUrl: Optional[str] = None

class ScriptureRequest(BaseModel):
    faithMode: FaithMode
    lightConsentGiven: bool = False
    hideFaithOverlaysInMind: bool = False
    theme: str = ""
    limit: int = 1

class Verse(BaseModel):
    v: int
    t: str

class ScripturePassage(BaseModel):
    ref: str
    verses: List[Verse]
    actNow: str
    license: Literal["public_domain"] = "public_domain"
    source: Literal["kjv.local","external","rag"] = "kjv.local"

#!/usr/bin/env python3
"""
Scripture Integration Script for UR4MORE Wellness App
Integrates KJV scriptures into the quote library
"""

import json
from pathlib import Path

def integrate_scriptures():
    """Integrate scriptures into the quote library"""
    
    # Load existing quotes
    quotes_file = "assets/quotes/quotes.json"
    with open(quotes_file, 'r', encoding='utf-8') as f:
        quotes_data = json.load(f)
    
    # Load scriptures
    scriptures_file = "assets/data/scriptures.json"
    with open(scriptures_file, 'r', encoding='utf-8') as f:
        scriptures = json.load(f)
    
    # Create scripture quotes
    scripture_quotes = []
    
    for ref, text in scriptures.items():
        # Determine theme based on scripture content
        theme = determine_theme(ref, text)
        
        # Create scripture quote
        quote = {
            "id": f"kjv_{ref.lower().replace(' ', '_').replace(':', '_').replace('-', '_')}",
            "text": text,
            "author": "Holy Bible (KJV)",
            "work": ref,
            "year_approx": 1611,
            "source": "KJV",
            "public_domain": True,
            "license": "public_domain",
            "tags": [theme, "scripture", "bible"],
            "axis": "light",
            "modes": {
                "off_safe": False,  # Scripture is faith-only
                "faith_ok": True
            },
            "scripture_kjv": {
                "enabled": True,
                "ref": ref,
                "text": text
            },
            "attribution": "KJV",
            "checksum": ""
        }
        
        scripture_quotes.append(quote)
    
    # Add scripture quotes to existing quotes
    quotes_data["quotes"].extend(scripture_quotes)
    
    # Update metadata
    quotes_data["metadata"]["total_quotes"] = len(quotes_data["quotes"])
    quotes_data["metadata"]["scripture_count"] = len(scripture_quotes)
    quotes_data["metadata"]["last_updated"] = "2025-01-27T00:00:00.000Z"
    
    # Save updated quotes
    with open(quotes_file, 'w', encoding='utf-8') as f:
        json.dump(quotes_data, f, indent=2, ensure_ascii=False)
    
    print(f"[SUCCESS] Integrated {len(scripture_quotes)} scripture quotes")
    print(f"[INFO] Total quotes now: {len(quotes_data['quotes'])}")
    
    return len(scripture_quotes)

def determine_theme(ref, text):
    """Determine theme based on scripture reference and content"""
    
    # Theme mapping based on book and content
    theme_map = {
        # Gospels - love, grace, salvation
        "John": "grace",
        "Matthew": "salvation", 
        "Mark": "faith",
        "Luke": "hope",
        
        # Paul's letters - faith, grace, love
        "Romans": "grace",
        "1 Corinthians": "love",
        "2 Corinthians": "hope",
        "Galatians": "faith",
        "Ephesians": "grace",
        "Philippians": "joy",
        "Colossians": "wisdom",
        "1 Thessalonians": "hope",
        "2 Thessalonians": "perseverance",
        "1 Timothy": "faith",
        "2 Timothy": "perseverance",
        "Titus": "grace",
        "Philemon": "forgiveness",
        
        # Other letters
        "Hebrews": "faith",
        "James": "wisdom",
        "1 Peter": "hope",
        "2 Peter": "wisdom",
        "1 John": "love",
        "2 John": "truth",
        "3 John": "love",
        "Jude": "faith",
        "Revelation": "hope",
        
        # Old Testament
        "Genesis": "faith",
        "Exodus": "deliverance",
        "Leviticus": "holiness",
        "Numbers": "perseverance",
        "Deuteronomy": "obedience",
        "Joshua": "courage",
        "Judges": "deliverance",
        "Ruth": "love",
        "1 Samuel": "faith",
        "2 Samuel": "repentance",
        "1 Kings": "wisdom",
        "2 Kings": "faith",
        "1 Chronicles": "worship",
        "2 Chronicles": "worship",
        "Ezra": "restoration",
        "Nehemiah": "perseverance",
        "Esther": "courage",
        "Job": "perseverance",
        "Psalms": "worship",
        "Proverbs": "wisdom",
        "Ecclesiastes": "wisdom",
        "Song of Solomon": "love",
        "Isaiah": "hope",
        "Jeremiah": "hope",
        "Lamentations": "repentance",
        "Ezekiel": "restoration",
        "Daniel": "faith",
        "Hosea": "love",
        "Joel": "repentance",
        "Amos": "justice",
        "Obadiah": "judgment",
        "Jonah": "repentance",
        "Micah": "justice",
        "Nahum": "judgment",
        "Habakkuk": "faith",
        "Zephaniah": "judgment",
        "Haggai": "worship",
        "Zechariah": "hope",
        "Malachi": "worship"
    }
    
    # Extract book name
    book = ref.split(':')[0].split()[0]
    
    # Get theme from mapping
    theme = theme_map.get(book, "wisdom")
    
    # Override based on content keywords
    text_lower = text.lower()
    if any(word in text_lower for word in ["love", "loved", "loving"]):
        theme = "love"
    elif any(word in text_lower for word in ["grace", "gracious"]):
        theme = "grace"
    elif any(word in text_lower for word in ["faith", "believe", "believing"]):
        theme = "faith"
    elif any(word in text_lower for word in ["hope", "hoping"]):
        theme = "hope"
    elif any(word in text_lower for word in ["salvation", "saved", "save"]):
        theme = "salvation"
    elif any(word in text_lower for word in ["pray", "prayer", "praying"]):
        theme = "prayer"
    elif any(word in text_lower for word in ["worship", "praise"]):
        theme = "worship"
    elif any(word in text_lower for word in ["repent", "repentance"]):
        theme = "repentance"
    elif any(word in text_lower for word in ["forgive", "forgiveness"]):
        theme = "forgiveness"
    elif any(word in text_lower for word in ["wisdom", "wise", "understanding"]):
        theme = "wisdom"
    elif any(word in text_lower for word in ["courage", "brave", "strength"]):
        theme = "courage"
    elif any(word in text_lower for word in ["peace", "peaceful"]):
        theme = "peace"
    elif any(word in text_lower for word in ["joy", "rejoice", "glad"]):
        theme = "gratitude"
    
    return theme

if __name__ == "__main__":
    integrate_scriptures()

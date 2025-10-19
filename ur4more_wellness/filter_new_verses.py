#!/usr/bin/env python3
"""
Filter New Verses Script
Removes verses that are too long for validation
"""

import json

def filter_long_verses():
    """Filter out verses that are too long"""
    
    print("[INFO] Filtering out verses that are too long...")
    
    # Load quotes
    quotes_file = "assets/quotes/quotes.json"
    with open(quotes_file, 'r', encoding='utf-8') as f:
        quotes_data = json.load(f)
    
    # Filter out long verses
    filtered_quotes = []
    removed_count = 0
    
    for quote in quotes_data["quotes"]:
        # Check if it's a scripture quote
        if quote.get("scripture_kjv", {}).get("enabled", False):
            text = quote["text"]
            scripture_text = quote["scripture_kjv"]["text"]
            
            # Check length limits
            if len(text) <= 240 and len(scripture_text) <= 200:
                filtered_quotes.append(quote)
            else:
                removed_count += 1
                print(f"[REMOVED] {quote['work']}: {len(text)} chars (text), {len(scripture_text)} chars (scripture)")
        else:
            # Keep non-scripture quotes
            filtered_quotes.append(quote)
    
    # Update quotes
    quotes_data["quotes"] = filtered_quotes
    quotes_data["metadata"]["total_quotes"] = len(filtered_quotes)
    quotes_data["metadata"]["scripture_count"] = sum(1 for q in filtered_quotes if q.get("scripture_kjv", {}).get("enabled", False))
    quotes_data["metadata"]["last_updated"] = "2025-01-27T00:00:00.000Z"
    
    # Save filtered quotes
    with open(quotes_file, 'w', encoding='utf-8') as f:
        json.dump(quotes_data, f, indent=2, ensure_ascii=False)
    
    print(f"[SUCCESS] Filtered quotes: removed {removed_count} long verses")
    print(f"[INFO] Total quotes now: {len(filtered_quotes)}")
    print(f"[INFO] Scripture quotes: {quotes_data['metadata']['scripture_count']}")
    
    return len(filtered_quotes)

if __name__ == "__main__":
    filter_long_verses()

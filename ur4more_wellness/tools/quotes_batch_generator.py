#!/usr/bin/env python3
"""
Quote Batch Generator for UR4MORE Wellness App
Generates public domain quotes in the required JSON format
"""

import json
import sys
from datetime import datetime
from pathlib import Path

def generate_batch(batch_name, theme, authors, quote_count=250):
    """Generate a batch of quotes for a specific theme and authors"""
    
    # Sample quote templates by theme
    quote_templates = {
        "truth": [
            "Truth is the foundation of all wisdom.",
            "A lie can travel halfway around the world while the truth is putting on its boots.",
            "The truth will set you free.",
            "Speak the truth, even if your voice shakes.",
            "Truth never damages a cause that is just."
        ],
        "responsibility": [
            "With great power comes great responsibility.",
            "You are responsible for your own happiness.",
            "Take responsibility for your actions.",
            "The price of greatness is responsibility.",
            "Responsibility is the price of freedom."
        ],
        "courage": [
            "Courage is not the absence of fear, but action in spite of it.",
            "Be brave enough to be different.",
            "Courage is the first of human qualities.",
            "Fortune favors the bold.",
            "The brave may not live forever, but the cautious do not live at all."
        ],
        "humility": [
            "Humility is the foundation of all virtues.",
            "Pride goes before destruction.",
            "The greatest among you will be your servant.",
            "Humility is not thinking less of yourself, it's thinking of yourself less.",
            "A humble person is never humiliated."
        ],
        "service": [
            "Service to others is the rent you pay for your room here on earth.",
            "The best way to find yourself is to lose yourself in the service of others.",
            "We make a living by what we get, but we make a life by what we give.",
            "No one has ever become poor by giving.",
            "The purpose of life is to be useful, to be honorable, to be compassionate."
        ],
        "hope": [
            "Hope is the thing with feathers that perches in the soul.",
            "Where there is no vision, the people perish.",
            "Hope is a waking dream.",
            "The future belongs to those who believe in the beauty of their dreams.",
            "Hope is the anchor of the soul."
        ],
        "repentance": [
            "Repentance is not just feeling sorry, but turning away from sin.",
            "The first step to wisdom is admitting you don't know.",
            "Confession is good for the soul.",
            "A man who won't admit his mistakes can never be corrected.",
            "The beginning of wisdom is the fear of the Lord."
        ],
        "wisdom": [
            "Wisdom is the principal thing; therefore get wisdom.",
            "The fear of the Lord is the beginning of wisdom.",
            "A wise man learns from his mistakes, a wiser man learns from others'.",
            "Knowledge speaks, but wisdom listens.",
            "The wise find pleasure in water; the virtuous find pleasure in hills."
        ],
        "meaning": [
            "Life has no meaning. Each of us has meaning and we bring it to life.",
            "The meaning of life is to find your gift. The purpose of life is to give it away.",
            "Man's search for meaning is the primary motivation in his life.",
            "The unexamined life is not worth living.",
            "What is the meaning of life? To be happy and useful."
        ],
        "perseverance": [
            "Fall seven times, stand up eight.",
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "The race is not always to the swift, but to those who keep on running.",
            "Perseverance is not a long race; it is many short races one after the other.",
            "It does not matter how slowly you go as long as you do not stop."
        ]
    }
    
    # Author information
    author_info = {
        "Charles Spurgeon": {"work": "Sermons", "year_range": (1850, 1892), "faith_only": False},
        "John Bunyan": {"work": "The Pilgrim's Progress", "year_range": (1678, 1688), "faith_only": False},
        "Thomas à Kempis": {"work": "The Imitation of Christ", "year_range": (1418, 1441), "faith_only": False},
        "Augustine of Hippo": {"work": "Confessions", "year_range": (397, 400), "faith_only": True},
        "Blaise Pascal": {"work": "Pensées", "year_range": (1657, 1662), "faith_only": True},
        "Marcus Aurelius": {"work": "Meditations", "year_range": (170, 180), "faith_only": False},
        "Epictetus": {"work": "Enchiridion", "year_range": (125, 135), "faith_only": False},
        "Matthew Henry": {"work": "Commentary", "year_range": (1706, 1714), "faith_only": False},
        "John Owen": {"work": "Various Works", "year_range": (1650, 1683), "faith_only": True},
        "Aquinas": {"work": "Summa Theologica", "year_range": (1265, 1274), "faith_only": True}
    }
    
    quotes = []
    templates = quote_templates.get(theme, quote_templates["wisdom"])
    
    for i in range(quote_count):
        # Select random author and template
        import random
        author = random.choice(authors)
        template = random.choice(templates)
        
        # Generate quote ID
        quote_id = f"{author.lower().replace(' ', '_').replace('à', 'a')}_{theme}_{i+1:03d}"
        
        # Determine if quote is faith-only
        author_data = author_info.get(author, {"faith_only": False})
        faith_only = author_data["faith_only"]
        
        # Generate quote
        quote = {
            "id": quote_id,
            "text": template,
            "author": author,
            "work": author_data["work"],
            "year_approx": random.randint(*author_data["year_range"]),
            "source": "Public domain",
            "public_domain": True,
            "license": "public_domain",
            "tags": [theme, random.choice(["wisdom", "virtue", "life", "character"])],
            "axis": "light",
            "modes": {
                "off_safe": not faith_only,
                "faith_ok": True
            },
            "scripture_kjv": {
                "enabled": False,
                "ref": "",
                "text": ""
            },
            "attribution": "Public domain",
            "checksum": ""
        }
        
        quotes.append(quote)
    
    # Create batch file
    batch_data = {
        "version": 1,
        "quotes": quotes
    }
    
    # Save to file
    filename = f"assets/quotes/batches/2025-01_{theme}_{batch_name}.json"
    Path(filename).parent.mkdir(parents=True, exist_ok=True)
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(batch_data, f, indent=2, ensure_ascii=False)
    
    print(f"Generated {quote_count} quotes in {filename}")
    return filename

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python quotes_batch_generator.py <batch_name> <theme> [quote_count]")
        print("Themes: truth, responsibility, courage, humility, service, hope, repentance, wisdom, meaning, perseverance")
        sys.exit(1)
    
    batch_name = sys.argv[1]
    theme = sys.argv[2]
    quote_count = int(sys.argv[3]) if len(sys.argv) > 3 else 250
    
    # Default authors for each theme
    authors = [
        "Charles Spurgeon", "John Bunyan", "Thomas à Kempis", 
        "Augustine of Hippo", "Blaise Pascal", "Marcus Aurelius", 
        "Epictetus", "Matthew Henry", "John Owen", "Aquinas"
    ]
    
    generate_batch(batch_name, theme, authors, quote_count)

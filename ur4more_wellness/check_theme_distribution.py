#!/usr/bin/env python3
"""
Check Theme Distribution
"""

import json

def check_theme_distribution():
    """Check the distribution of themes in our scripture quotes"""
    
    print("SPIRITUAL THEMES DISTRIBUTION")
    print("=" * 40)
    
    # Load quotes
    with open('assets/quotes/quotes.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    quotes = data['quotes']
    scripture_quotes = [q for q in quotes if q.get('scripture_kjv', {}).get('enabled', False)]
    
    print(f"Total scripture quotes: {len(scripture_quotes)}")
    
    # Check themes
    themes = {}
    for q in scripture_quotes:
        for tag in q['tags']:
            if tag not in ['scripture', 'bible']:
                themes[tag] = themes.get(tag, 0) + 1
    
    print(f"\nTheme distribution:")
    for theme, count in sorted(themes.items(), key=lambda x: x[1], reverse=True):
        print(f"  - {theme}: {count} verses")
    
    # Check new themes specifically
    new_themes = ['spiritual_warfare', 'work_inspired', 'body_temple']
    print(f"\nNew spiritual themes:")
    for theme in new_themes:
        count = themes.get(theme, 0)
        print(f"  - {theme}: {count} verses")
    
    # Sample verses from new themes
    print(f"\nSample verses from new themes:")
    for theme in new_themes:
        theme_verses = [q for q in scripture_quotes if theme in q['tags']]
        if theme_verses:
            print(f"\n{theme.upper().replace('_', ' ')}:")
            for i, q in enumerate(theme_verses[:3]):
                print(f"  {i+1}. {q['work']}: {q['text'][:80]}...")
            if len(theme_verses) > 3:
                print(f"  ... and {len(theme_verses) - 3} more")

if __name__ == "__main__":
    check_theme_distribution()

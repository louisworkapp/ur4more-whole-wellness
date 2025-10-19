#!/usr/bin/env python3
import json

# Load quotes
with open('assets/quotes/quotes.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

quotes = data['quotes']
scripture_quotes = [q for q in quotes if q.get('scripture_kjv', {}).get('enabled', False)]

print('Sample scripture quotes:')
for i, q in enumerate(scripture_quotes[:5]):
    print(f'{i+1}. {q["work"]}: {q["text"][:80]}...')

print(f'\nTotal scripture quotes: {len(scripture_quotes)}')
print(f'Total quotes: {len(quotes)}')

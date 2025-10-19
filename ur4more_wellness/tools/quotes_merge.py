#!/usr/bin/env python3
"""
Quote Merger for UR4MORE Wellness App
Merges multiple quote batch files into a master quotes file
"""

import json
import sys
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime

def load_quotes_file(filepath: str) -> List[Dict[str, Any]]:
    """Load quotes from a JSON file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data.get('quotes', [])
    except Exception as e:
        print(f"Error loading {filepath}: {e}")
        return []

def deduplicate_quotes(quotes: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Remove duplicate quotes based on text content"""
    seen_texts = set()
    unique_quotes = []
    
    for quote in quotes:
        text = quote.get('text', '').strip().lower()
        if text and text not in seen_texts:
            seen_texts.add(text)
            unique_quotes.append(quote)
    
    return unique_quotes

def merge_quotes(batch_files: List[str], output_file: str):
    """Merge multiple quote batch files into a master file"""
    all_quotes = []
    
    print(f"Merging {len(batch_files)} batch files...")
    
    for filepath in batch_files:
        quotes = load_quotes_file(filepath)
        all_quotes.extend(quotes)
        print(f"  Loaded {len(quotes)} quotes from {filepath}")
    
    print(f"Total quotes before deduplication: {len(all_quotes)}")
    
    # Remove duplicates
    unique_quotes = deduplicate_quotes(all_quotes)
    print(f"Total quotes after deduplication: {len(unique_quotes)}")
    
    # Create master file
    master_data = {
        "version": 1,
        "metadata": {
            "total_quotes": len(unique_quotes),
            "created": str(datetime.now()),
            "source_files": batch_files
        },
        "quotes": unique_quotes
    }
    
    # Ensure output directory exists
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    
    # Save master file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(master_data, f, indent=2, ensure_ascii=False)
    
    print(f"Master quotes file created: {output_file}")
    print(f"Final quote count: {len(unique_quotes)}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python quotes_merge.py <output_file> <batch_file1> [batch_file2] ...")
        print("Example: python quotes_merge.py assets/quotes/quotes.json assets/quotes/batches/*.json")
        sys.exit(1)
    
    output_file = sys.argv[1]
    batch_files = sys.argv[2:]
    
    merge_quotes(batch_files, output_file)

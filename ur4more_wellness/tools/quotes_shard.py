#!/usr/bin/env python3
"""
Quote Sharder for UR4MORE Wellness App
Splits master quotes file into smaller shards for efficient loading
"""

import json
import sys
import math
import os
from pathlib import Path
from datetime import datetime

def shard_quotes(master_path: str, output_dir: str, shard_size: int = 1000):
    """Split master quotes file into smaller shards"""
    
    # Load master file
    with open(master_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    quotes = data.get('quotes', [])
    total_quotes = len(quotes)
    
    if total_quotes == 0:
        print("No quotes found in master file")
        return
    
    # Calculate number of shards needed
    num_shards = math.ceil(total_quotes / shard_size)
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Create shard files
    shard_files = []
    for i in range(num_shards):
        start_idx = i * shard_size
        end_idx = min((i + 1) * shard_size, total_quotes)
        
        shard_quotes = quotes[start_idx:end_idx]
        
        shard_data = {
            "version": data.get("version", 1),
            "metadata": {
                "shard_index": i,
                "total_shards": num_shards,
                "quote_count": len(shard_quotes),
                "created": str(datetime.now())
            },
            "quotes": shard_quotes
        }
        
        shard_filename = f"quotes_{i:03d}.json"
        shard_path = Path(output_dir) / shard_filename
        shard_files.append(f"assets/quotes/shards/{shard_filename}")
        
        with open(shard_path, 'w', encoding='utf-8') as f:
            json.dump(shard_data, f, indent=2, ensure_ascii=False)
        
        print(f"Created shard {i+1}/{num_shards}: {shard_filename} ({len(shard_quotes)} quotes)")
    
    # Update manifest file
    manifest_path = "assets/quotes/manifest.json"
    manifest_data = {
        "version": 1,
        "shard_count": num_shards,
        "files": shard_files,
        "last_updated": str(datetime.now())
    }
    
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest_data, f, indent=2, ensure_ascii=False)
    
    print(f"\nSharding complete!")
    print(f"Total quotes: {total_quotes}")
    print(f"Number of shards: {num_shards}")
    print(f"Quotes per shard: ~{shard_size}")
    print(f"Manifest updated: {manifest_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python quotes_shard.py <master_file> <output_dir> [shard_size]")
        print("Example: python quotes_shard.py assets/quotes/quotes.json assets/quotes/shards 1000")
        sys.exit(1)
    
    master_file = sys.argv[1]
    output_dir = sys.argv[2]
    shard_size = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
    
    shard_quotes(master_file, output_dir, shard_size)

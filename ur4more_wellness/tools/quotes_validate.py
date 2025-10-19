#!/usr/bin/env python3
"""
Quote Validator for UR4MORE Wellness App
Validates quote files against the required schema
"""

import json
import sys
from pathlib import Path

def validate_quote(quote: dict) -> list:
    """Validate a single quote against the schema"""
    errors = []
    
    # Required fields
    required_fields = [
        'id', 'text', 'author', 'work', 'year_approx', 'source',
        'public_domain', 'license', 'tags', 'axis', 'modes',
        'scripture_kjv', 'attribution', 'checksum'
    ]
    
    for field in required_fields:
        if field not in quote:
            errors.append(f"Missing required field: {field}")
    
    # Validate text length
    if 'text' in quote and len(quote['text']) > 240:
        errors.append(f"Text too long: {len(quote['text'])} characters (max 240)")
    
    # Validate modes structure
    if 'modes' in quote:
        modes = quote['modes']
        if not isinstance(modes, dict):
            errors.append("modes must be a dictionary")
        else:
            if 'off_safe' not in modes or 'faith_ok' not in modes:
                errors.append("modes must contain 'off_safe' and 'faith_ok' fields")
    
    # Validate scripture structure
    if 'scripture_kjv' in quote:
        scripture = quote['scripture_kjv']
        if not isinstance(scripture, dict):
            errors.append("scripture_kjv must be a dictionary")
        else:
            if 'enabled' not in scripture:
                errors.append("scripture_kjv must contain 'enabled' field")
            elif scripture.get('enabled') and len(scripture.get('text', '')) > 200:
                errors.append("Scripture text too long (max 200 characters)")
    
    # Validate public domain flag
    if 'public_domain' in quote and not quote['public_domain']:
        errors.append("All quotes must be public domain")
    
    # Validate year
    if 'year_approx' in quote:
        year = quote['year_approx']
        if not isinstance(year, int) or year < 1000 or year > 2024:
            errors.append(f"Invalid year: {year}")
    
    return errors

def validate_quotes_file(filepath: str) -> bool:
    """Validate a quotes file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'quotes' not in data:
            print(f"❌ {filepath}: Missing 'quotes' field")
            return False
        
        quotes = data['quotes']
        if not isinstance(quotes, list):
            print(f"❌ {filepath}: 'quotes' must be a list")
            return False
        
        total_errors = 0
        for i, quote in enumerate(quotes):
            errors = validate_quote(quote)
            if errors:
                print(f"❌ {filepath}: Quote {i+1} ({quote.get('id', 'unknown')}):")
                for error in errors:
                    print(f"   - {error}")
                total_errors += len(errors)
        
        if total_errors == 0:
            print(f"✅ {filepath}: {len(quotes)} quotes validated successfully")
            return True
        else:
            print(f"❌ {filepath}: {total_errors} validation errors found")
            return False
            
    except json.JSONDecodeError as e:
        print(f"❌ {filepath}: JSON decode error - {e}")
        return False
    except Exception as e:
        print(f"❌ {filepath}: Error - {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python quotes_validate.py <file1> [file2] ...")
        print("Example: python quotes_validate.py assets/quotes/batches/*.json")
        sys.exit(1)
    
    files = sys.argv[1:]
    all_valid = True
    
    for filepath in files:
        if not validate_quotes_file(filepath):
            all_valid = False
    
    if all_valid:
        print("\n🎉 All files validated successfully!")
        sys.exit(0)
    else:
        print("\n❌ Some files failed validation")
        sys.exit(1)

#!/usr/bin/env python3
"""
UR4MORE Wellness - Quote Library Builder
Complete script to build and manage the quote library
"""

import os
import sys
import subprocess
from pathlib import Path

def run_command(cmd, description):
    """Run a command and handle errors"""
    print(f"\n🔄 {description}...")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed")
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed: {e}")
        if e.stderr:
            print(f"Error: {e.stderr}")
        return False

def build_quote_library():
    """Build the complete quote library"""
    print("🚀 Building UR4MORE Quote Library")
    print("=" * 50)
    
    # Step 1: Generate quote batches
    print("\n📝 Step 1: Generating Quote Batches")
    
    batches = [
        ("truth_001", "truth", 250),
        ("responsibility_001", "responsibility", 250),
        ("courage_001", "courage", 250),
        ("humility_001", "humility", 250),
        ("service_001", "service", 250),
        ("hope_001", "hope", 250),
        ("repentance_001", "repentance", 250),
        ("wisdom_001", "wisdom", 250),
        ("meaning_001", "meaning", 250),
        ("perseverance_001", "perseverance", 250),
    ]
    
    batch_files = []
    for batch_name, theme, count in batches:
        cmd = f"python tools/quotes_batch_generator.py {batch_name} {theme} {count}"
        if run_command(cmd, f"Generating {theme} batch ({count} quotes)"):
            batch_files.append(f"assets/quotes/batches/2025-01_{theme}_{batch_name}.json")
    
    if not batch_files:
        print("❌ No batches were generated successfully")
        return False
    
    # Step 2: Validate all batches
    print("\n🔍 Step 2: Validating Quote Batches")
    batch_files_str = " ".join(batch_files)
    if not run_command(f"python tools/quotes_validate.py {batch_files_str}", "Validating all batches"):
        print("❌ Validation failed - stopping build")
        return False
    
    # Step 3: Merge batches into master file
    print("\n🔗 Step 3: Merging Batches")
    merge_cmd = f"python tools/quotes_merge.py assets/quotes/quotes.json {batch_files_str}"
    if not run_command(merge_cmd, "Merging batches into master file"):
        return False
    
    # Step 4: Create shards
    print("\n📦 Step 4: Creating Shards")
    if not run_command("python tools/quotes_shard.py assets/quotes/quotes.json assets/quotes/shards 1000", "Creating quote shards"):
        return False
    
    # Step 5: Final validation
    print("\n✅ Step 5: Final Validation")
    if not run_command("python tools/quotes_validate.py assets/quotes/quotes.json", "Validating master file"):
        return False
    
    # Step 6: Update pubspec.yaml
    print("\n📋 Step 6: Updating pubspec.yaml")
    update_pubspec()
    
    print("\n🎉 Quote Library Build Complete!")
    print("=" * 50)
    print(f"📊 Generated {len(batch_files)} batches")
    print("📁 Master file: assets/quotes/quotes.json")
    print("📦 Shards created in: assets/quotes/shards/")
    print("📋 Manifest updated: assets/quotes/manifest.json")
    print("\n🚀 Ready to commit and push!")
    
    return True

def update_pubspec():
    """Update pubspec.yaml with new shard files"""
    pubspec_path = "pubspec.yaml"
    
    if not Path(pubspec_path).exists():
        print("❌ pubspec.yaml not found")
        return
    
    # Read current pubspec
    with open(pubspec_path, 'r') as f:
        content = f.read()
    
    # Find shard files
    shard_dir = Path("assets/quotes/shards")
    if shard_dir.exists():
        shard_files = [f"    - {f}" for f in sorted(shard_dir.glob("quotes_*.json"))]
        
        # Replace the quotes section
        start_marker = "    - assets/quotes/manifest.json"
        end_marker = "    - assets/quotes/shards/quotes_000.json"
        
        if start_marker in content and end_marker in content:
            start_idx = content.find(start_marker)
            end_idx = content.find(end_marker) + len(end_marker)
            
            new_quotes_section = f"    - assets/quotes/manifest.json\n" + "\n".join(shard_files)
            content = content[:start_idx] + new_quotes_section + content[end_idx:]
            
            with open(pubspec_path, 'w') as f:
                f.write(content)
            
            print(f"✅ Updated pubspec.yaml with {len(shard_files)} shard files")
        else:
            print("⚠️  Could not find quotes section in pubspec.yaml")

def quick_build():
    """Quick build with existing tools"""
    print("⚡ Quick Build - Using existing infrastructure")
    
    # Just validate and shard existing files
    if run_command("python tools/quotes_validate.py assets/quotes/shards/quotes_000.json", "Validating existing shard"):
        print("✅ Existing quote system is valid")
        return True
    return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "quick":
        success = quick_build()
    else:
        success = build_quote_library()
    
    sys.exit(0 if success else 1)

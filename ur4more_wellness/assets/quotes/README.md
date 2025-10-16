# UR4MORE Quotes Library

## Overview

This directory contains two curated quote libraries that ship with the UR4MORE Wellness app:

- **`quotes_faith_seed.json`** - Faith-explicit original quotes (~600 items)
- **`quotes_secular_seed.json`** - Secular-subtle original quotes (~400 items)

## Content Origin

All quotes in these libraries are **UR4MORE Originals** © UR4MORE. They were generated using internal writing tools and carefully curated for tone, safety, and alignment with our wellness mission. No external copyrighted quotes are included.

## Library Descriptions

### Faith-Explicit Library
Contains quotes that explicitly reference Christian faith concepts, including:
- Prayer and spiritual practices
- Grace, mercy, and divine love
- Biblical themes and concepts
- Christ-centered identity and purpose
- Spiritual surrender and victory

### Secular-Subtle Library
Contains quotes that express timeless virtues and wisdom in neutral language:
- Universal human values and principles
- Personal growth and self-acceptance
- Inner strength and resilience
- Compassion and service
- Hope and purpose

The secular library intentionally expresses biblically resonant themes without overt religious terminology, making them accessible to users of all faith backgrounds.

## Schema

Both libraries follow the same JSON schema:

```json
[
  {
    "id": "ur4-faith-0001",
    "text": "Short encouragement…",
    "author": "UR4MORE",
    "source": "UR4MORE Originals",
    "tags": ["identity", "gratitude", "service"],
    "tierMin": "light",
    "lang": "en",
    "length": 52,
    "weight": 0.9,
    "origin": "seed",
    "category": "faith"
  }
]
```

### Field Descriptions

- **`id`**: Unique identifier with format `ur4-{category}-{number}`
- **`text`**: The quote text (≤140 characters, no trailing spaces)
- **`author`**: Always "UR4MORE"
- **`source`**: Always "UR4MORE Originals"
- **`tags`**: 2-3 thematic tags from predefined set
- **`tierMin`**: Minimum faith mode tier (`off`, `light`, `disciple`, `kingdom`)
- **`lang`**: Language code (currently "en")
- **`length`**: Character count of the text
- **`weight`**: Surfacing weight (0.7-1.0)
- **`origin`**: Content origin (currently "seed")
- **`category`**: Library category (`faith` or `secular`)

## Distribution

### Tier Distribution
- **Off**: 20% - Accessible to all users
- **Light**: 40% - Minimal spiritual content
- **Disciple**: 30% - Active faith integration
- **Kingdom**: 10% - Advanced spiritual features

### Length Distribution
- 60% of quotes are 60-110 characters
- All quotes are ≤140 characters
- No trailing spaces or punctuation issues

### Tag Coverage
Quotes are tagged across these themes:
- identity, surrender, peace, courage, humility, service
- compassion, hope, wisdom, discipline, gratitude, patience
- forgiveness, resilience, purpose, prayer, rest, perseverance
- justice, mercy, love, grace, faith, trust, strength
- healing, freedom, joy, contentment, generosity, kindness

## Key Themes

### "Die to Self" (Surrender of Ego)
Expressed in modern, invitational language:
- **Faith**: "Let the small self step back so love can lead"
- **Secular**: "Let the ego loosen its grip so love can do the guiding"

### "Fight from Victory" (Identity-Anchored Confidence)
Framed as living from established worth:
- **Faith**: "You don't fight for worth—you live from it"
- **Secular**: "Move from settled worth, not toward it"

## Safety & Guidelines

### Brand Safety
All quotes are filtered against our brand safety rules. The following terms are excluded:
- yoga, chakra, mantra, tarot, astrology, namaste

### Tone & Approach
- Warm, non-judgmental, and invitational
- Avoid "should/shouldn't" language
- Prefer "can/consider/try" phrasing
- No medical or clinical claims
- No political content
- Crisis support always available regardless of faith mode

## Integration Notes

### Faith Mode Integration
- **Off Mode**: Only secular-subtle quotes shown
- **Light Mode**: Mostly secular-subtle with occasional faith quotes (user toggle)
- **Disciple/Kingdom Mode**: Faith-explicit quotes by default with "show neutral alternative" option

### Usage in Daily Check-in
Quotes may appear in Daily Check-in steps 3-5 as **QuoteStrip** components, providing contextual encouragement based on the user's faith mode and current state.

## Generation

These libraries were generated using `tools/generate_quotes.dart` with:
- Curated phrase banks for both faith and secular content
- Template-based composition for variety
- Strict duplicate detection (trigram similarity ≥0.8)
- Brand safety filtering
- Tier distribution enforcement
- Validation against schema requirements

The generator is deterministic with a fixed seed (42) for reproducible results.

## Maintenance

To regenerate the libraries:
1. Run `dart tools/generate_quotes.dart`
2. Review the generated content
3. Validate against requirements
4. Commit the updated JSON files

The generator includes comprehensive validation to ensure:
- Minimum quote counts (faith ≥580, secular ≥380)
- Proper length constraints (1-140 characters)
- Brand safety compliance
- Schema validation
- Tier distribution accuracy

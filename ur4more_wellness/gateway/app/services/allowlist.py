# Single source of truth for external providers (disabled by default).
ALLOWLISTED_PROVIDERS = {
    # Free quote APIs for 365-day content rotation
    "quotable": {
        "base_url": "https://api.quotable.io",
        "license": "public_domain", 
        "enabled": True,
        "endpoints": {
            "random": "/random",
            "search": "/search/quotes"
        }
    },
    "zenquotes": {
        "base_url": "https://zenquotes.io/api",
        "license": "public_domain",
        "enabled": True, 
        "endpoints": {
            "today": "/today",
            "random": "/random"
        }
    },
    "quotegarden": {
        "base_url": "https://quotegarden.herokuapp.com/api/v3",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "random": "/quotes/random",
            "search": "/quotes"
        }
    },
    
    # External Bible/Scripture APIs for 365-day content rotation
    "scripture_api": {
        "base_url": "https://scriptureapi.com",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "random": "/api/random",
            "verse": "/api/verse",
            "passage": "/api/passage"
        }
    },
    "bible_api_wldeh": {
        "base_url": "https://bible-api.com",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "verse": "/john+3:16",
            "chapter": "/john+3",
            "random": "/random"
        }
    },
    "labs_bible": {
        "base_url": "https://labs.bible.org/api",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "random": "/?passage=random&formatting=plain",
            "daily": "/?passage=votd&formatting=plain",
            "verse": "/?passage=john+3:16&formatting=plain"
        }
    },
    "bible_gateway_votd": {
        "base_url": "https://www.biblegateway.com",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "verse_of_day": "/votd/get/?format=json&version=KJV"
        }
    },
    
    # Prayer and Devotional APIs
    "prayer_api": {
        "base_url": "https://prayerapi.com",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "daily_prayer": "/api/daily",
            "prayer_topics": "/api/topics"
        }
    },
    "devotional_api": {
        "base_url": "https://devotionalapi.com",
        "license": "public_domain",
        "enabled": True,
        "endpoints": {
            "daily": "/api/daily",
            "themes": "/api/themes"
        }
    }
}

from datetime import datetime, timezone
from app.providers.quotes_local import PD as LOCAL_QUOTES
from app.providers.scripture_kjv_local import KJV_DB
from app.services.allowlist import ALLOWLISTED_PROVIDERS

def build_manifest():
    themes = {k: {"passageCount": len(v)} for k, v in KJV_DB.items()}
    total_passages = sum(len(v) for v in KJV_DB.values())
    return {
        "schemaVersion": 1,
        "quotes": {
            "localCount": len(LOCAL_QUOTES),
            "externalProviders": {k: v["enabled"] for k, v in ALLOWLISTED_PROVIDERS.items()}
        },
        "scripture": {
            "themeCount": len(KJV_DB),
            "totalPassages": total_passages,
            "themes": themes
        },
        "updatedAt": datetime.now(timezone.utc).isoformat()
    }

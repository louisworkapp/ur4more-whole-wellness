from app.models import FaithMode

def faith_allowed(mode: FaithMode, lightConsent: bool, hideInMind: bool) -> bool:
    if hideInMind: return False
    if mode == "off": return False
    if mode == "light": return bool(lightConsent)
    return True

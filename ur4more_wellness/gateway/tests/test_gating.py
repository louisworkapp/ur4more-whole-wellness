from app.services.gating import faith_allowed

def test_off_blocked():
  assert faith_allowed("off", False, False) is False

def test_light_needs_consent():
  assert faith_allowed("light", False, False) is False
  assert faith_allowed("light", True, False) is True

def test_hide_blocks_all():
  assert faith_allowed("disciple", True, True) is False

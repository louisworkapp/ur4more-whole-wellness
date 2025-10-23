from app.models import ScripturePassage, Verse
from typing import List

KJV_DB: dict[str, List[ScripturePassage]] = {
  "gluttony": [ScripturePassage(
    ref="1 Corinthians 9:24–27 (KJV)",
    verses=[
      Verse(v=24, t="Know ye not that they which run in a race run all, but one receiveth the prize? So run, that ye may obtain."),
      Verse(v=25, t="And every man that striveth for the mastery is temperate in all things. Now they do it to obtain a corruptible crown; but we an incorruptible."),
      Verse(v=26, t="I therefore so run, not as uncertainly; so fight I, not as one that beateth the air:"),
      Verse(v=27, t="But I keep under my body, and bring it into subjection: lest that by any means, when I have preached to others, I myself should be a castaway.")
    ],
    actNow="Plate plan → pray → eat with temperance; log one small victory."
  )],
  # TODO: add: pride, envy, lust, greed, anger, sloth, feeling_lost with full passages
}

async def fetch_scripture_local(theme: str, limit: int) -> List[ScripturePassage]:
    seq = KJV_DB.get(theme.lower().strip(), [])
    return seq[:max(1, limit)]

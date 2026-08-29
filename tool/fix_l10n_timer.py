"""Fix createQuizTimerOn / createQuizTimerPreview strings in generated l10n dart files."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib" / "l10n"

TIMER_ON = (
    "  String createQuizTimerOn(int seconds, int count, int total) => "
    "'${total}s for the whole quiz (${seconds}s × ${count} questions)';"
)
TIMER_PREVIEW = (
    "  String createQuizTimerPreview(int seconds) => '${seconds}s total quiz timer';"
)

import re

for path in sorted(ROOT.glob("app_localizations_*.dart")):
    text = path.read_text(encoding="utf-8", errors="replace")
    text2, n1 = re.subn(
        r"  String createQuizTimerOn\(int seconds, int count, int total\) => [^;]+;",
        TIMER_ON,
        text,
        count=1,
    )
    text2, n2 = re.subn(
        r"  String createQuizTimerPreview\(int seconds\) => [^;]+;",
        TIMER_PREVIEW,
        text2,
        count=1,
    )
    if n1 or n2:
        path.write_text(text2, encoding="utf-8")
        print(f"{path.name}: timerOn={n1} preview={n2}")
    else:
        print(f"{path.name}: no match")

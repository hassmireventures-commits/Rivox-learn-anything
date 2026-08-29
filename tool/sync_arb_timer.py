"""Sync createQuizTimerOn / preview / generation strings across ARB locales."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1] / "lib" / "l10n"

TIMER_ON = "{total}s for the whole quiz ({seconds}s × {count} questions)"
TIMER_ON_META = {
    "placeholders": {
        "seconds": {"type": "int"},
        "count": {"type": "int"},
        "total": {"type": "int"},
    }
}
TIMER_PREVIEW = "{seconds}s total quiz timer"
EXTRA = {
    "pathGenerationTimeout": "Learning path generation timed out. Check your connection and try again.",
    "generationJobInProgress": "Another generation is already in progress.",
    "generationRunningInBackground": "Generation continues in the background. We'll notify you when it's ready.",
}

for path in sorted(ROOT.glob("app_*.arb")):
    if path.name == "app_en.arb":
        continue
    text = path.read_text(encoding="utf-8")
    # Prefer regex replace for createQuizTimerOn value + metadata block
    text2, n = re.subn(
        r'"createQuizTimerOn"\s*:\s*"[^"]*"\s*,\s*"@createQuizTimerOn"\s*:\s*\{[^}]*\{[^}]*\}[^}]*\}',
        f'"createQuizTimerOn": "{TIMER_ON}",\n  "@createQuizTimerOn": {json.dumps(TIMER_ON_META)}',
        text,
        count=1,
        flags=re.DOTALL,
    )
    if n == 0:
        text2, n = re.subn(
            r'"createQuizTimerOn"\s*:\s*"[^"]*"',
            f'"createQuizTimerOn": "{TIMER_ON}"',
            text,
            count=1,
        )
        # Expand @createQuizTimerOn placeholders if only seconds
        text2 = re.sub(
            r'"@createQuizTimerOn"\s*:\s*\{\s*"placeholders"\s*:\s*\{\s*"seconds"\s*:\s*\{\s*"type"\s*:\s*"int"\s*\}\s*\}\s*\}',
            f'"@createQuizTimerOn": {json.dumps(TIMER_ON_META)}',
            text2,
            count=1,
        )
    text2 = re.sub(
        r'"createQuizTimerPreview"\s*:\s*"[^"]*"',
        f'"createQuizTimerPreview": "{TIMER_PREVIEW}"',
        text2,
        count=1,
    )
    # Insert extras before createQuizGenerateButton if missing
    for key, val in EXTRA.items():
        if f'"{key}"' not in text2:
            text2 = text2.replace(
                '"createQuizGenerateButton"',
                f'"{key}": "{val}",\n  "createQuizGenerateButton"',
                1,
            )
    path.write_text(text2, encoding="utf-8")
    print(f"updated {path.name}")

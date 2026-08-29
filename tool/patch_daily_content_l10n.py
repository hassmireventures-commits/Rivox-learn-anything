#!/usr/bin/env python3
"""Add daily content detail l10n keys to all ARBs (English fallback)."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "lib" / "l10n"

VALS = {
    "dailyContentDetailTitle": "Today's learning pick",
    "dailyContentCardSubtitle": "Open today's validated article or video",
    "dailyContentTypeArticle": "Article",
    "dailyContentTypeVideo": "Video",
    "dailyContentOpenArticle": "Read in app",
    "dailyContentOpenExternally": "Open externally",
    "dailyContentEmpty": "No learning pick yet. Generate one when AI is online.",
    "dailyContentGenerating": "Finding a learning resource...",
    "dailyContentGenerate": "Generate today's pick",
}


def main() -> None:
    for path in sorted(ROOT.glob("app_*.arb")):
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        changed = False
        for key, value in VALS.items():
            if key not in data:
                data[key] = value
                changed = True
        if changed:
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            print(f"patched {path.name}")
        else:
            print(f"ok {path.name}")


if __name__ == "__main__":
    main()

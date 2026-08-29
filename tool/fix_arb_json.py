from pathlib import Path
import re

root = Path(__file__).resolve().parents[1] / "lib" / "l10n"
pat = re.compile(
    r'"@createQuizTimerOn": \{"placeholders": \{"seconds": \{"type": "int"\}, '
    r'"count": \{"type": "int"\}, "total": \{"type": "int"\}\}\}\s*\n\s*\},'
)
repl = (
    '"@createQuizTimerOn": {"placeholders": {"seconds": {"type": "int"}, '
    '"count": {"type": "int"}, "total": {"type": "int"}}},'
)

for path in sorted(root.glob("app_*.arb")):
    if path.name == "app_en.arb":
        continue
    text = path.read_text(encoding="utf-8")
    text2, n = pat.subn(repl, text, count=1)
    if n:
        path.write_text(text2, encoding="utf-8")
        print(f"fixed {path.name}")
    else:
        print(f"no change {path.name}")

"""Append guidance l10n getters from en to all other locale files."""
from pathlib import Path

L10N_DIR = Path(__file__).resolve().parent.parent / "lib" / "l10n"
EN_FILE = L10N_DIR / "app_localizations_en.dart"
MARKER = "  String providerGuideTitle(String provider)"

def extract_block(text: str) -> str:
    start = text.find(MARKER)
    if start == -1:
        raise SystemExit(f"Marker not found in {EN_FILE}")
    end = text.rfind("}")
    block = text[start:end].rstrip()
    if not block.endswith(";"):
        block += ";"
    return block + "\n"

def main() -> None:
    en_text = EN_FILE.read_text(encoding="utf-8")
    block = extract_block(en_text)

    for path in sorted(L10N_DIR.glob("app_localizations_*.dart")):
        if path.name == "app_localizations_en.dart":
            continue
        text = path.read_text(encoding="utf-8")
        if MARKER in text:
            print(f"skip {path.name} (already patched)")
            continue
        if not text.rstrip().endswith("}"):
            raise SystemExit(f"Unexpected end in {path.name}")
        text = text.rstrip()[:-1] + block + "}\n"
        path.write_text(text, encoding="utf-8")
        print(f"patched {path.name}")

if __name__ == "__main__":
    main()

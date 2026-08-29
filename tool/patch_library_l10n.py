"""Append library/AI l10n getters from en to all other locale files."""
from pathlib import Path

L10N_DIR = Path(__file__).resolve().parent.parent / "lib" / "l10n"
EN_FILE = L10N_DIR / "app_localizations_en.dart"
MARKER = "  String get libraryTitle"
CITATION_MARKER = "  String get resultsGroundedInLibrary"


def extract_block(text: str, marker: str) -> str:
    start = text.find(marker)
    if start == -1:
        raise SystemExit(f"Marker not found in {EN_FILE}: {marker!r}")
    end = text.rfind("}")
    block = text[start:end].rstrip()
    if not block.endswith(";"):
        block += ";"
    return block + "\n"


def main() -> None:
    en_text = EN_FILE.read_text(encoding="utf-8")
    block = extract_block(en_text, MARKER)
    citation_block = ""
    if CITATION_MARKER in en_text:
        citation_block = extract_block(en_text, CITATION_MARKER)

    for path in sorted(L10N_DIR.glob("app_localizations_*.dart")):
        if path.name == "app_localizations_en.dart":
            continue
        text = path.read_text(encoding="utf-8")
        if MARKER not in text:
            text = text.rstrip()[:-1] + block + "}\n"
            path.write_text(text, encoding="utf-8")
            print(f"patched library block in {path.name}")
        elif CITATION_MARKER not in text and citation_block:
            text = text.rstrip()[:-1] + citation_block + "}\n"
            path.write_text(text, encoding="utf-8")
            print(f"patched citation block in {path.name}")
        else:
            print(f"skip {path.name}")


if __name__ == "__main__":
    main()

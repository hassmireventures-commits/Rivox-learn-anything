"""Patch l10n for short segment labels + restore EN em dashes from ARB."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib" / "l10n"

NEW_BLOCK = """
  @override
  String pathDepthLessons(int count) => '${count} lessons';

  @override
  String get goalModeShortLearning => 'Learning';

  @override
  String get goalModeShortExam => 'Exam';

  @override
  String get goalModeShortCareer => 'Career';
"""

PATH_REPLACEMENTS = {
    r"String get pathDepthLight => '[^']*';": "String get pathDepthLight => 'Light';",
    r"String get pathDepthStandard => '[^']*';": "String get pathDepthStandard => 'Standard';",
    r"String get pathDepthDeep => '[^']*';": "String get pathDepthDeep => 'Deep';",
}


def patch_locale_dart(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    for pat, repl in PATH_REPLACEMENTS.items():
        text, _ = re.subn(pat, repl, text, count=1)
    if "pathDepthLessons" not in text:
        # Insert after pathDepthDeep getter
        text, n = re.subn(
            r"(String get pathDepthDeep => '[^']*';)",
            r"\1" + NEW_BLOCK,
            text,
            count=1,
        )
        if n != 1:
            print(f"WARN: could not insert new keys in {path.name}")
    path.write_text(text, encoding="utf-8")
    print(f"patched {path.name}")


def restore_en_dashes() -> None:
    arb = json.loads((ROOT / "app_en.arb").read_text(encoding="utf-8-sig"))
    en_path = ROOT / "app_localizations_en.dart"
    text = en_path.read_text(encoding="utf-8")

    # For each ARB string containing an em dash, rewrite the matching Dart getter body.
    for key, value in arb.items():
        if key.startswith("@") or not isinstance(value, str):
            continue
        if "—" not in value and "…" not in value and "\u2019" not in value:
            continue
        # Skip parameterized for simplicity unless no complex placeholders nesting
        meta = arb.get(f"@{key}")
        if meta and "placeholders" in meta:
            # Build dart template
            dart_val = value
            for pname in meta["placeholders"]:
                dart_val = dart_val.replace("{" + pname + "}", "${" + pname + "}")
            escaped = dart_val.replace("\\", "\\\\").replace("'", "\\'")
            params = ", ".join(
                f"{'int' if info.get('type') == 'int' else 'String'} {pname}"
                for pname, info in meta["placeholders"].items()
            )
            pat = rf"String {key}\([^)]*\) => '[^']*';"
            repl = f"String {key}({params}) => '{escaped}';"
            text2, n = re.subn(pat, repl, text, count=1)
            if n:
                text = text2
                print(f"  fixed method {key}")
            continue

        escaped = value.replace("\\", "\\\\").replace("'", "\\'")
        pat = rf"String get {key} => '[^']*';"
        repl = f"String get {key} => '{escaped}';"
        text2, n = re.subn(pat, repl, text, count=1)
        if n:
            text = text2
            print(f"  fixed getter {key}")
        else:
            print(f"  miss {key}")

    en_path.write_text(text, encoding="utf-8")
    print("restored EN unicode punctuation from ARB")


def main() -> None:
    for path in sorted(ROOT.glob("app_localizations_*.dart")):
        patch_locale_dart(path)
    restore_en_dashes()


if __name__ == "__main__":
    main()

from pathlib import Path
import re

root = Path(__file__).resolve().parents[1] / "lib" / "l10n"

abs_block = """
  String get aiStudyPulseTitle;
  String get aiStudyPulseLoading;
  String get aiStudyPulseTapRetry;
"""

impl_block = """
  @override
  String get aiStudyPulseTitle => 'Today\\'s AI brief';

  @override
  String get aiStudyPulseLoading => 'Checking your AI connection…';

  @override
  String get aiStudyPulseTapRetry => 'Tap to refresh';
"""

abs_path = root / "app_localizations.dart"
abs_t = abs_path.read_text(encoding="utf-8")
if "aiStudyPulseTitle" not in abs_t:
    abs_t = abs_t.replace(
        "  String get aiStatusOffline;",
        "  String get aiStatusOffline;" + abs_block,
        1,
    )
    abs_path.write_text(abs_t, encoding="utf-8")
    print("abstract ok")

for path in sorted(root.glob("app_localizations_*.dart")):
    text = path.read_text(encoding="utf-8")
    if "aiStudyPulseTitle" in text:
        print("skip", path.name)
        continue
    text2, n = re.subn(
        r"(String get aiStatusOffline => '[^']*';)",
        r"\1" + impl_block,
        text,
        count=1,
    )
    if n:
        path.write_text(text2, encoding="utf-8")
        print("ok", path.name)
    else:
        print("fail", path.name)

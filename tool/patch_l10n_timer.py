from pathlib import Path
import re

root = Path(r"C:\dev\learn-anything\lib\l10n")
extra = """
  @override
  String get pathGenerationTimeout =>
      'Learning path generation timed out. Check your connection and try again.';

  @override
  String get generationJobInProgress => 'Another generation is already in progress.';

  @override
  String get generationRunningInBackground =>
      'Generation continues in the background. We\\'ll notify you when it\\'s ready.';
"""

for p in root.glob("app_localizations_*.dart"):
    text = p.read_text(encoding="utf-8", errors="replace")
    orig = text
    text = re.sub(
        r"String createQuizTimerOn\(int seconds\) => [^;]+;",
        "String createQuizTimerOn(int seconds, int count, int total) => "
        "'${total}s for the whole quiz (${seconds}s × ${count} questions)';",
        text,
    )
    text = text.replace(
        "String createQuizTimerPreview(int seconds) => '${seconds} s timer';",
        "String createQuizTimerPreview(int seconds) => '${seconds}s total quiz timer';",
    )
    if "pathGenerationTimeout" not in text:
        needle = "@override\n  String get multiplayerUnavailableTitle"
        if needle in text:
            text = text.replace(needle, extra + "\n\n  @override\n  String get multiplayerUnavailableTitle")
        else:
            needle2 = "String get multiplayerUnavailableTitle"
            text = text.replace(needle2, extra + "\n\n  @override\n  String get multiplayerUnavailableTitle", 1)
    if text != orig:
        p.write_text(text, encoding="utf-8")
        print("ok", p.name)
    else:
        print("skip", p.name)
print("done")

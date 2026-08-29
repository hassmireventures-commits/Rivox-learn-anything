#!/usr/bin/env python3
"""One-shot ARB scrub: ASCII punctuation + support ad copy. Run then generate_l10n.py."""

from __future__ import annotations

from pathlib import Path

L10N = Path(__file__).resolve().parent.parent / "lib" / "l10n"


def scrub_en(text: str) -> str:
    em = "\u2014"
    ell = "\u2026"
    text = text.replace(
        f'"supportAdReady": "Rewarded ad ready {em} tap to watch"',
        '"supportAdReady": "Video ad ready - tap to watch"',
    )
    text = text.replace(
        '"supportAdReady": "Rewarded ad ready - tap to watch"',
        '"supportAdReady": "Video ad ready - tap to watch"',
    )
    text = text.replace(
        f'"supportAdUnavailable": "Ad loading{ell} tap again shortly"',
        '"supportAdUnavailable": "Ad loading... tap again shortly"',
    )
    text = text.replace(
        f'"supportLoadingAd": "Loading ad{ell}"',
        '"supportLoadingAd": "Loading ad..."',
    )
    text = text.replace(
        f'"settingsLoadingAd": "Loading ad{ell}"',
        '"settingsLoadingAd": "Loading ad..."',
    )
    text = text.replace("\u2014", " - ")
    text = text.replace("\u2013", "-")
    text = text.replace("\u2026", "...")
    if "languageFontDownloadSuccess" not in text:
        text = text.replace(
            '"languageFontDownloadFailed": "Could not download fonts. Check your connection and try again.",',
            '"languageFontDownloadFailed": "Could not download fonts. Check your connection and try again.",\n'
            '  "languageFontDownloadSuccess": "Fonts ready for this language.",\n'
            '  "languageFontDownloadProgress": "Downloading fonts...",',
        )
    return text


def scrub_other(text: str) -> str:
    text = text.replace("â€¦", "...")
    text = text.replace("Ã¢â‚¬Â¦", "...")
    text = text.replace("\u2026", "...")
    text = text.replace("\uFFFD", "-")
    text = text.replace("\u2014", " - ")
    text = text.replace(
        '"supportAdReady": "Optional rewarded ad"',
        '"supportAdReady": "Video ad ready - tap to watch"',
    )
    return text


def main() -> None:
    en_path = L10N / "app_en.arb"
    en = scrub_en(en_path.read_text(encoding="utf-8-sig"))
    en_path.write_text(en, encoding="utf-8", newline="\n")
    print(
        f"Wrote app_en.arb; ellipsis={en.count(chr(0x2026))} emdash={en.count(chr(0x2014))}"
    )

    for arb in sorted(L10N.glob("app_*.arb")):
        if arb.name == "app_en.arb":
            continue
        orig = arb.read_text(encoding="utf-8-sig")
        text = scrub_other(orig)
        if text != orig:
            arb.write_text(text, encoding="utf-8", newline="\n")
            print(f"Scrubbed {arb.name}")
        else:
            print(f"No change {arb.name}")


if __name__ == "__main__":
    main()

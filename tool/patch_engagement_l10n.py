#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

EN = Path(__file__).resolve().parent.parent / "lib" / "l10n" / "app_en.arb"

KEYS = {
    "supportRequestSponsoredTitle": "Request sponsored ads",
    "supportRequestSponsoredSubtitle": "Email us if you want to advertise with Learn Anything",
    "supportRequestSponsoredEmailSubject": "Sponsored ads request - Learn Anything",
    "supportRequestSponsoredEmailBody": (
        "Hi, I would like to discuss sponsored ads / partnerships for Learn Anything.\n\n"
        "Company:\nWebsite:\nMessage:\n"
    ),
    "settingsReminderPlaySound": "Play sound",
    "settingsReminderVibrate": "Vibrate",
    "historySegmentQuizzes": "Quizzes",
    "historySegmentNotifications": "Notifications",
    "historyNotificationsEmpty": (
        "No notifications yet. Study reminders and daily content will appear here."
    ),
    "dailyContentReadyTitle": "Today's learning pick",
    "dailyContentReadyBody": "A fresh article or video for your goals is ready.",
    "resultsAnswerReferences": "References",
}


def main() -> None:
    data = json.loads(EN.read_text(encoding="utf-8-sig"))
    data.update(KEYS)
    EN.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"Updated app_en.arb ({len(KEYS)} keys)")


if __name__ == "__main__":
    main()

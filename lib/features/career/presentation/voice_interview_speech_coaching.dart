/// English-only coaching copy for voice interview (Whisper en-US).
class VoiceInterviewSpeechCoaching {
  VoiceInterviewSpeechCoaching._();

  static const primaryTip =
      'Speak slowly, loudly, and clearly in English.';

  static const beforeRecord =
      'Tap Record, then answer in English. Speak slowly, loudly, and clearly.';

  static const whileRecording =
      'Listening… speak slowly, loudly, and clearly in English.';

  static const stopReminder = 'Tap Stop when you finish your answer.';

  /// Rotates on a timer while the mic is open for realtime guidance.
  static const rotatingTips = <String>[
    'Speak slowly.',
    'Speak loudly.',
    'Speak clearly.',
    'Answer in English.',
  ];
}

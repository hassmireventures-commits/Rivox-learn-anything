import 'package:flutter/material.dart';

class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.aiPromptName,
  });

  final String code;
  final String nativeName;
  final String englishName;
  final String aiPromptName;

  Locale get locale => Locale(code);
}

class SupportedLanguages {
  SupportedLanguages._();

  static const defaultCode = 'en';

  /// Picker / AI order: English → Tamil → Arabic → others.
  static const all = [
    SupportedLanguage(code: 'en', nativeName: 'English', englishName: 'English', aiPromptName: 'English'),
    SupportedLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', aiPromptName: 'Tamil'),
    SupportedLanguage(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', aiPromptName: 'Arabic'),
    SupportedLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', aiPromptName: 'Hindi'),
    SupportedLanguage(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', aiPromptName: 'Telugu'),
    SupportedLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish', aiPromptName: 'Spanish'),
    SupportedLanguage(code: 'fr', nativeName: 'Français', englishName: 'French', aiPromptName: 'French'),
    SupportedLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German', aiPromptName: 'German'),
    SupportedLanguage(code: 'pt', nativeName: 'Português', englishName: 'Portuguese', aiPromptName: 'Portuguese'),
    SupportedLanguage(code: 'zh', nativeName: '中文', englishName: 'Chinese (Simplified)', aiPromptName: 'Chinese'),
    SupportedLanguage(code: 'ja', nativeName: '日本語', englishName: 'Japanese', aiPromptName: 'Japanese'),
  ];

  /// Locales with known broken generated strings - normalize away from these.
  static const _blockedCodes = {'bn', 'ml', 'mr'};

  static SupportedLanguage? find(String code) {
    for (final lang in all) {
      if (lang.code == code) return lang;
    }
    return null;
  }

  static SupportedLanguage get defaultLanguage => all.first;

  static String normalizeCode(String? raw) {
    if (raw == null || raw.isEmpty) return defaultCode;
    if (_blockedCodes.contains(raw)) return defaultCode;
    if (find(raw) != null) return raw;
    final legacy = _legacyNameToCode[raw];
    if (legacy != null) {
      if (_blockedCodes.contains(legacy)) return defaultCode;
      return legacy;
    }
    return defaultCode;
  }

  static const _legacyNameToCode = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Hindi': 'hi',
    'Arabic': 'ar',
    'Portuguese': 'pt',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Bengali': 'bn',
    'Malayalam': 'ml',
    'Marathi': 'mr',
  };

  static String defaultCodeForDevice(Locale? deviceLocale) {
    if (deviceLocale == null) return defaultCode;
    final match = find(deviceLocale.languageCode);
    return match?.code ?? defaultCode;
  }
}

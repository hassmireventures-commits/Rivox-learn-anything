import 'package:flutter/material.dart';

import '../constants/supported_languages.dart';

Locale localeFromCode(String code) {
  final normalized = SupportedLanguages.normalizeCode(code);
  return SupportedLanguages.find(normalized)?.locale ?? SupportedLanguages.defaultLanguage.locale;
}

String aiLanguageName(String code) {
  final normalized = SupportedLanguages.normalizeCode(code);
  return SupportedLanguages.find(normalized)?.aiPromptName ?? SupportedLanguages.defaultLanguage.aiPromptName;
}

String languageNativeName(String code) {
  final normalized = SupportedLanguages.normalizeCode(code);
  return SupportedLanguages.find(normalized)?.nativeName ?? SupportedLanguages.defaultLanguage.nativeName;
}

/// BCP-47 language tag for NVIDIA Whisper STT.
String whisperLanguageCode(String code) {
  final normalized = SupportedLanguages.normalizeCode(code);
  return switch (normalized) {
    'en' => 'en-US',
    'es' => 'es-US',
    'fr' => 'fr-FR',
    'de' => 'de-DE',
    'pt' => 'pt-BR',
    'zh' => 'zh-CN',
    'ja' => 'ja-JP',
    'hi' => 'hi-IN',
    'ar' => 'ar',
    'ta' => 'ta-IN',
    'te' => 'te-IN',
    _ => 'en-US',
  };
}

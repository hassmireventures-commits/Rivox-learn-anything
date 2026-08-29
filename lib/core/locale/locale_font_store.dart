import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

/// Tracks which locale script fonts have been preloaded for clear glyph display.
class LocaleFontStore {
  LocaleFontStore._();

  static const _fileName = 'locale_fonts_ready_v1.json';
  static final Set<String> _ready = {};
  static bool _loaded = false;

  /// Locales that need a Noto download beyond Latin Poppins coverage.
  static bool needsScriptFont(String languageCode) {
    const nonLatin = {'ta', 'ar', 'hi', 'te', 'zh', 'ja'};
    return nonLatin.contains(languageCode);
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      for (final part in raw.split(',')) {
        final code = part.trim();
        if (code.isNotEmpty) _ready.add(code);
      }
    } catch (_) {}
  }

  static Future<bool> isReady(String languageCode) async {
    await _ensureLoaded();
    return _ready.contains(languageCode);
  }

  static Future<void> markReady(String languageCode) async {
    await _ensureLoaded();
    if (_ready.contains(languageCode)) return;
    _ready.add(languageCode);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(_ready.join(','));
    } catch (_) {}
  }

  /// Clears ready flag so the next change can re-prompt download.
  static Future<void> clearReady(String languageCode) async {
    await _ensureLoaded();
    if (!_ready.remove(languageCode)) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(_ready.join(','));
    } catch (_) {}
  }

  /// Preloads Noto families. Returns false if download/warm-up failed.
  static Future<bool> preloadFor(String languageCode) async {
    try {
      // Force font file resolution (throws if network/cache fails).
      switch (languageCode) {
        case 'ta':
          await GoogleFonts.pendingFonts([
            GoogleFonts.notoSansTamil(),
            GoogleFonts.notoSans(),
          ]);
        case 'te':
          await GoogleFonts.pendingFonts([
            GoogleFonts.notoSansTelugu(),
            GoogleFonts.notoSans(),
          ]);
        case 'hi':
          await GoogleFonts.pendingFonts([
            GoogleFonts.notoSansDevanagari(),
            GoogleFonts.notoSans(),
          ]);
        case 'ar':
          await GoogleFonts.pendingFonts([
            GoogleFonts.notoNaskhArabic(),
            GoogleFonts.notoSans(),
          ]);
        case 'zh':
          await GoogleFonts.pendingFonts([GoogleFonts.notoSansSc()]);
        case 'ja':
          await GoogleFonts.pendingFonts([GoogleFonts.notoSansJp()]);
        default:
          await GoogleFonts.pendingFonts([GoogleFonts.notoSans()]);
      }
      await markReady(languageCode);
      return true;
    } catch (_) {
      await clearReady(languageCode);
      return false;
    }
  }

  /// Font families must match google_fonts registry IDs (no spaces).
  static List<String> fallbackFamiliesFor(String? languageCode) {
    final code = languageCode ?? 'en';
    final list = <String>['NotoSans'];
    switch (code) {
      case 'ta':
        list.insert(0, 'NotoSansTamil');
      case 'te':
        list.insert(0, 'NotoSansTelugu');
      case 'hi':
        list.insert(0, 'NotoSansDevanagari');
      case 'ar':
        list.insert(0, 'NotoNaskhArabic');
      case 'zh':
        list.insert(0, 'NotoSansSC');
      case 'ja':
        list.insert(0, 'NotoSansJP');
    }
    return list;
  }
}

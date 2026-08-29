import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AiConsentPreferences {
  AiConsentPreferences({
    this.piiUploadConsent = false,
    this.sendChunksToProvider = false,
    this.generationMode = 'blended',
    this.economyMode = false,
    this.transparencySeen = false,
  });

  bool piiUploadConsent;
  bool sendChunksToProvider;
  String generationMode;
  bool economyMode;
  bool transparencySeen;

  Map<String, dynamic> toJson() => {
        'piiUploadConsent': piiUploadConsent,
        'sendChunksToProvider': sendChunksToProvider,
        'generationMode': generationMode,
        'economyMode': economyMode,
        'transparencySeen': transparencySeen,
      };

  factory AiConsentPreferences.fromJson(Map<String, dynamic> json) {
    return AiConsentPreferences(
      piiUploadConsent: json['piiUploadConsent'] as bool? ?? false,
      // Opt-in: missing key must not send library chunks to third-party providers.
      sendChunksToProvider: json['sendChunksToProvider'] as bool? ?? false,
      generationMode: json['generationMode'] as String? ?? 'blended',
      economyMode: json['economyMode'] as bool? ?? false,
      transparencySeen: json['transparencySeen'] as bool? ?? false,
    );
  }
}

class AiConsentGate {
  AiConsentGate._();
  static final instance = AiConsentGate._();

  AiConsentPreferences _cached = AiConsentPreferences();

  AiConsentPreferences get current => _cached;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ai_consent_preferences.json');
  }

  Future<AiConsentPreferences> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _cached;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _cached = AiConsentPreferences.fromJson(json);
      }
    } catch (_) {}
    return _cached;
  }

  Future<void> save(AiConsentPreferences prefs) async {
    _cached = prefs;
    final file = await _file();
    await file.writeAsString(jsonEncode(prefs.toJson()));
  }

  bool canSendChunksToProvider() => _cached.sendChunksToProvider;

  bool canUploadPii() => _cached.piiUploadConsent;
}

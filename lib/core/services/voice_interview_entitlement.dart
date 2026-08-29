import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// One free voice-interview session per app install (local persistence).
class VoiceInterviewEntitlement {
  VoiceInterviewEntitlement._();
  static final instance = VoiceInterviewEntitlement._();

  static const _fileName = 'voice_interview_entitlement_v1.json';

  bool? _cachedUsed;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<bool> hasUsedFreeSession() async {
    if (_cachedUsed != null) return _cachedUsed!;
    try {
      final file = await _file();
      if (!await file.exists()) {
        _cachedUsed = false;
        return false;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is Map) {
        _cachedUsed = json['used'] == true;
        return _cachedUsed!;
      }
    } catch (_) {}
    _cachedUsed = false;
    return false;
  }

  Future<bool> canStartVoiceInterview() async => !(await hasUsedFreeSession());

  Future<void> markFreeSessionUsed({required String personaId}) async {
    _cachedUsed = true;
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode({
          'used': true,
          'usedAt': DateTime.now().toIso8601String(),
          'persona': personaId,
        }),
      );
    } catch (_) {}
  }

  /// Testing / support reset only — not exposed in UI.
  Future<void> resetForDebug() async {
    _cachedUsed = false;
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

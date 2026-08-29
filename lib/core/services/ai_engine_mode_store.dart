import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// User AI routing: Built-in AI and BYOK cloud providers (legacy `local` migrates to cloud).
enum AiEngineMode {
  local,
  cloud;

  static AiEngineMode fromId(String? id) {
    return switch (id) {
      'local' => AiEngineMode.cloud,
      'cloud' => AiEngineMode.cloud,
      _ => AiEngineMode.cloud,
    };
  }

  String get id => name;
}

class AiEngineModeStore {
  AiEngineModeStore._();
  static final instance = AiEngineModeStore._();

  AiEngineMode? _cached;
  bool _hasChoice = false;

  bool get hasExplicitChoice => _hasChoice;
  AiEngineMode? get currentOrNull => _cached;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ai_engine_mode.json');
  }

  Future<AiEngineMode?> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        _cached = null;
        _hasChoice = false;
        return null;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        final rawId = json['mode'] as String?;
        final mode = AiEngineMode.fromId(rawId);
        _cached = mode;
        _hasChoice = json['chosen'] == true;
        if (rawId == 'local' && _hasChoice) {
          await save(AiEngineMode.cloud);
        }
        return _hasChoice ? mode : null;
      }
    } catch (_) {}
    return null;
  }

  /// Persists an explicit user selection (onboarding or Settings).
  Future<void> save(AiEngineMode mode) async {
    final normalized = mode == AiEngineMode.local ? AiEngineMode.cloud : mode;
    _cached = normalized;
    _hasChoice = true;
    final file = await _file();
    await file.writeAsString(
      jsonEncode({'mode': normalized.id, 'chosen': true}),
    );
  }

  Future<void> clear() async {
    _cached = null;
    _hasChoice = false;
    final file = await _file();
    if (file.existsSync()) await file.delete();
  }
}

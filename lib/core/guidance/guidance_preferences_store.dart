import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GuidancePreferences {
  GuidancePreferences({
    this.walkthroughCompletedAt,
    this.walkthroughVersion = 0,
    this.whatsNewSeenVersion = '',
    this.legalAcceptedVersion = '',
    this.dismissedHintIds = const [],
  });

  DateTime? walkthroughCompletedAt;
  int walkthroughVersion;
  String whatsNewSeenVersion;
  String legalAcceptedVersion;
  List<String> dismissedHintIds;

  Map<String, dynamic> toJson() => {
        'walkthroughCompletedAt': walkthroughCompletedAt?.toIso8601String(),
        'walkthroughVersion': walkthroughVersion,
        'whatsNewSeenVersion': whatsNewSeenVersion,
        'legalAcceptedVersion': legalAcceptedVersion,
        'dismissedHintIds': dismissedHintIds,
      };

  factory GuidancePreferences.fromJson(Map<String, dynamic> json) {
    return GuidancePreferences(
      walkthroughCompletedAt: json['walkthroughCompletedAt'] != null
          ? DateTime.tryParse(json['walkthroughCompletedAt'] as String)
          : null,
      walkthroughVersion: (json['walkthroughVersion'] as num?)?.toInt() ?? 0,
      whatsNewSeenVersion: json['whatsNewSeenVersion'] as String? ?? '',
      legalAcceptedVersion: json['legalAcceptedVersion'] as String? ?? '',
      dismissedHintIds: (json['dismissedHintIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class GuidancePreferencesStore {
  GuidancePreferencesStore._();
  static final instance = GuidancePreferencesStore._();

  static const currentWalkthroughVersion = 1;
  static const currentLegalVersion = '1.0.0';

  GuidancePreferences _cached = GuidancePreferences();

  GuidancePreferences get current => _cached;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/guidance_preferences.json');
  }

  Future<GuidancePreferences> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _cached;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _cached = GuidancePreferences.fromJson(json);
      }
    } catch (_) {}
    return _cached;
  }

  Future<void> save(GuidancePreferences prefs) async {
    _cached = prefs;
    final file = await _file();
    await file.writeAsString(jsonEncode(prefs.toJson()));
  }
}

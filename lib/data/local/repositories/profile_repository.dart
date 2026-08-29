import 'package:isar_community/isar.dart';

import '../../../core/constants/supported_languages.dart';
import '../isar_service.dart';
import '../models/app_settings.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  Future<UserProfile?> getProfile() async {
    return _db.userProfiles.where().findFirst();
  }

  Future<UserProfile> saveProfile(String name) async {
    final existing = await getProfile();
    final profile = existing ?? UserProfile()
      ..createdAt = DateTime.now();
    profile.name = name.trim();

    await _db.writeTxn(() async {
      await _db.userProfiles.put(profile);
    });
    return profile;
  }

  Future<AppSettings> getSettings() async {
    final existing = await _db.appSettings.where().findFirst();
    if (existing != null) {
      final normalized = SupportedLanguages.normalizeCode(existing.language);
      if (normalized != existing.language) {
        existing.language = normalized;
        await _db.writeTxn(() async {
          await _db.appSettings.put(existing);
        });
      }
      return existing;
    }

    final settings = AppSettings()
      ..themeMode = 'system'
      ..language = 'en'
      ..roomExpiryHours = 24;

    await _db.writeTxn(() async {
      await _db.appSettings.put(settings);
    });
    return settings;
  }

  Future<AppSettings> updateSettings({
    String? themeMode,
    String? defaultProviderId,
    String? language,
    int? roomExpiryHours,
  }) async {
    final settings = await getSettings();
    if (themeMode != null) settings.themeMode = themeMode;
    if (defaultProviderId != null) settings.defaultProviderId = defaultProviderId;
    if (language != null) settings.language = SupportedLanguages.normalizeCode(language);
    if (roomExpiryHours != null) settings.roomExpiryHours = roomExpiryHours;

    await _db.writeTxn(() async {
      await _db.appSettings.put(settings);
    });
    return settings;
  }
}

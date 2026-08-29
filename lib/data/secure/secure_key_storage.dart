import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStorage {
  SecureKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
            );

  final FlutterSecureStorage _storage;
  static const _prefix = 'ai_key_';
  static const _playerIdKey = 'player_id';

  Future<void> saveApiKey(String providerUuid, String apiKey) async {
    await _storage.write(key: '$_prefix$providerUuid', value: apiKey);
  }

  Future<String?> getApiKey(String providerUuid) async {
    return _storage.read(key: '$_prefix$providerUuid');
  }

  Future<void> deleteApiKey(String providerUuid) async {
    await _storage.delete(key: '$_prefix$providerUuid');
  }

  Future<void> clearAllKeys() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_prefix) || key == _playerIdKey) {
        await _storage.delete(key: key);
      }
    }
  }

  Future<String?> getPlayerId() => _storage.read(key: _playerIdKey);

  Future<void> savePlayerId(String id) => _storage.write(key: _playerIdKey, value: id);
}

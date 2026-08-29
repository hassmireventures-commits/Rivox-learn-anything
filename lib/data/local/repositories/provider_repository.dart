import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/ai_engine_mode_store.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../secure/secure_key_storage.dart';
import '../isar_service.dart';
import '../models/ai_provider_config.dart';
import '../../remote/ai/ai_provider.dart';

class ProviderRepository {
  ProviderRepository(this._isarService, this._secureStorage);

  final IsarService _isarService;
  final SecureKeyStorage _secureStorage;
  final _uuid = const Uuid();

  Isar get _db => _isarService.db;

  Future<List<AiProviderConfig>> getAll() async {
    return _db.aiProviderConfigs.where().sortByCreatedAtDesc().findAll();
  }

  Future<AiProviderConfig?> getByUuid(String uuid) async {
    return _db.aiProviderConfigs.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<AiProviderConfig?> getDefault() async {
    return _db.aiProviderConfigs.filter().isDefaultEqualTo(true).findFirst();
  }

  /// Providers with stored keys, ordered: default → other BYOK → Built-in.
  Future<List<({AiProviderConfig config, String apiKey})>> listResolvableWithKeys() async {
    final providers = await getAll();
    if (providers.isEmpty) return [];

    final preferred = providers.where((p) => p.isDefault).firstOrNull ?? providers.first;
    final byok = providers.where((p) => p.uuid != BuiltInAiConfig.uuid).toList();
    final ordered = <AiProviderConfig>[
      preferred,
      ...byok.where((p) => p.uuid != preferred.uuid),
      ...providers.where(
        (p) => p.uuid == BuiltInAiConfig.uuid && p.uuid != preferred.uuid,
      ),
    ];

    final seen = <String>{};
    final out = <({AiProviderConfig config, String apiKey})>[];
    for (final provider in ordered) {
      if (!seen.add(provider.uuid)) continue;
      final apiKey = await getApiKey(provider.uuid);
      if (apiKey != null && apiKey.trim().isNotEmpty) {
        out.add((config: provider, apiKey: apiKey.trim()));
      }
    }
    return out;
  }

  Future<AiProviderConfig> add({
    required String name,
    required String providerType,
    required String apiKey,
    required String defaultModel,
    String? baseUrl,
    bool setAsDefault = false,
  }) async {
    final providers = await getAll();
    final shouldDefault = setAsDefault || providers.isEmpty;
    final config = AiProviderConfig()
      ..uuid = _uuid.v4()
      ..name = name.trim()
      ..providerType = providerType
      ..baseUrl = baseUrl?.trim().isEmpty == true ? null : baseUrl?.trim()
      ..defaultModel = defaultModel.trim()
      ..isDefault = shouldDefault
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      if (shouldDefault) {
        final all = await _db.aiProviderConfigs.where().findAll();
        for (final p in all) {
          p.isDefault = false;
          await _db.aiProviderConfigs.put(p);
        }
      }
      await _db.aiProviderConfigs.put(config);
    });

    await _secureStorage.saveApiKey(config.uuid, apiKey.trim());
    return config;
  }

  Future<AiProviderConfig> update({
    required String uuid,
    required String name,
    required String providerType,
    required String defaultModel,
    String? baseUrl,
    String? apiKey,
  }) async {
    final config = await getByUuid(uuid);
    if (config == null) {
      throw StateError('Provider not found');
    }

    config
      ..name = name.trim()
      ..providerType = providerType
      ..baseUrl = baseUrl?.trim().isEmpty == true ? null : baseUrl?.trim()
      ..defaultModel = defaultModel.trim();

    await _db.writeTxn(() async {
      await _db.aiProviderConfigs.put(config);
    });

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      await _secureStorage.saveApiKey(uuid, apiKey.trim());
    }
    return config;
  }

  Future<void> setDefault(String uuid) async {
    await _db.writeTxn(() async {
      final all = await _db.aiProviderConfigs.where().findAll();
      for (final p in all) {
        p.isDefault = p.uuid == uuid;
        await _db.aiProviderConfigs.put(p);
      }
    });
  }

  Future<void> delete(String uuid) async {
    if (uuid == BuiltInAiConfig.uuid) {
      throw StateError('Built-in AI cannot be deleted.');
    }
    final config = await getByUuid(uuid);
    if (config == null) return;

    await _db.writeTxn(() async {
      await _db.aiProviderConfigs.delete(config.id);
      if (config.isDefault) {
        final remaining = await _db.aiProviderConfigs.where().findAll();
        if (remaining.isNotEmpty) {
          // Prefer Built-in as default when present.
          final builtin = remaining
              .where((p) => p.uuid == BuiltInAiConfig.uuid)
              .firstOrNull;
          final next = builtin ?? remaining.first;
          next.isDefault = true;
          await _db.aiProviderConfigs.put(next);
        }
      }
    });
    await _secureStorage.deleteApiKey(uuid);
  }

  Future<String?> getApiKey(String uuid) async {
    final stored = await _secureStorage.getApiKey(uuid);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    if (uuid == BuiltInAiConfig.uuid && BuiltInAiConfig.hasApiKey) {
      return BuiltInAiConfig.apiKey;
    }
    return null;
  }

  /// Idempotent seed of silent Built-in AI (dart-define key + cloud mode on first seed).
  Future<AiProviderConfig?> ensureBuiltInSeeded() async {
    final existing = await getByUuid(BuiltInAiConfig.uuid);
    final key = BuiltInAiConfig.apiKey;
    if (existing != null) {
      if (key.isNotEmpty) {
        await _secureStorage.saveApiKey(BuiltInAiConfig.uuid, key);
      }
      // Refresh model/URL/name so Built-in upgrades apply without reinstall.
      final needsRefresh = existing.defaultModel != BuiltInAiConfig.defaultModel ||
          existing.baseUrl != BuiltInAiConfig.baseUrl ||
          existing.name != BuiltInAiConfig.displayName ||
          existing.providerType != AiProviderType.builtin.name;
      if (needsRefresh) {
        existing
          ..name = BuiltInAiConfig.displayName
          ..providerType = AiProviderType.builtin.name
          ..baseUrl = BuiltInAiConfig.baseUrl
          ..defaultModel = BuiltInAiConfig.defaultModel;
        await _db.writeTxn(() async {
          await _db.aiProviderConfigs.put(existing);
        });
      }
      // Do not overwrite the user's persisted engine mode on every launch.
      return existing;
    }

    final all = await getAll();
    final makeDefault = all.isEmpty || all.every((p) => !p.isDefault);

    final config = AiProviderConfig()
      ..uuid = BuiltInAiConfig.uuid
      ..name = BuiltInAiConfig.displayName
      ..providerType = AiProviderType.builtin.name
      ..baseUrl = BuiltInAiConfig.baseUrl
      ..defaultModel = BuiltInAiConfig.defaultModel
      ..isDefault = makeDefault
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      if (makeDefault) {
        final rows = await _db.aiProviderConfigs.where().findAll();
        for (final p in rows) {
          p.isDefault = false;
          await _db.aiProviderConfigs.put(p);
        }
      }
      await _db.aiProviderConfigs.put(config);
    });

    if (key.isNotEmpty) {
      await _secureStorage.saveApiKey(BuiltInAiConfig.uuid, key);
    }
    await AiEngineModeStore.instance.save(AiEngineMode.cloud);
    return config;
  }
}

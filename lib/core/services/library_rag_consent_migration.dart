import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/knowledge_source.dart';
import '../ai_platform/ai_consent_gate.dart';

/// One-time: if the user already has consented/indexed library sources, enable chunk send.
class LibraryRagConsentMigration {
  LibraryRagConsentMigration._();

  static const _flagName = 'library_rag_consent_v1.done';

  static Future<void> runIfNeeded(IsarService isarService) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final flag = File('${dir.path}/$_flagName');
      if (await flag.exists()) return;

      final sources = await isarService.db.knowledgeSources.where().findAll();
      final hasLibrary = sources.any(
        (s) => s.consentAt != null || s.status == 'indexed',
      );
      if (hasLibrary) {
        await AiConsentGate.instance.load();
        final current = AiConsentGate.instance.current;
        if (!current.sendChunksToProvider) {
          await AiConsentGate.instance.save(
            AiConsentPreferences(
              piiUploadConsent: current.piiUploadConsent || hasLibrary,
              sendChunksToProvider: true,
              generationMode: current.generationMode,
              economyMode: false,
              transparencySeen: current.transparencySeen,
            ),
          );
        }
      }
      await flag.writeAsString(DateTime.now().toUtc().toIso8601String());
    } catch (_) {}
  }
}

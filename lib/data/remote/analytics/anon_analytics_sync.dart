import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/telemetry/telemetry_service.dart';
import '../../local/repositories/learner_repository.dart';
import '../../secure/secure_key_storage.dart';

class AnonAnalyticsSync {
  AnonAnalyticsSync({
    required this.telemetry,
    required this.learnerRepository,
    required this.secureStorage,
    FirebaseFirestore? firestore,
  }) : _db = firestore;

  /// Client Firestore writes require deployed rules (see firestore.rules).
  /// Override with `--dart-define=ENABLE_FIRESTORE_ANALYTICS=false` to disable.
  static const bool cloudWritesEnabled = bool.fromEnvironment(
    'ENABLE_FIRESTORE_ANALYTICS',
    defaultValue: true,
  );

  final TelemetryService telemetry;
  final LearnerRepository learnerRepository;
  final SecureKeyStorage secureStorage;
  final FirebaseFirestore? _db;

  Future<String> _anonId() async {
    final playerId = await secureStorage.getPlayerId() ?? 'unknown';
    final bytes = utf8.encode('${AppConstants.analyticsSalt}:$playerId');
    return sha256.convert(bytes).toString();
  }

  Future<void> syncIfOptedIn() async {
    if (!cloudWritesEnabled) return;
    if (Firebase.apps.isEmpty) return;
    final db = _db ?? FirebaseFirestore.instance;

    final profile = await learnerRepository.getOrCreateProfile();
    if (!profile.helpImproveOptIn) return;

    try {
      final anonId = await _anonId();
      final events = await telemetry.unsynced(limit: 50);
      if (events.isEmpty) {
        await _pullGlobalStats(db);
        return;
      }

      final batch = db.batch();
      final syncedIds = <int>[];
      for (final event in events) {
        final ref = db.collection('anon_events').doc();
        final payload = jsonDecode(event.payloadJson);
        final topic = payload is Map ? payload['topic']?.toString() : null;
        batch.set(ref, {
          'anonId': anonId,
          'type': event.type,
          'topicHash': topic == null ? null : sha256.convert(utf8.encode(topic)).toString(),
          'timestamp': Timestamp.fromDate(event.timestamp),
          // Never include names, keys, or full question text.
        });
        syncedIds.add(event.id);
      }
      await batch.commit();
      await telemetry.markSynced(syncedIds);
      await _pullGlobalStats(db);
    } catch (_) {
      // Cloud is optional; local learning continues.
    }
  }

  Future<void> _pullGlobalStats(FirebaseFirestore db) async {
    try {
      final snap = await db.collection('global_prompt_stats').limit(20).get();
      // Clients may blend these later; store lightly in telemetry for now.
      if (snap.docs.isEmpty) return;
      await telemetry.emit('global_stats_pulled', {'count': snap.docs.length});
    } catch (_) {}
  }

  Future<void> publishPromptOutcome(String strategyId, {required bool success}) async {
    if (!cloudWritesEnabled) return;
    if (Firebase.apps.isEmpty) return;
    final db = _db ?? FirebaseFirestore.instance;

    final profile = await learnerRepository.getOrCreateProfile();
    if (!profile.helpImproveOptIn) return;
    try {
      final ref = db.collection('global_prompt_stats').doc(strategyId);
      await db.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final data = doc.data() ?? {};
        final attempts = (data['attempts'] as int? ?? 0) + 1;
        final successes = (data['successes'] as int? ?? 0) + (success ? 1 : 0);
        tx.set(ref, {
          'attempts': attempts,
          'successes': successes,
          'successRate': successes / attempts,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (_) {}
  }
}

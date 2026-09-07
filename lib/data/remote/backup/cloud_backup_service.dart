import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/backup_flags.dart';
import '../../local/isar_service.dart';
import '../../local/path_steps_storage.dart';
import '../../local/repositories/chat_repository.dart';
import '../../local/repositories/cloud_backup_repository.dart';
import '../../local/repositories/flashcard_repository.dart';
import '../../local/repositories/knowledge_repository.dart';
import '../../local/repositories/learner_repository.dart';
import '../../local/repositories/quiz_repository.dart';
import '../../local/repositories/stats_repository.dart';
import '../../local/repositories/study_repository.dart';
import '../auth/auth_service.dart';
import 'backup_crypto.dart' as backup_crypto;

/// Bumped only for additive manifest-shape changes; the (future) Phase 3
/// restore flow gates on this to refuse newer-than-supported backups.
const int kBackupSchemaVersion = 1;

/// Typed failures for B13 cloud backup (Phase 2 — backup only, restore is a
/// separate later phase). Kept local rather than added to the sealed
/// `AppException` hierarchy in `core/error/app_exception.dart` — Dart's
/// `sealed` modifier restricts subclassing to the declaring library/file, so
/// a new subclass can't live here anyway. Callers can still catch these by
/// type same as any other typed exception.
class CloudBackupDisabledException implements Exception {
  const CloudBackupDisabledException();
  @override
  String toString() => 'Cloud backup is not enabled yet.';
}

class CloudBackupNotSignedInException implements Exception {
  const CloudBackupNotSignedInException();
  @override
  String toString() => 'Sign in with Google before creating a cloud backup.';
}

/// Wraps a lower-level failure (no internet, Firebase auth/storage/Firestore
/// error, or anything unexpected) with a short user-facing [message]; [cause]
/// keeps the original error for logs/diagnostics.
class CloudBackupFailedException implements Exception {
  const CloudBackupFailedException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message ($cause)';
}

/// Thrown by [CloudBackupService.restoreBackup] when no backup exists yet
/// for the signed-in account.
class CloudBackupNotFoundException implements Exception {
  const CloudBackupNotFoundException();
  @override
  String toString() => 'No cloud backup found for this account.';
}

/// Thrown by [CloudBackupService.restoreBackup] when the backup's
/// `backupSchemaVersion` is newer than this app build understands.
class CloudBackupUnsupportedSchemaException implements Exception {
  const CloudBackupUnsupportedSchemaException(this.foundVersion, this.maxSupportedVersion);

  final int foundVersion;
  final int maxSupportedVersion;

  @override
  String toString() =>
      'This backup (schema $foundVersion) needs a newer version of the app '
      '(this build supports up to schema $maxSupportedVersion). Please update Rivox.';
}

/// Orchestrates B13 encrypted cloud backup (Phase 2: one-way backup only —
/// no restore/download/decrypt-and-apply path here, see the approved plan's
/// Phase 3). Assembles one combined manifest from every in-scope repository,
/// encrypts it client-side (Rivox/Firebase never see the passphrase or
/// plaintext), and uploads the encrypted blob to Firebase Storage with a
/// small cleartext metadata doc (salt, KDF iterations, schema version) in
/// Firestore.
///
/// Storage layout (documented here since Phase 3's restore reads the exact
/// same shape back):
///   - Encrypted blob: Firebase Storage `users/{uid}/backups/latest.enc`
///     — bytes are `[12-byte nonce][ciphertext][16-byte GCM tag]`
///     (see `backup_crypto.dart`).
///   - Metadata doc: Firestore `users/{uid}/backup_metadata/current` with
///     fields `saltBase64`, `kdfIterations`, `kdfAlgorithm` ('pbkdf2-sha256'),
///     `backupSchemaVersion`, `appVersion`, `createdAt`, `sizeBytes`.
///   - Manifest JSON keys: `backupSchemaVersion`, `exportedAt`, `appVersion`,
///     `learnerProfile`, `quizData`, `statsData`, `flashcards`,
///     `chatMessages`, `knowledgeData`, `studyData`, `learningPaths`,
///     `pathSteps` (a map of path uuid -> step list, from `PathStepsStorage`).
class CloudBackupService {
  CloudBackupService({
    required CloudBackupRepository cloudBackupRepository,
    required AuthService authService,
    required IsarService isarService,
    required QuizRepository quizRepository,
    required StatsRepository statsRepository,
    required LearnerRepository learnerRepository,
    required FlashcardRepository flashcardRepository,
    required ChatRepository chatRepository,
    required KnowledgeRepository knowledgeRepository,
    required StudyRepository studyRepository,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _cloudBackupRepository = cloudBackupRepository,
        _authService = authService,
        _isarService = isarService,
        _quizRepository = quizRepository,
        _statsRepository = statsRepository,
        _learnerRepository = learnerRepository,
        _flashcardRepository = flashcardRepository,
        _chatRepository = chatRepository,
        _knowledgeRepository = knowledgeRepository,
        _studyRepository = studyRepository,
        _firestoreOverride = firestore,
        _storageOverride = storage;

  final CloudBackupRepository _cloudBackupRepository;
  final AuthService _authService;
  final IsarService _isarService;
  final QuizRepository _quizRepository;
  final StatsRepository _statsRepository;
  final LearnerRepository _learnerRepository;
  final FlashcardRepository _flashcardRepository;
  final ChatRepository _chatRepository;
  final KnowledgeRepository _knowledgeRepository;
  final StudyRepository _studyRepository;
  final FirebaseFirestore? _firestoreOverride;
  final FirebaseStorage? _storageOverride;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;
  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  /// Encrypts and uploads a fresh full backup for the current user.
  ///
  /// Throws [CloudBackupDisabledException] if [kCloudBackupEnabled] is off,
  /// [CloudBackupNotSignedInException] if nobody is signed in, or
  /// [CloudBackupFailedException] wrapping any network/Firebase/unexpected
  /// failure — never silently no-ops.
  Future<void> createBackup({required String passphrase}) async {
    if (!kCloudBackupEnabled) {
      throw const CloudBackupDisabledException();
    }
    final user = _authService.currentUser;
    if (user == null) {
      throw const CloudBackupNotSignedInException();
    }
    final uid = user.uid;

    try {
      final manifest = await _buildManifest();
      final manifestJson = jsonEncode(manifest);

      final metadataRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('backup_metadata')
          .doc('current');
      final existingMetadata = await metadataRef.get();
      final existingData = existingMetadata.data();

      final List<int> salt;
      final int iterations;
      if (existingData != null && existingData['saltBase64'] is String) {
        // Reuse this account's existing salt/iterations — this device must
        // derive the SAME key the account's first-ever backup used, or this
        // backup becomes silently undecryptable with the original
        // passphrase. There's no way to verify the passphrase matches
        // without an actual decrypt attempt (that's Phase 3's restore path);
        // we just derive and proceed.
        salt = base64Decode(existingData['saltBase64'] as String);
        iterations = (existingData['kdfIterations'] as num?)?.toInt() ??
            backup_crypto.kDefaultPbkdf2Iterations;
      } else {
        salt = backup_crypto.generateSalt();
        iterations = backup_crypto.kDefaultPbkdf2Iterations;
      }

      final key = await backup_crypto.deriveKey(passphrase, salt, iterations);
      final encrypted = await backup_crypto.encrypt(manifestJson, key);

      final storageRef = _storage.ref('users/$uid/backups/latest.enc');
      await storageRef.putData(encrypted);

      final saltBase64 = base64Encode(salt);
      await metadataRef.set({
        'saltBase64': saltBase64,
        'kdfIterations': iterations,
        'kdfAlgorithm': 'pbkdf2-sha256',
        'backupSchemaVersion': kBackupSchemaVersion,
        'appVersion': AppConstants.appVersion,
        'createdAt': FieldValue.serverTimestamp(),
        'sizeBytes': encrypted.length,
      }, SetOptions(merge: true));

      await _cloudBackupRepository.updateState(
        linkedUid: uid,
        lastBackupAt: DateTime.now(),
        lastBackupSizeBytes: encrypted.length,
        kdfSaltBase64: saltBase64,
        kdfIterations: iterations,
      );
    } on CloudBackupDisabledException {
      rethrow;
    } on CloudBackupNotSignedInException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CloudBackupFailedException(
        'Cloud backup failed (${e.plugin}: ${e.code}): ${e.message ?? 'unknown error'}',
        cause: e,
      );
    } catch (e) {
      throw CloudBackupFailedException('Cloud backup failed: $e', cause: e);
    }
  }

  /// Downloads, decrypts, and applies this account's cloud backup — replacing
  /// ALL current on-device data in backup scope (see
  /// `IsarService.clearBackupInScopeData`). Callers must confirm this
  /// destructive effect with the user BEFORE calling this method; it does
  /// not ask for confirmation itself.
  ///
  /// Throws [CloudBackupDisabledException]/[CloudBackupNotSignedInException]
  /// (same guards as [createBackup]), [CloudBackupNotFoundException] if no
  /// backup exists yet for this account,
  /// `backup_crypto.BackupDecryptionException` if [passphrase] is wrong or
  /// the blob is corrupted (propagated as-is so callers can show a specific
  /// message), [CloudBackupUnsupportedSchemaException] if the backup is
  /// newer than this app build understands, or [CloudBackupFailedException]
  /// wrapping any other network/Firebase/unexpected failure.
  Future<void> restoreBackup({required String passphrase}) async {
    if (!kCloudBackupEnabled) {
      throw const CloudBackupDisabledException();
    }
    final user = _authService.currentUser;
    if (user == null) {
      throw const CloudBackupNotSignedInException();
    }
    final uid = user.uid;

    try {
      final metadataRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('backup_metadata')
          .doc('current');
      final metadataSnapshot = await metadataRef.get();
      final metadata = metadataSnapshot.data();
      if (metadata == null || metadata['saltBase64'] is! String) {
        throw const CloudBackupNotFoundException();
      }

      final salt = base64Decode(metadata['saltBase64'] as String);
      final iterations =
          (metadata['kdfIterations'] as num?)?.toInt() ?? backup_crypto.kDefaultPbkdf2Iterations;
      final schemaVersion = (metadata['backupSchemaVersion'] as num?)?.toInt() ?? 1;
      if (schemaVersion > kBackupSchemaVersion) {
        throw CloudBackupUnsupportedSchemaException(schemaVersion, kBackupSchemaVersion);
      }

      final Uint8List encrypted;
      try {
        final bytes = await _storage.ref('users/$uid/backups/latest.enc').getData(
              50 * 1024 * 1024, // 50 MiB cap — generous for a text-only manifest.
            );
        if (bytes == null) throw const CloudBackupNotFoundException();
        encrypted = bytes;
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') throw const CloudBackupNotFoundException();
        rethrow;
      }

      final key = await backup_crypto.deriveKey(passphrase, salt, iterations);
      // Not caught here on purpose — BackupDecryptionException propagates
      // as-is so the caller can show "incorrect passphrase or corrupted
      // backup" instead of a generic failure message.
      final manifestJson = await backup_crypto.decrypt(encrypted, key);
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

      await _applyManifest(manifest);

      await _cloudBackupRepository.updateState(
        linkedUid: uid,
        lastRestoreAt: DateTime.now(),
        kdfSaltBase64: metadata['saltBase64'] as String,
        kdfIterations: iterations,
      );
    } on CloudBackupDisabledException {
      rethrow;
    } on CloudBackupNotSignedInException {
      rethrow;
    } on CloudBackupNotFoundException {
      rethrow;
    } on CloudBackupUnsupportedSchemaException {
      rethrow;
    } on backup_crypto.BackupDecryptionException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CloudBackupFailedException(
        'Cloud restore failed (${e.plugin}: ${e.code}): ${e.message ?? 'unknown error'}',
        cause: e,
      );
    } catch (e) {
      throw CloudBackupFailedException('Cloud restore failed: $e', cause: e);
    }
  }

  /// Wipes in-scope local data and writes the decoded manifest back —
  /// tolerant of missing/extra fields (same idiom as the existing
  /// `QuizRepository.importData`/`StatsRepository.importStats`) so a
  /// slightly-older or slightly-newer (but schema-compatible) backup
  /// degrades gracefully instead of throwing.
  Future<void> _applyManifest(Map<String, dynamic> manifest) async {
    await _isarService.clearBackupInScopeData();

    final learnerProfile = manifest['learnerProfile'] as Map?;
    if (learnerProfile != null) {
      await _learnerRepository.importProfile(Map<String, dynamic>.from(learnerProfile));
    }

    final quizData = manifest['quizData'] as Map?;
    if (quizData != null) {
      await _quizRepository.importData(Map<String, dynamic>.from(quizData));
    }

    final statsData = manifest['statsData'] as Map?;
    if (statsData != null) {
      await _statsRepository.importStats(Map<String, dynamic>.from(statsData));
    }

    await _flashcardRepository.importFlashcards((manifest['flashcards'] as List?) ?? []);
    await _chatRepository.importMessages((manifest['chatMessages'] as List?) ?? []);

    final knowledgeData = manifest['knowledgeData'] as Map?;
    if (knowledgeData != null) {
      await _knowledgeRepository.importKnowledgeData(Map<String, dynamic>.from(knowledgeData));
    }

    final studyData = manifest['studyData'] as Map?;
    if (studyData != null) {
      await _studyRepository.importStudyData(Map<String, dynamic>.from(studyData));
    }

    await _learnerRepository.importLearningPaths((manifest['learningPaths'] as List?) ?? []);

    final pathSteps = manifest['pathSteps'] as Map?;
    if (pathSteps != null) {
      for (final entry in pathSteps.entries) {
        final steps = (entry.value as List? ?? [])
            .map((raw) => Map<String, dynamic>.from(raw as Map))
            .toList();
        if (steps.isNotEmpty) {
          await PathStepsStorage.instance.saveSteps(entry.key as String, steps);
        }
      }
    }
  }

  Future<Map<String, dynamic>> _buildManifest() async {
    final learningPaths = await _learnerRepository.exportLearningPaths();
    final pathUuids = learningPaths
        .map((p) => p['uuid'])
        .whereType<String>()
        .toList();

    return {
      'backupSchemaVersion': kBackupSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': AppConstants.appVersion,
      'learnerProfile': await _learnerRepository.exportProfile(),
      'quizData': await _quizRepository.exportData(),
      'statsData': await _statsRepository.exportStats(),
      'flashcards': await _flashcardRepository.exportFlashcards(),
      'chatMessages': await _chatRepository.exportMessages(),
      'knowledgeData': await _knowledgeRepository.exportKnowledgeData(),
      'studyData': await _studyRepository.exportStudyData(),
      'learningPaths': learningPaths,
      'pathSteps': await _exportPathSteps(pathUuids),
    };
  }

  /// Per-path step JSON files (outside Isar, see `PathStepsStorage`), keyed
  /// by path uuid. Paths with no saved step file (bare-topic fallback) are
  /// simply omitted from the map.
  Future<Map<String, dynamic>> _exportPathSteps(List<String> pathUuids) async {
    final result = <String, dynamic>{};
    for (final uuid in pathUuids) {
      final steps = await PathStepsStorage.instance.loadSteps(uuid);
      if (steps.isNotEmpty) {
        result[uuid] = steps;
      }
    }
    return result;
  }
}

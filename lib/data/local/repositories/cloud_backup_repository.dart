import 'package:isar_community/isar.dart';

import '../isar_service.dart';
import '../models/cloud_backup_state.dart';

/// Repository for the singleton [CloudBackupState] row (B13, Phase 1).
class CloudBackupRepository {
  CloudBackupRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  Future<CloudBackupState> getOrCreateState() async {
    final existing = await _db.cloudBackupStates.where().findFirst();
    if (existing != null) return existing;

    final state = CloudBackupState()
      ..enabled = false
      ..linkedUid = null
      ..lastBackupAt = null
      ..lastBackupSizeBytes = null
      ..lastRestoreAt = null
      ..kdfSaltBase64 = null
      ..kdfIterations = null;

    await _db.writeTxn(() async {
      await _db.cloudBackupStates.put(state);
    });
    return state;
  }

  Future<CloudBackupState> updateState({
    bool? enabled,
    String? linkedUid,
    DateTime? lastBackupAt,
    int? lastBackupSizeBytes,
    DateTime? lastRestoreAt,
    String? kdfSaltBase64,
    int? kdfIterations,
  }) async {
    final state = await getOrCreateState();
    if (enabled != null) state.enabled = enabled;
    if (linkedUid != null) state.linkedUid = linkedUid;
    if (lastBackupAt != null) state.lastBackupAt = lastBackupAt;
    if (lastBackupSizeBytes != null) state.lastBackupSizeBytes = lastBackupSizeBytes;
    if (lastRestoreAt != null) state.lastRestoreAt = lastRestoreAt;
    if (kdfSaltBase64 != null) state.kdfSaltBase64 = kdfSaltBase64;
    if (kdfIterations != null) state.kdfIterations = kdfIterations;

    await _db.writeTxn(() async {
      await _db.cloudBackupStates.put(state);
    });
    return state;
  }
}

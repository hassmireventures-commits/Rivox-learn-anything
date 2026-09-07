import 'package:isar_community/isar.dart';

part 'cloud_backup_state.g.dart';

/// Singleton row tracking this device's B13 cloud-backup opt-in + state.
///
/// Phase 1 only wires the opt-in toggle and the linked-account bookkeeping;
/// [lastBackupAt]/[lastBackupSizeBytes]/[lastRestoreAt]/[kdfSaltBase64]/
/// [kdfIterations] are populated starting in Phase 2/3. Intentionally
/// excluded from the backup manifest itself (backing up your own tracking
/// state is circular) and from [IsarService.clearLearningData] (it isn't
/// "learning data").
@collection
class CloudBackupState {
  Id id = Isar.autoIncrement;

  /// Opt-in toggle; default false.
  late bool enabled;

  /// Firebase uid this device last backed up/restored against.
  String? linkedUid;

  DateTime? lastBackupAt;

  int? lastBackupSizeBytes;

  DateTime? lastRestoreAt;

  /// Local cache only — never authoritative. Phase 2 will always re-fetch
  /// the salt from Firestore on a fresh-device restore.
  String? kdfSaltBase64;

  int? kdfIterations;
}

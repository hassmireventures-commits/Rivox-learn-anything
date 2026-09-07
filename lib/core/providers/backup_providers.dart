import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/repositories/cloud_backup_repository.dart';
import '../../data/local/repositories/study_repository.dart';
import '../../data/remote/auth/auth_service.dart';
import '../../data/remote/backup/cloud_backup_service.dart';
import 'ai_platform_providers.dart';
import 'app_providers.dart';

/// B13 cloud backup (Phase 1: auth + opt-in plumbing only). See
/// ai_platform_providers.dart for the split-out-provider-file precedent this
/// mirrors.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final cloudBackupRepositoryProvider = Provider<CloudBackupRepository>((ref) {
  return CloudBackupRepository(ref.watch(isarServiceProvider));
});

/// B13 cloud backup (Phase 2: backup only, no restore yet).
final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(ref.watch(isarServiceProvider));
});

final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  return CloudBackupService(
    cloudBackupRepository: ref.watch(cloudBackupRepositoryProvider),
    authService: ref.watch(authServiceProvider),
    isarService: ref.watch(isarServiceProvider),
    quizRepository: ref.watch(quizRepositoryProvider),
    statsRepository: ref.watch(statsRepositoryProvider),
    learnerRepository: ref.watch(learnerRepositoryProvider),
    flashcardRepository: ref.watch(flashcardRepositoryProvider),
    chatRepository: ref.watch(chatRepositoryProvider),
    knowledgeRepository: ref.watch(knowledgeRepositoryProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
  );
});

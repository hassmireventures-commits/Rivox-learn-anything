import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/backup_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/services/backup_flags.dart';
import '../../../data/local/models/cloud_backup_state.dart';
import '../../../data/remote/backup/cloud_backup_service.dart';
import '../../../shared/widgets/app_card.dart';
import 'backup_passphrase_sheet.dart';

/// B13 cloud backup — sign-in, opt-in toggle, manual "Create backup now" /
/// "Restore from backup". No continuous/automatic sync — every operation is
/// explicit and user-initiated (see the approved plan's Phase 4 note on what
/// stays deferred: two-way sync, conflict resolution, scheduling).
///
/// Reachability is gated on [kCloudBackupEnabled] at the settings entry point
/// (see settings_screen.dart); this defensive check covers direct navigation
/// while the flag is off.
class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (!kCloudBackupEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cloud Backup')),
        body: const Center(child: Text('Cloud backup is not available yet.')),
      );
    }

    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cloud Backup'),
        toolbarHeight: 56,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          userAsync.when(
            data: (user) => user == null
                ? const _SignedOutCard()
                : _SignedInCard(user: user),
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => AppCard(
              child: Text(
                'Something went wrong checking your sign-in state: $e',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOutCard extends ConsumerStatefulWidget {
  const _SignedOutCard();

  @override
  ConsumerState<_SignedOutCard> createState() => _SignedOutCardState();
}

class _SignedOutCardState extends ConsumerState<_SignedOutCard> {
  bool _signingIn = false;

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Back up your progress',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with Google to optionally enable encrypted cloud backup '
            'for your account. Nothing is uploaded until you turn it on.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _signingIn ? null : _signIn,
              icon: _signingIn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(_signingIn ? 'Signing in…' : 'Sign in with Google'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInCard extends ConsumerStatefulWidget {
  const _SignedInCard({required this.user});

  final User user;

  @override
  ConsumerState<_SignedInCard> createState() => _SignedInCardState();
}

class _SignedInCardState extends ConsumerState<_SignedInCard> {
  bool _signingOut = false;
  late Future<CloudBackupState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = ref.read(cloudBackupRepositoryProvider).getOrCreateState();
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(authServiceProvider).signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-out failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Future<void> _setEnabled(bool value) async {
    final repo = ref.read(cloudBackupRepositoryProvider);
    await repo.updateState(enabled: value, linkedUid: widget.user.uid);
    setState(() {
      _stateFuture = repo.getOrCreateState();
    });
  }

  /// Opens the passphrase sheet, then runs the backup with the same
  /// blocking-progress-dialog + SnackBar pattern as
  /// `settings_screen.dart`'s `_exportData`/`_resetApp` (no new UI pattern).
  Future<void> _createBackupNow() async {
    final passphrase = await BackupPassphraseSheet.show(context);
    if (passphrase == null || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Backing up your data…')),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(cloudBackupServiceProvider).createBackup(passphrase: passphrase);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss progress dialog
      final repo = ref.read(cloudBackupRepositoryProvider);
      setState(() {
        _stateFuture = repo.getOrCreateState();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully.')),
      );
    } on CloudBackupNotSignedInException catch (e) {
      _showBackupError(e.toString());
    } on CloudBackupDisabledException catch (e) {
      _showBackupError(e.toString());
    } on CloudBackupFailedException catch (e) {
      _showBackupError(e.message);
    } catch (e) {
      _showBackupError('Backup failed: $e');
    }
  }

  void _showBackupError(String message) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss progress dialog
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Restores this account's cloud backup — a destructive, whole-state
  /// operation that replaces all current on-device content in backup scope.
  /// Confirms with the user first (modeled on `settings_screen.dart`'s
  /// `_resetApp` confirmation dialog), then reuses the same
  /// blocking-progress-dialog + SnackBar pattern as backup.
  Future<void> _restoreBackupNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
          'This replaces your current quiz history, learning paths, '
          'flashcards, chat history, library uploads, and syllabus/study-plan/'
          'career data on this device with what\'s in your cloud backup. '
          "Anything on this device that isn't in that backup will be lost. "
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final passphrase = await BackupPassphraseSheet.show(
      context,
      mode: BackupPassphraseSheetMode.enterExisting,
    );
    if (passphrase == null || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Restoring your data…')),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(cloudBackupServiceProvider).restoreBackup(passphrase: passphrase);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss progress dialog

      // Restored data invalidates all the same caches a full data reset
      // would — mirrors settings_screen.dart's _resetApp invalidation.
      ref.invalidate(profileProvider);
      ref.invalidate(learnerProfileProvider);
      invalidateHomeProviders(ref);

      final repo = ref.read(cloudBackupRepositoryProvider);
      setState(() {
        _stateFuture = repo.getOrCreateState();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully.')),
      );
    } on CloudBackupNotFoundException {
      _showBackupError('No cloud backup found for this account yet.');
    } on CloudBackupUnsupportedSchemaException catch (e) {
      _showBackupError(e.toString());
    } on CloudBackupFailedException catch (e) {
      _showBackupError(e.message);
    } catch (e) {
      // Covers backup_crypto.BackupDecryptionException (wrong passphrase or
      // corrupted backup) and anything unexpected with its own clear message.
      _showBackupError('$e');
    }
  }

  String _formatBackupTimestamp(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  String _formatBackupSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : null,
              child: widget.user.photoURL == null
                  ? const Icon(Icons.person_rounded)
                  : null,
            ),
            title: Text(widget.user.displayName ?? widget.user.email ?? 'Signed in'),
            subtitle: widget.user.email != null ? Text(widget.user.email!) : null,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Encrypted cloud backup',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'When this is on, your quiz history, learning paths, '
                'flashcards, and other study content will be encrypted on '
                'your device and backed up to the cloud so you don\'t lose '
                'it if you lose this device — Rivox itself can never read '
                'it. Only you, with your own passphrase, can decrypt a '
                'backup.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<CloudBackupState>(
                future: _stateFuture,
                builder: (context, snapshot) {
                  final enabled = snapshot.data?.enabled ?? false;
                  final state = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable encrypted cloud backup'),
                        value: enabled,
                        onChanged: snapshot.connectionState == ConnectionState.waiting
                            ? null
                            : _setEnabled,
                      ),
                      if (enabled) ...[
                        const SizedBox(height: 4),
                        if (state?.lastBackupAt != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Last backup: ${_formatBackupTimestamp(state!.lastBackupAt!)}'
                              '${state.lastBackupSizeBytes != null ? ' · ${_formatBackupSize(state.lastBackupSizeBytes!)}' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _createBackupNow,
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: const Text('Create backup now'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _restoreBackupNow,
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: const Text('Restore from backup'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _signingOut ? null : _signOut,
            icon: _signingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: Text(_signingOut ? 'Signing out…' : 'Sign out'),
          ),
        ),
      ],
    );
  }
}

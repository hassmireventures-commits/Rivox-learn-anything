import 'package:flutter/material.dart';

/// Which flow this sheet is being shown for: [setNew] (first backup on a
/// device, or a repeat backup — always the same passphrase for a given
/// account) or [enterExisting] (restore, or a second device's first backup
/// joining an account that already has one — must enter the SAME passphrase
/// the account's original backup used).
enum BackupPassphraseSheetMode { setNew, enterExisting }

/// Bottom sheet that collects (and, in [BackupPassphraseSheetMode.setNew],
/// confirms) the passphrase used to encrypt a cloud backup.
///
/// This is a client-side, end-to-end-encryption passphrase: Rivox never sees
/// it and never stores it. If the user forgets it and has no other
/// signed-in device with a backup already made, the backup can never be
/// recovered — not even by Rivox. That warning is always visible (not
/// tucked behind a collapsed section) and must be explicitly acknowledged
/// before the confirm button is enabled.
class BackupPassphraseSheet extends StatefulWidget {
  const BackupPassphraseSheet({super.key, this.mode = BackupPassphraseSheetMode.setNew});

  final BackupPassphraseSheetMode mode;

  /// Shows the sheet and returns the confirmed passphrase, or `null` if the
  /// user cancelled or dismissed it.
  static Future<String?> show(
    BuildContext context, {
    BackupPassphraseSheetMode mode = BackupPassphraseSheetMode.setNew,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BackupPassphraseSheet(mode: mode),
    );
  }

  @override
  State<BackupPassphraseSheet> createState() => _BackupPassphraseSheetState();
}

class _BackupPassphraseSheetState extends State<BackupPassphraseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _acknowledgedRisk = false;

  static const _minPassphraseLength = 8;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isEnterExisting => widget.mode == BackupPassphraseSheetMode.enterExisting;

  void _submit() {
    if (!_isEnterExisting && !_acknowledgedRisk) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_passphraseController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _isEnterExisting || _acknowledgedRisk;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _isEnterExisting ? 'Enter your backup passphrase' : 'Set a backup passphrase',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isEnterExisting
                          ? 'This must be the exact passphrase you used when you '
                              'first set up encrypted backup for this account. If '
                              "it doesn't match, the backup can't be decrypted."
                          : "If you forget this passphrase and don't have another "
                              'signed-in device with a backup already made, this '
                              'backup can never be recovered — not even by us.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passphraseController,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter a passphrase.';
                if (!_isEnterExisting && value.length < _minPassphraseLength) {
                  return 'Use at least $_minPassphraseLength characters.';
                }
                return null;
              },
            ),
            if (!_isEnterExisting) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirm passphrase',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _passphraseController.text) {
                    return 'Passphrases do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _acknowledgedRisk,
                onChanged: (value) => setState(() => _acknowledgedRisk = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "I understand this passphrase cannot be recovered if I forget it.",
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canSubmit ? _submit : null,
                    child: Text(_isEnterExisting ? 'Restore' : 'Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

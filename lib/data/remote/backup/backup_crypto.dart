import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Isolated, independently-testable AES-256-GCM + PBKDF2-HMAC-SHA256 helpers
/// for B13 encrypted cloud backup (Phase 2). No Firebase dependency here —
/// `CloudBackupService` is the orchestrator that wires this to Firestore /
/// Firebase Storage.
///
/// Wire format for an encrypted blob (what actually gets uploaded):
/// `[12-byte nonce][ciphertext][16-byte GCM tag]`, all concatenated as one
/// byte array. This matches `SecretBox.concatenation()`'s default field order
/// (nonce, cipherText, mac) so [encrypt]/[decrypt] are simple pass-throughs
/// to `package:cryptography`'s own concatenation helpers.

/// PBKDF2 iteration count used for new backups, per current OWASP password
/// storage guidance (600k for PBKDF2-HMAC-SHA256). Stored in cleartext
/// alongside each backup's metadata so it can change between backups without
/// breaking the ability to derive the key for older ones.
///
/// NOTE: benchmarked at ~1.6s per [deriveKey] call on this dev machine (see
/// `test/backup_crypto_test.dart`'s benchmark) — see this task's final report
/// for the measured number and a recommendation on whether that's acceptable
/// backup-creation latency for real devices (especially low-end Android).
const int kDefaultPbkdf2Iterations = 600000;

const int _gcmNonceLength = 12;
const int _gcmMacLength = 16;
const int _saltLength = 16;

/// Thrown by [decrypt] when the GCM authentication tag doesn't match — i.e.
/// wrong passphrase (wrong derived key) or corrupted/tampered ciphertext.
/// Kept distinct from other exceptions so callers (the future Phase 3 restore
/// flow) can show "incorrect passphrase or corrupted backup" instead of a
/// generic error.
class BackupDecryptionException implements Exception {
  const BackupDecryptionException([
    this.message = 'Failed to decrypt backup: wrong passphrase or corrupted data.',
  ]);

  final String message;

  @override
  String toString() => 'BackupDecryptionException: $message';
}

/// Generates a fresh random 16-byte salt for PBKDF2. Only ever minted once
/// per account's first-ever backup — every subsequent backup (any device)
/// reuses the same salt so the same passphrase always derives the same key.
List<int> generateSalt() {
  final random = Random.secure();
  return List<int>.generate(_saltLength, (_) => random.nextInt(256));
}

/// Derives a 256-bit AES key from [passphrase] via PBKDF2-HMAC-SHA256.
Future<SecretKey> deriveKey(
  String passphrase,
  List<int> salt,
  int iterations,
) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );
  return pbkdf2.deriveKeyFromPassword(password: passphrase, nonce: salt);
}

/// Encrypts [plaintext] with AES-256-GCM under [key], using a fresh random
/// 12-byte nonce. Returns `[nonce][ciphertext][tag]` concatenated.
Future<Uint8List> encrypt(String plaintext, SecretKey key) async {
  final algorithm = AesGcm.with256bits(nonceLength: _gcmNonceLength);
  final nonce = algorithm.newNonce();
  final secretBox = await algorithm.encrypt(
    utf8.encode(plaintext),
    secretKey: key,
    nonce: nonce,
  );
  return secretBox.concatenation();
}

/// Decrypts a `[nonce][ciphertext][tag]` blob produced by [encrypt], using
/// AES-256-GCM under [key]. Throws [BackupDecryptionException] if the GCM
/// auth tag doesn't verify (wrong key/passphrase, or corrupted/truncated
/// data) rather than letting the underlying MAC error leak through.
Future<String> decrypt(Uint8List blob, SecretKey key) async {
  final algorithm = AesGcm.with256bits(nonceLength: _gcmNonceLength);
  if (blob.length < _gcmNonceLength + _gcmMacLength) {
    throw const BackupDecryptionException(
      'Backup data is too short to be valid — it may be corrupted or truncated.',
    );
  }
  final secretBox = SecretBox.fromConcatenation(
    blob,
    nonceLength: _gcmNonceLength,
    macLength: _gcmMacLength,
  );
  try {
    final clearBytes = await algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clearBytes);
  } on SecretBoxAuthenticationError {
    throw const BackupDecryptionException();
  }
}

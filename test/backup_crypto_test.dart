import 'dart:typed_data';

import 'package:ai_quiz_app/data/remote/backup/backup_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('backup_crypto', () {
    test('encrypt -> decrypt round-trips the original plaintext', () async {
      final salt = generateSalt();
      expect(salt.length, 16);

      final key = await deriveKey('correct horse battery staple', salt, 1000);
      const plaintext = '{"hello":"world","n":42}';

      final blob = await encrypt(plaintext, key);
      final decrypted = await decrypt(blob, key);

      expect(decrypted, plaintext);
    });

    test('decrypting with the wrong passphrase throws BackupDecryptionException', () async {
      final salt = generateSalt();
      final rightKey = await deriveKey('right passphrase', salt, 1000);
      final wrongKey = await deriveKey('wrong passphrase', salt, 1000);

      final blob = await encrypt('secret content', rightKey);

      expect(
        () => decrypt(blob, wrongKey),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test('decrypting a tampered blob throws BackupDecryptionException', () async {
      final salt = generateSalt();
      final key = await deriveKey('some passphrase', salt, 1000);

      final blob = await encrypt('important data', key);
      // Flip a byte in the ciphertext region (after the 12-byte nonce) so the
      // GCM auth tag no longer verifies.
      final tampered = Uint8List.fromList(blob);
      tampered[12] = tampered[12] ^ 0xFF;

      expect(
        () => decrypt(tampered, key),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test('decrypting a truncated blob throws BackupDecryptionException', () async {
      final salt = generateSalt();
      final key = await deriveKey('some passphrase', salt, 1000);
      final blob = await encrypt('important data', key);

      // Too short to even contain a nonce + GCM tag.
      final truncated = Uint8List.fromList(blob.sublist(0, 10));

      expect(
        () => decrypt(truncated, key),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test(
      'benchmark: deriveKey wall-clock time at the default iteration count',
      () async {
        final salt = generateSalt();
        final stopwatch = Stopwatch()..start();
        await deriveKey('benchmark passphrase', salt, kDefaultPbkdf2Iterations);
        stopwatch.stop();

        // Not a pass/fail assertion — this is a timing measurement surfaced
        // via printOnFailure/print so it shows up in `flutter test` output
        // for a human to judge whether it's acceptable backup-creation
        // latency on this dev machine (a real low-end Android device will
        // likely be slower).
        // ignore: avoid_print
        print(
          'PBKDF2 benchmark: $kDefaultPbkdf2Iterations iterations took '
          '${stopwatch.elapsedMilliseconds}ms on this machine.',
        );

        expect(stopwatch.elapsedMilliseconds, greaterThan(0));
      },
    );
  });
}

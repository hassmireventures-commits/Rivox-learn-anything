import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../../data/remote/backup/backup_crypto.dart' as crypto;

/// B36 — local, no-cloud `.rivox` file sharing (e.g. a teacher exporting a
/// learning path to share with students over WhatsApp/email/etc). Reuses
/// B13's existing AES-256-GCM + PBKDF2-HMAC-SHA256 helpers rather than adding
/// a second crypto dependency — this is genuinely just a different envelope
/// around the same primitives, not new cryptography.
///
/// Threat model, stated plainly (per this backlog item's own risk note): a
/// short numeric PIN is casual-sharing protection, not a security-hardened
/// credential store. Good enough for "don't let a stranger who intercepts
/// the file read it trivially," not good enough to call "secure."
///
/// File format: a single JSON object. The outer fields (format/version/
/// contentType/title/salt/iterations) are cleartext by design — they're
/// metadata the receiving app needs before it can even ask for the PIN
/// ("Alice shared 'Intro to Biology' with you"). Only `payload` is the
/// AES-GCM ciphertext (base64 of `[nonce][ciphertext][tag]`, i.e. exactly
/// what `backup_crypto.encrypt` returns).
const String kRivoxPackFormat = 'rivox-pack';
const int kRivoxPackVersion = 1;
const String kRivoxPackContentTypeLearningPath = 'learning_path';

/// Lower than B13's cloud-backup default (600k) — a share PIN is meant to
/// feel instant on both ends (export and every recipient's import), and the
/// casual-sharing threat model here doesn't call for the same cost as an
/// account passphrase. Still a real, deliberate PBKDF2 cost, not none.
const int kRivoxPackPbkdf2Iterations = 100000;

class RivoxPackFormatException implements Exception {
  const RivoxPackFormatException(this.message);
  final String message;
  @override
  String toString() => 'RivoxPackFormatException: $message';
}

/// The cleartext header of a `.rivox` file, readable before the PIN is known.
class RivoxPackHeader {
  const RivoxPackHeader({
    required this.contentType,
    required this.title,
  });
  final String contentType;
  final String title;
}

/// Decoded, decrypted content of a learning-path `.rivox` pack.
class RivoxLearningPathPack {
  const RivoxLearningPathPack({
    required this.title,
    required this.topics,
    required this.steps,
  });
  final String title;
  final List<String> topics;
  final List<Map<String, dynamic>> steps;
}

/// Generates a fresh random 6-digit share PIN, shown to the sharer to relay
/// to the recipient through a separate channel than the file itself (e.g.
/// say it out loud, or a separate text) — the file alone must never be
/// enough to decrypt it.
String generateSharePin() {
  final random = Random.secure();
  return (100000 + random.nextInt(900000)).toString();
}

/// Builds the encrypted `.rivox` file content (a JSON string) for a learning
/// path, encrypted under [pin].
Future<String> buildLearningPathPack({
  required String pin,
  required String title,
  required List<String> topics,
  required List<Map<String, dynamic>> steps,
}) async {
  final payloadJson = jsonEncode({'title': title, 'topics': topics, 'steps': steps});
  final salt = crypto.generateSalt();
  final key = await crypto.deriveKey(pin, salt, kRivoxPackPbkdf2Iterations);
  final encrypted = await crypto.encrypt(payloadJson, key);
  return jsonEncode({
    'format': kRivoxPackFormat,
    'version': kRivoxPackVersion,
    'contentType': kRivoxPackContentTypeLearningPath,
    'title': title,
    'salt': base64Encode(salt),
    'iterations': kRivoxPackPbkdf2Iterations,
    'payload': base64Encode(encrypted),
  });
}

/// Reads just the cleartext header of a `.rivox` file — enough to show
/// "Alice shared '{title}' with you" before asking for the PIN.
RivoxPackHeader readPackHeader(String fileContents) {
  final envelope = _decodeEnvelope(fileContents);
  final contentType = envelope['contentType'];
  final title = envelope['title'];
  if (contentType is! String || title is! String) {
    throw const RivoxPackFormatException('This file is missing required fields.');
  }
  return RivoxPackHeader(contentType: contentType, title: title);
}

/// Decrypts and validates a learning-path `.rivox` file under [pin]. Throws
/// [RivoxPackFormatException] for a malformed/wrong-content-type file, or
/// [crypto.BackupDecryptionException] for a wrong PIN / corrupted payload —
/// the same distinct exception B13's restore flow already uses, so callers
/// can show "wrong PIN or corrupted file" consistently with that pattern.
Future<RivoxLearningPathPack> decodeLearningPathPack(String fileContents, String pin) async {
  final envelope = _decodeEnvelope(fileContents);
  final contentType = envelope['contentType'];
  if (contentType != kRivoxPackContentTypeLearningPath) {
    throw RivoxPackFormatException('This file contains a "$contentType" pack, not a learning path.');
  }
  final saltB64 = envelope['salt'];
  final payloadB64 = envelope['payload'];
  final iterations = envelope['iterations'];
  if (saltB64 is! String || payloadB64 is! String || iterations is! int) {
    throw const RivoxPackFormatException('This file is missing required fields.');
  }
  final salt = base64Decode(saltB64);
  final key = await crypto.deriveKey(pin, salt, iterations);
  final decryptedJson = await crypto.decrypt(Uint8List.fromList(base64Decode(payloadB64)), key);

  final Map<String, dynamic> decoded;
  try {
    decoded = jsonDecode(decryptedJson) as Map<String, dynamic>;
  } catch (_) {
    throw const RivoxPackFormatException('Decrypted content is not valid.');
  }
  final title = decoded['title'];
  final topicsRaw = decoded['topics'];
  final stepsRaw = decoded['steps'];
  if (title is! String || topicsRaw is! List || stepsRaw is! List) {
    throw const RivoxPackFormatException('Decrypted content is missing required fields.');
  }
  return RivoxLearningPathPack(
    title: title,
    topics: topicsRaw.map((e) => e.toString()).toList(),
    steps: stepsRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(),
  );
}

Map<String, dynamic> _decodeEnvelope(String fileContents) {
  final Map<String, dynamic> envelope;
  try {
    envelope = jsonDecode(fileContents) as Map<String, dynamic>;
  } catch (_) {
    throw const RivoxPackFormatException('This does not look like a valid .rivox file.');
  }
  if (envelope['format'] != kRivoxPackFormat) {
    throw const RivoxPackFormatException('This does not look like a valid .rivox file.');
  }
  final version = envelope['version'];
  if (version is! int || version > kRivoxPackVersion) {
    throw const RivoxPackFormatException('This .rivox file was made by a newer, unsupported app version.');
  }
  return envelope;
}

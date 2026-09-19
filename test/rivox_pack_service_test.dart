import 'dart:convert';

import 'package:ai_quiz_app/core/services/rivox_pack_service.dart';
import 'package:ai_quiz_app/data/remote/backup/backup_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rivox_pack_service', () {
    test('build -> readPackHeader exposes title/contentType without the PIN', () async {
      final packJson = await buildLearningPathPack(
        pin: '123456',
        title: 'Intro to Biology',
        topics: ['Cells', 'Genetics'],
        steps: [
          {'title': 'Cells', 'summary': 'What is a cell', 'difficulty': 'easy', 'estimatedMinutes': 10},
        ],
      );

      final header = readPackHeader(packJson);
      expect(header.title, 'Intro to Biology');
      expect(header.contentType, kRivoxPackContentTypeLearningPath);
    });

    test('build -> decode round-trips title/topics/steps with the correct PIN', () async {
      final steps = [
        {'title': 'Cells', 'summary': 'What is a cell', 'difficulty': 'easy', 'estimatedMinutes': 10},
        {'title': 'Genetics', 'summary': 'DNA basics', 'difficulty': 'medium', 'estimatedMinutes': 15},
      ];
      final packJson = await buildLearningPathPack(
        pin: '654321',
        title: 'Intro to Biology',
        topics: ['Cells', 'Genetics'],
        steps: steps,
      );

      final pack = await decodeLearningPathPack(packJson, '654321');
      expect(pack.title, 'Intro to Biology');
      expect(pack.topics, ['Cells', 'Genetics']);
      expect(pack.steps, steps);
    });

    test('decoding with the wrong PIN throws BackupDecryptionException', () async {
      final packJson = await buildLearningPathPack(
        pin: '111111',
        title: 'Intro to Biology',
        topics: ['Cells'],
        steps: const [],
      );

      expect(
        () => decodeLearningPathPack(packJson, '222222'),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test('decoding a non-JSON file throws RivoxPackFormatException', () async {
      expect(
        () => decodeLearningPathPack('not json at all', '123456'),
        throwsA(isA<RivoxPackFormatException>()),
      );
    });

    test('decoding a file with the wrong format tag throws RivoxPackFormatException', () async {
      final fake = jsonEncode({'format': 'something-else', 'version': 1});
      expect(
        () => decodeLearningPathPack(fake, '123456'),
        throwsA(isA<RivoxPackFormatException>()),
      );
    });

    test('decoding a newer unsupported version throws RivoxPackFormatException', () async {
      final fake = jsonEncode({
        'format': kRivoxPackFormat,
        'version': kRivoxPackVersion + 1,
        'contentType': kRivoxPackContentTypeLearningPath,
        'title': 'x',
        'salt': base64Encode([1, 2, 3]),
        'iterations': 1000,
        'payload': base64Encode([1, 2, 3]),
      });
      expect(
        () => decodeLearningPathPack(fake, '123456'),
        throwsA(isA<RivoxPackFormatException>()),
      );
    });

    test('decoding a pack of a different content type throws RivoxPackFormatException', () async {
      final fake = jsonEncode({
        'format': kRivoxPackFormat,
        'version': kRivoxPackVersion,
        'contentType': 'quiz',
        'title': 'x',
        'salt': base64Encode([1, 2, 3]),
        'iterations': 1000,
        'payload': base64Encode([1, 2, 3]),
      });
      expect(
        () => decodeLearningPathPack(fake, '123456'),
        throwsA(isA<RivoxPackFormatException>()),
      );
    });

    test('generateSharePin returns a 6-digit numeric string', () {
      for (var i = 0; i < 20; i++) {
        final pin = generateSharePin();
        expect(pin.length, 6);
        expect(int.tryParse(pin), isNotNull);
      }
    });
  });
}

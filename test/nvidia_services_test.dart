import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_quiz_app/core/services/nvidia/cloud_ocr_service.dart';
import 'package:ai_quiz_app/core/services/nvidia/content_safety_service.dart';
import 'package:ai_quiz_app/core/services/nvidia/image_prep.dart';
import 'package:ai_quiz_app/core/services/nvidia/nvidia_ai_config.dart';
import 'package:ai_quiz_app/core/services/nvidia/nvidia_client.dart';
import 'package:ai_quiz_app/core/services/nvidia/vision_service.dart';
import 'package:ai_quiz_app/core/services/built_in_ai_config.dart';
import 'package:ai_quiz_app/data/vector/semantic_index.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Answers each request by Authorization header: maps key -> status.
class _KeyAdapter implements HttpClientAdapter {
  _KeyAdapter(this.statusByKey);
  final Map<String, int> statusByKey;
  final List<String> seenKeys = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final key = (options.headers['Authorization'] as String).replaceFirst('Bearer ', '');
    seenKeys.add(key);
    final status = statusByKey[key] ?? 500;
    return ResponseBody.fromString(
      jsonEncode(status == 200 ? {'ok': key} : {'detail': 'nope'}),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Deterministic fake embedder: 3-d vectors from keyword presence.
class _FakeEmbedder extends EmbeddingService {
  int calls = 0;
  int textsEmbedded = 0;

  @override
  Future<List<Float32List>> embed(List<String> texts, {required bool query}) async {
    calls++;
    textsEmbedded += texts.length;
    return [
      for (final t in texts)
        Float32List.fromList([
          t.contains('squat') || t.contains('low') ? 1.0 : 0.0,
          t.contains('bread') ? 1.0 : 0.0,
          0.1,
        ]),
    ];
  }
}

class _Vision extends VisionService {
  _Vision({this.delay = Duration.zero, this.fail = false});
  final Duration delay;
  final bool fail;

  @override
  Future<String> readImage(Uint8List bytes, {String? learnerNote}) async {
    await Future<void>.delayed(delay);
    if (fail) throw const VisionException('down');
    return 'vision text';
  }
}

class _Ocr extends CloudOcrService {
  _Ocr(this.text);
  final String text;

  @override
  Future<String> recognizeBytes(Uint8List bytes) async => text;
}

void main() {
  group('NvidiaClient key failover', () {
    test('429 and 401 move to the next key; success stops there', () async {
      final adapter = _KeyAdapter({'k1': 429, 'k2': 401, 'k3': 200, 'k4': 200});
      final dio = Dio()..httpClientAdapter = adapter;
      final client = NvidiaClient(dio: dio, keysOverride: ['k1', 'k2', 'k3', 'k4']);
      final res = await client.postJson('https://x/y', {}, capability: NvidiaCapability.ocr);
      expect(res['ok'], 'k3');
      expect(adapter.seenKeys, ['k1', 'k2', 'k3']);
    });

    test('a non-key error (500) is not retried on other keys', () async {
      final adapter = _KeyAdapter({'k1': 500, 'k2': 200});
      final client = NvidiaClient(dio: Dio()..httpClientAdapter = adapter, keysOverride: ['k1', 'k2']);
      await expectLater(
        client.postJson('https://x/y', {}, capability: NvidiaCapability.ocr),
        throwsA(isA<DioException>()),
      );
      expect(adapter.seenKeys, ['k1']);
    });

    test('all keys rate limited gives NvidiaUnavailableException', () async {
      final client = NvidiaClient(
        dio: Dio()..httpClientAdapter = _KeyAdapter({'k1': 429}),
        keysOverride: ['k1'],
      );
      await expectLater(
        client.postJson('https://x/y', {}, capability: NvidiaCapability.ocr),
        throwsA(isA<NvidiaUnavailableException>()),
      );
    });

    test('keysFor never repeats a key and never includes empties', () {
      final keys = NvidiaAiConfig.keysFor(NvidiaCapability.vision);
      expect(keys.toSet().length, keys.length);
      expect(keys.every((k) => k.isNotEmpty), isTrue);
      if (BuiltInAiConfig.hasApiKey) expect(keys, contains(BuiltInAiConfig.apiKey));
    });
  });

  group('Built-in fallback model', () {
    test('is not the retired nemotron-3-nano-30b-a3b', () {
      expect(BuiltInAiConfig.fallbackModel, isNot('nvidia/nemotron-3-nano-30b-a3b'));
      expect(BuiltInAiConfig.fallbackModel, 'nvidia/nemotron-3.5-lightning-30b-a3b');
    });
  });

  group('CloudOcrService', () {
    test('parses the Nemotron Parse tool call (live response shape)', () {
      final message = {
        'content': null,
        'tool_calls': [
          {
            'type': 'function',
            'function': {
              'name': 'markdown_no_bbox',
              'arguments': '[{"text": "Photosynthesis makes glucose"}, [{"text": "| a | b |"}]]',
            },
          },
        ],
      };
      expect(CloudOcrService.parseToolCallText(message), 'Photosynthesis makes glucose\n| a | b |');
    });

    test('weak on-device reads trigger the cloud fallback', () {
      expect(CloudOcrService.onDeviceLooksWeak(''), isTrue);
      expect(CloudOcrService.onDeviceLooksWeak('|| -- // 12 ;;'), isTrue);
      expect(
        CloudOcrService.onDeviceLooksWeak(
          'Photosynthesis converts light energy into chemical energy stored in glucose.',
        ),
        isFalse,
      );
      expect(
        CloudOcrService.onDeviceLooksWeak('One short line on page one only', pages: 3),
        isTrue,
      );
    });
  });

  group('ContentSafetyService.parseVerdict', () {
    test('reads the live text format', () {
      expect(ContentSafetyService.parseVerdict('User Safety: safe').safe, isTrue);
      final unsafe = ContentSafetyService.parseVerdict('User Safety: unsafe\nSafety Categories: Violence, Weapons');
      expect(unsafe.safe, isFalse);
      expect(unsafe.categories, ['Violence', 'Weapons']);
    });

    test('reads a JSON variant and fails open on empty', () {
      expect(ContentSafetyService.parseVerdict('{"User Safety": "unsafe"}').safe, isFalse);
      final empty = ContentSafetyService.parseVerdict('');
      expect(empty.safe, isTrue);
      expect(empty.checked, isFalse);
    });
  });

  group('ImagePrep', () {
    test('downscales a large photo to the max edge as JPEG', () {
      final big = img.Image(width: 3000, height: 1500);
      final png = Uint8List.fromList(img.encodePng(big));
      final out = ImagePrep.resizeToJpegSync(png)!;
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, ImagePrep.maxEdge);
      expect(decoded.height, 640);
    });

    test('non-images return null', () {
      expect(ImagePrep.resizeToJpegSync(Uint8List.fromList([1, 2, 3])), isNull);
    });
  });

  group('PhotoReader (self-healing photo questions)', () {
    test('uses the vision reading when it arrives in time', () async {
      final reader = PhotoReader(vision: _Vision(delay: Duration.zero), cloudOcr: _Ocr('ocr text'));
      final r = await reader.read(Uint8List(4));
      expect(r.full, isTrue);
      expect(r.text, 'vision text');
    });

    test('falls back to cloud OCR when vision is too slow', () async {
      final reader = PhotoReader(
        vision: _Vision(delay: const Duration(seconds: 5)),
        cloudOcr: _Ocr('Q1. Solve 2x + 3 = 7'),
        visionBudget: const Duration(milliseconds: 50),
      );
      final r = await reader.read(Uint8List(4));
      expect(r.full, isFalse);
      expect(r.text, contains('Solve 2x + 3 = 7'));
    });

    test('then on-device OCR, then a clear error', () async {
      final onDevice = PhotoReader(
        vision: _Vision(fail: true),
        cloudOcr: _Ocr(''),
        onDeviceOcr: (_) async => 'device text',
      );
      expect((await onDevice.read(Uint8List(4), imagePath: 'x.jpg')).text, contains('device text'));

      final nothing = PhotoReader(vision: _Vision(fail: true), cloudOcr: _Ocr(''));
      await expectLater(nothing.read(Uint8List(4)), throwsA(isA<VisionException>()));
    });
  });

  group('SemanticIndex', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('sem_idx_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('scores by meaning and caches chunk vectors on disk', () async {
      final embedder = _FakeEmbedder();
      final index = SemanticIndex(embedder: embedder, cacheDir: () async => dir);
      const candidates = [
        SemanticCandidate(chunkId: 's:0', text: 'How low should a squat go'),
        SemanticCandidate(chunkId: 's:1', text: 'Bake bread at 220C'),
      ];
      final scores = await index.score('squat depth', candidates);
      expect(scores['s:0']!, greaterThan(scores['s:1']!));
      expect(dir.listSync().whereType<File>().length, 2);

      // A fresh index reuses the disk cache: only the query is embedded.
      final embedder2 = _FakeEmbedder();
      final again = SemanticIndex(embedder: embedder2, cacheDir: () async => dir);
      await again.score('squat depth', candidates);
      expect(embedder2.textsEmbedded, 1);
    });

    test('cache key changes when the chunk text changes', () {
      expect(SemanticIndex.cacheKey('a:1', 'old'), isNot(SemanticIndex.cacheKey('a:1', 'new')));
      expect(SemanticIndex.cacheKey('a:1', 'same'), SemanticIndex.cacheKey('a:1', 'same'));
    });
  });
}

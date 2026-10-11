import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'image_prep.dart';
import 'nvidia_ai_config.dart';
import 'nvidia_client.dart';

/// Cloud OCR with NVIDIA Nemotron Parse (document to Markdown: handwriting,
/// tables, formulas). Used only as a self-healing fallback after on-device
/// ML Kit OCR, which stays the default so most scans never leave the phone.
class CloudOcrService {
  CloudOcrService({NvidiaClient? client}) : _client = client ?? NvidiaClient();

  final NvidiaClient _client;

  static bool get isAvailable => NvidiaAiConfig.isAvailable(NvidiaCapability.ocr);

  /// Below this many letters per page, an on-device result is treated as a
  /// failed read (blank, blurry, handwriting, or a table ML Kit scrambled).
  static const int minLettersPerPage = 40;

  /// True when the on-device text looks like a failed read: too few letters
  /// for the number of pages, or mostly symbols and noise.
  static bool onDeviceLooksWeak(String text, {int pages = 1}) {
    final letters = RegExp(r'[A-Za-zÀ-ɏऀ-ॿ]').allMatches(text).length;
    if (letters < minLettersPerPage * (pages < 1 ? 1 : pages)) return true;
    final visible = text.replaceAll(RegExp(r'\s'), '').length;
    return visible > 0 && letters / visible < 0.5;
  }

  /// Reads each page with Nemotron Parse. Returns the joined text, or an
  /// empty string when nothing could be read. Never throws.
  Future<String> recognizePages(List<String> imagePaths) async {
    final pages = <String>[];
    for (final path in imagePaths) {
      try {
        final text = await _recognize(await File(path).readAsBytes());
        if (text.trim().isNotEmpty) pages.add(text.trim());
      } catch (_) {
        // One unreadable page must not lose the others.
      }
    }
    return pages.join('\n\n');
  }

  /// Reads one in-memory image. Returns '' on any failure. Never throws.
  Future<String> recognizeBytes(Uint8List bytes) async {
    try {
      return (await _recognize(bytes)).trim();
    } catch (_) {
      return '';
    }
  }

  Future<String> _recognize(Uint8List bytes) async {
    final dataUrl = await ImagePrep.toJpegDataUrl(bytes);
    if (dataUrl == null) return '';
    final message = await _client.chat(
      model: NvidiaAiConfig.ocrModel,
      capability: NvidiaCapability.ocr,
      maxTokens: 3500,
      temperature: 0,
      timeout: const Duration(seconds: 60),
      messages: [
        {'role': 'user', 'content': '<img src="$dataUrl" />'},
      ],
      extra: {
        'tools': [
          {
            'type': 'function',
            'function': {'name': 'markdown_no_bbox'},
          },
        ],
        'tool_choice': {
          'type': 'function',
          'function': {'name': 'markdown_no_bbox'},
        },
      },
    );
    return parseToolCallText(message);
  }

  /// Nemotron Parse answers with a tool call whose `arguments` is a JSON
  /// list of `{"text": ...}` blocks (sometimes nested one level). Pure.
  @visibleForTesting
  static String parseToolCallText(Map<String, dynamic> message) {
    final calls = message['tool_calls'];
    if (calls is! List || calls.isEmpty) {
      return message['content']?.toString() ?? '';
    }
    final out = <String>[];
    for (final call in calls.whereType<Map>()) {
      final fn = call['function'];
      if (fn is! Map) continue;
      final rawArgs = fn['arguments'];
      Object? decoded;
      try {
        decoded = rawArgs is String ? jsonDecode(rawArgs) : rawArgs;
      } catch (_) {
        decoded = rawArgs;
      }
      _collectText(decoded, out);
    }
    return out.join('\n').trim();
  }

  static void _collectText(Object? node, List<String> out) {
    if (node is String) {
      if (node.trim().isNotEmpty) out.add(node.trim());
    } else if (node is List) {
      for (final n in node) {
        _collectText(n, out);
      }
    } else if (node is Map) {
      final t = node['text'];
      if (t is String) {
        if (t.trim().isNotEmpty) out.add(t.trim());
      } else {
        for (final v in node.values) {
          _collectText(v, out);
        }
      }
    }
  }
}

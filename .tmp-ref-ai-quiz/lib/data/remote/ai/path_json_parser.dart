import 'dart:convert';

import '../../../core/error/app_exception.dart';
import 'resource_link_validator.dart';

class PathJsonParser {
  const PathJsonParser._();

  static GeneratedLearningPath parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length > 120000) {
      throw const InvalidJsonException('Learning path response too large.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(_extractJson(trimmed));
    } catch (_) {
      throw const InvalidJsonException('AI returned invalid learning path JSON.');
    }

    if (decoded is! Map) {
      throw const InvalidJsonException('Learning path must be a JSON object.');
    }

    try {
      return ResourceLinkValidator.validatePath(Map<String, dynamic>.from(decoded));
    } on FormatException catch (e) {
      throw InvalidJsonException(e.message);
    }
  }

  static String _extractJson(String input) {
    if (input.startsWith('{')) return input;
    final start = input.indexOf('{');
    final end = input.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return input.substring(start, end + 1);
    }
    return input;
  }
}

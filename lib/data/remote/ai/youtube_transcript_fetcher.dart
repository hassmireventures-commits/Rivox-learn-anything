import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

/// Best-effort YouTube caption/transcript fetch for module summarizer.
///
/// Uses the public timedtext endpoint. Fails soft (empty string) when captions
/// are disabled, geo-blocked, or the network fails.
class YoutubeTranscriptFetcher {
  YoutubeTranscriptFetcher._();

  static Future<String> fetchTranscript(String videoId, {Duration timeout = const Duration(seconds: 12)}) async {
    final id = videoId.trim();
    if (id.length != 11) return '';
    final dio = DioClient.create(timeout: timeout);
    try {
      // Prefer English auto or manual tracks; fall back to any listed track.
      final list = await dio.get<String>(
        'https://www.youtube.com/api/timedtext',
        queryParameters: {'type': 'list', 'v': id},
        options: Options(responseType: ResponseType.plain, validateStatus: (s) => s != null && s < 500),
      );
      if (list.statusCode != 200 || (list.data ?? '').isEmpty) return '';
      final xml = list.data!;
      final lang = _pickLang(xml) ?? 'en';
      final track = await dio.get<String>(
        'https://www.youtube.com/api/timedtext',
        queryParameters: {'lang': lang, 'v': id},
        options: Options(responseType: ResponseType.plain, validateStatus: (s) => s != null && s < 500),
      );
      if (track.statusCode != 200 || (track.data ?? '').isEmpty) {
        final auto = await dio.get<String>(
          'https://www.youtube.com/api/timedtext',
          queryParameters: {'lang': lang, 'v': id, 'kind': 'asr'},
          options: Options(responseType: ResponseType.plain, validateStatus: (s) => s != null && s < 500),
        );
        if (auto.statusCode != 200 || (auto.data ?? '').isEmpty) return '';
        return _stripTimedText(auto.data!);
      }
      return _stripTimedText(track.data!);
    } catch (_) {
      return '';
    }
  }

  static String? _pickLang(String listXml) {
    final langs = RegExp(r'lang_code="([^"]+)"').allMatches(listXml).map((m) => m.group(1)!).toList();
    if (langs.isEmpty) return null;
    if (langs.contains('en')) return 'en';
    return langs.first;
  }

  static String _stripTimedText(String xml) {
    final texts = RegExp(r'<text[^>]*>([\s\S]*?)</text>', caseSensitive: false)
        .allMatches(xml)
        .map((m) => _decodeXml(m.group(1) ?? ''))
        .where((s) => s.trim().isNotEmpty);
    final joined = texts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (joined.length <= 12000) return joined;
    return '${joined.substring(0, 12000)}…';
  }

  static String _decodeXml(String input) => input
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'<[^>]+>'), ' ');
}

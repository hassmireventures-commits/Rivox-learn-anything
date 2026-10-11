import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/remote/ai/resource_link_validator.dart';
import '../network/dio_client.dart';

/// One playable search result.
class YoutubeVideoHit {
  const YoutubeVideoHit({required this.videoId, required this.title, this.channel = ''});

  final String videoId;
  final String title;
  final String channel;
}

/// Finds real, embeddable YouTube videos for a topic so they can play in the
/// in-app player instead of handing the learner off to the YouTube app.
///
/// Source order:
/// 1. YouTube Data API v3 `search.list` when `YOUTUBE_API_KEY` is supplied via
///    `--dart-define` (the officially supported route; 100 quota units per
///    search, 10,000 free units a day).
/// 2. Otherwise the public results page, reading the video ids YouTube embeds
///    in it. Works without a key but can break whenever YouTube changes that
///    page, and automated reads of it sit outside YouTube's API terms, so a
///    key should be configured for production.
///
/// Every candidate then passes [ResourceLinkValidator.acceptYouTubeForTopic]
/// (oEmbed embeddable + topic relevance + reject list) before it is returned.
class YoutubeSearchService {
  YoutubeSearchService({Dio? dio}) : _dio = dio ?? DioClient.create(timeout: const Duration(seconds: 10));

  static const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  final Dio _dio;

  static final Map<String, List<YoutubeVideoHit>> _cache = {};

  Future<List<YoutubeVideoHit>> search(String topic, {int limit = 5}) async {
    final query = topic.trim();
    if (query.isEmpty) return const [];
    final cacheKey = '${query.toLowerCase()}|$limit';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    var candidates = <YoutubeVideoHit>[];
    try {
      candidates = _apiKey.isNotEmpty ? await _searchApi(query) : await _searchPage(query);
    } catch (_) {
      candidates = const [];
    }

    final accepted = <YoutubeVideoHit>[];
    for (final hit in candidates) {
      final ok = await ResourceLinkValidator.acceptYouTubeForTopic(hit.videoId, query);
      if (ok != null) accepted.add(hit);
      if (accepted.length >= limit) break;
    }
    if (accepted.isNotEmpty) _cache[cacheKey] = accepted;
    return accepted;
  }

  Future<List<YoutubeVideoHit>> _searchApi(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://www.googleapis.com/youtube/v3/search',
      queryParameters: {
        'part': 'snippet',
        'type': 'video',
        'videoEmbeddable': 'true',
        'safeSearch': 'strict',
        'relevanceLanguage': 'en',
        'maxResults': 10,
        'q': query,
        'key': _apiKey,
      },
    );
    final items = res.data?['items'];
    if (items is! List) return const [];
    return [
      for (final item in items.whereType<Map>())
        if (item['id'] is Map && (item['id'] as Map)['videoId'] is String)
          YoutubeVideoHit(
            videoId: (item['id'] as Map)['videoId'] as String,
            title: _unescape((item['snippet'] as Map?)?['title']?.toString() ?? ''),
            channel: (item['snippet'] as Map?)?['channelTitle']?.toString() ?? '',
          ),
    ];
  }

  Future<List<YoutubeVideoHit>> _searchPage(String query) async {
    final res = await _dio.get<String>(
      'https://www.youtube.com/results',
      queryParameters: {'search_query': '$query tutorial', 'hl': 'en', 'gl': 'US'},
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'Accept-Language': 'en-US,en;q=0.9',
          // Skips the EU consent interstitial, which has no results in it.
          'Cookie': 'CONSENT=YES+1; SOCS=CAI',
        },
      ),
    );
    return parseResultsPage(res.data ?? '');
  }

  /// Pulls `videoRenderer` entries (id + title) out of the results page's
  /// embedded JSON, in page order, de-duplicated. Shorts, ads, and channel
  /// cards use other renderer types and are skipped. Pure, unit-tested.
  @visibleForTesting
  static List<YoutubeVideoHit> parseResultsPage(String html) {
    final hits = <YoutubeVideoHit>[];
    final seen = <String>{};
    final renderer = RegExp(
      r'"videoRenderer":\{"videoId":"([A-Za-z0-9_-]{11})"(.{0,4000}?)"title":\{"runs":\[\{"text":"((?:[^"\\]|\\.)*)"',
      dotAll: true,
    );
    for (final m in renderer.allMatches(html)) {
      final id = m.group(1)!;
      if (!seen.add(id)) continue;
      hits.add(YoutubeVideoHit(videoId: id, title: _unescape(_decodeJsonString(m.group(3)!))));
      if (hits.length >= 12) break;
    }
    return hits;
  }

  static String _decodeJsonString(String raw) {
    try {
      return jsonDecode('"$raw"') as String;
    } catch (_) {
      return raw;
    }
  }

  static String _unescape(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
}

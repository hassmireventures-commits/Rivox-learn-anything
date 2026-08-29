import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/official_learning_domains.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/daily_content_fallbacks.dart';
import '../../../core/services/youtube_reject_store.dart';

class ResourceLink {
  const ResourceLink({
    required this.type,
    required this.title,
    required this.url,
    required this.domain,
  });

  final String type;
  final String title;
  final String url;
  final String domain;

  factory ResourceLink.fromJson(Map<String, dynamic> json) {
    return ResourceLink(
      type: json['type']?.toString() ?? 'doc',
      title: json['title']?.toString() ?? 'Resource',
      url: json['url']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'url': url,
        'domain': domain,
      };
}

class PathStep {
  const PathStep({
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.resources,
    this.youtubeVideoId,
  });

  final String title;
  final String summary;
  final String difficulty;
  final int estimatedMinutes;
  final List<ResourceLink> resources;
  final String? youtubeVideoId;

  factory PathStep.fromJson(Map<String, dynamic> json) {
    final resourcesRaw = json['resources'];
    final resources = <ResourceLink>[];
    if (resourcesRaw is List) {
      for (final item in resourcesRaw) {
        if (item is Map) {
          resources.add(ResourceLink.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return PathStep(
      title: json['title']?.toString() ?? 'Module',
      summary: json['summary']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 15,
      resources: resources,
      youtubeVideoId: json['youtubeVideoId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'difficulty': difficulty,
        'estimatedMinutes': estimatedMinutes,
        'resources': resources.map((e) => e.toJson()).toList(),
        'youtubeVideoId': youtubeVideoId,
      };
}

class GeneratedLearningPath {
  const GeneratedLearningPath({
    required this.title,
    required this.steps,
  });

  final String title;
  final List<PathStep> steps;
}

class ResourceLinkValidator {
  const ResourceLinkValidator._();

  static String? extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      return _isValidYouTubeId(id) ? id : null;
    }
    if (uri.host.contains('youtube.com') || uri.host.contains('youtube-nocookie.com')) {
      final id = uri.queryParameters['v'];
      return _isValidYouTubeId(id) ? id : null;
    }
    return null;
  }

  static bool _isValidYouTubeId(String? id) {
    if (id == null || id.length != 11) return false;
    return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id);
  }

  static Future<({bool ok, String title, String authorName})> fetchYouTubeOEmbed(
    String videoId,
  ) async {
    if (!_isValidYouTubeId(videoId)) {
      return (ok: false, title: '', authorName: '');
    }
    final dio = DioClient.create(timeout: const Duration(seconds: 8));
    try {
      final response = await dio.get<String>(
        'https://www.youtube.com/oembed',
        queryParameters: {
          'url': 'https://www.youtube.com/watch?v=$videoId',
          'format': 'json',
        },
        options: Options(responseType: ResponseType.plain, validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode != 200 || (response.data ?? '').isEmpty) {
        return (ok: false, title: '', authorName: '');
      }
      try {
        final map = jsonDecode(response.data!);
        if (map is Map) {
          return (
            ok: true,
            title: map['title']?.toString() ?? '',
            authorName: map['author_name']?.toString() ?? '',
          );
        }
      } catch (_) {
        return (ok: true, title: '', authorName: '');
      }
      return (ok: true, title: '', authorName: '');
    } catch (_) {
      return (ok: false, title: '', authorName: '');
    }
  }

  static Future<bool> isYouTubeEmbeddable(String videoId) async {
    final r = await fetchYouTubeOEmbed(videoId);
    return r.ok;
  }

  /// Token overlap between module title and oEmbed title (rejects music/memes).
  static bool isYouTubeTitleRelevant(String moduleTitle, String oEmbedTitle) {
    final mod = _tokens(moduleTitle);
    final vid = _tokens(oEmbedTitle);
    if (mod.isEmpty || vid.isEmpty) return false;
    // Hard reject music / entertainment signals.
    const bad = {
      'official', 'music', 'video', 'lyrics', 'vevo', 'song', 'album', 'remix',
      'trailer', 'parody', 'meme', 'comedy', 'never', 'gonna', 'give', 'gangnam',
      'despacito', 'bohemian',
    };
    final vidLower = oEmbedTitle.toLowerCase();
    if (bad.where((b) => b.length >= 5).any((b) => vidLower.contains(b)) &&
        mod.intersection(vid).isEmpty) {
      return false;
    }
    final inter = mod.intersection(vid).length;
    if (inter >= 1) return true;
    // Shared stem (len >= 4)
    for (final m in mod.where((t) => t.length >= 4)) {
      for (final v in vid) {
        if (v.startsWith(m) || m.startsWith(v)) return true;
      }
    }
    return false;
  }

  /// Daily pack: reject coding bootcamps for business/career topics; require title fit.
  static bool isDailyVideoOnTopic(String topic, String oEmbedTitle, String? authorName) {
    if (_topicIsCareerOrBusiness(topic) && _videoLooksLikeCodingBootcamp(oEmbedTitle)) {
      return false;
    }
    if (isYouTubeTitleRelevant(topic, oEmbedTitle)) return true;
    final author = (authorName ?? '').toLowerCase();
    if (_topicIsCareerOrBusiness(topic)) {
      const bizAuthors = {
        'product school', 'harvard business', 'hbr', 'mit sloan', 'ted-ed', 'ted ed',
        'google careers', 'mckinsey', 'bain', 'bcg',
      };
      if (bizAuthors.any(author.contains)) return true;
    }
    return false;
  }

  static bool _topicIsCareerOrBusiness(String topic) {
    final lower = topic.toLowerCase();
    const keys = [
      'product', 'manager', 'management', 'business', 'marketing', 'career',
      'leadership', 'startup', 'strategy', 'consult', 'mba', 'pm ',
    ];
    return keys.any(lower.contains);
  }

  static bool _videoLooksLikeCodingBootcamp(String title) {
    final lower = title.toLowerCase();
    const coding = [
      'python', 'javascript', 'java ', ' c++', ' c#', 'full course', 'hour course',
      'programming', 'coding bootcamp', 'learn to code', 'learn python', 'learn java',
      'web development', 'data structures',
    ];
    return coding.any(lower.contains);
  }

  static Set<String> _tokens(String input) {
    const stop = {
      'a', 'an', 'the', 'and', 'or', 'of', 'to', 'for', 'in', 'on', 'with',
      'intro', 'introduction', 'basics', 'foundation', 'foundations', 'module',
      'learn', 'learning', 'tutorial', 'course', 'part', 'how', 'what', 'your',
    };
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s+]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !stop.contains(w))
        .toSet();
  }

  static Future<String?> acceptYouTubeForTopic(String? videoId, String topic) =>
      _acceptYouTubeId(videoId, topic, dailyPack: false);

  static Future<String?> _acceptYouTubeId(
    String? videoId,
    String moduleTitle, {
    bool dailyPack = false,
  }) async {
    if (videoId == null || videoId.isEmpty) return null;
    if (!_isValidYouTubeId(videoId)) return null;
    if (await YoutubeRejectStore.isRejected(videoId)) return null;
    final oembed = await fetchYouTubeOEmbed(videoId);
    if (!oembed.ok) {
      await YoutubeRejectStore.reject(videoId, reason: 'not_embeddable');
      return null;
    }
    final trusted = OfficialLearningDomains.isTrustedYouTubeAuthor(oembed.authorName);
    if (dailyPack) {
      if (!isDailyVideoOnTopic(moduleTitle, oembed.title, oembed.authorName)) {
        await YoutubeRejectStore.reject(videoId, reason: 'irrelevant_title');
        return null;
      }
      return videoId;
    }
    if (trusted && oembed.ok) {
      final vidLower = oembed.title.toLowerCase();
      const music = {'lyrics', 'vevo', 'official music', 'music video'};
      if (!music.any(vidLower.contains)) return videoId;
    }
    final relevant = oembed.title.isEmpty ||
        isYouTubeTitleRelevant(moduleTitle, oembed.title);
    // Trusted educational channels: allow when oEmbed succeeds even if token
    // overlap is weak (still reject hard music/meme titles via isYouTubeTitleRelevant).
    if (!relevant && !trusted) {
      await YoutubeRejectStore.reject(videoId, reason: 'irrelevant_title');
      return null;
    }
    if (!relevant && trusted) {
      // Still block obvious music/meme on trusted channels.
      final vidLower = oembed.title.toLowerCase();
      const music = {'lyrics', 'vevo', 'official music', 'music video'};
      if (music.any(vidLower.contains)) {
        await YoutubeRejectStore.reject(videoId, reason: 'irrelevant_title');
        return null;
      }
    }
    return videoId;
  }

  /// Live reachability check for allowlisted article/doc URLs (daily pack).
  static Future<bool> isHttpsResourceReachable(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
    if (!OfficialLearningDomains.isAllowedDoc(uri.host)) return false;
    final host = uri.host.toLowerCase();
    final preferGet = host.contains('wikipedia.org') ||
        host.contains('britannica.com') ||
        host.contains('khanacademy.org') ||
        host.contains('wikihow.com') ||
        host.contains('howtogeek.com');
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        followRedirects: true,
        maxRedirects: 5,
        headers: const {
          'User-Agent':
              'LearnAnything/1.0 (Android; educational link validator)',
          'Accept': 'text/html,application/xhtml+xml',
        },
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    try {
      if (!preferGet) {
        final head = await dio.headUri(uri);
        final headCode = head.statusCode ?? 0;
        if (headCode >= 200 && headCode < 400) return true;
      }
      final get = await dio.getUri(
        uri,
        options: Options(responseType: ResponseType.plain),
      );
      final getCode = get.statusCode ?? 0;
      return getCode >= 200 && getCode < 400;
    } catch (_) {
      return false;
    }
  }

  /// Sanitize + live-validate a single daily pick. Never returns an unvalidated URL.
  static Future<({bool ok, String url, String? youtubeVideoId, String title})> acceptDailyResource({
    required String type,
    required String url,
    required String topic,
    String? title,
    bool trustedFallback = false,
  }) async {
    final linkType = type == 'video' ? 'video' : 'doc';
    final sanitized = sanitizeLink({
      'type': linkType,
      'title': (title != null && title.trim().isNotEmpty) ? title.trim() : topic,
      'url': url,
    });
    if (sanitized == null) {
      return (ok: false, url: '', youtubeVideoId: null, title: '');
    }

    if (linkType == 'video') {
      final id = extractYouTubeId(sanitized.url);
      if (trustedFallback) {
        if (id == null || !_isValidYouTubeId(id)) {
          return (ok: false, url: '', youtubeVideoId: null, title: '');
        }
        final oembed = await fetchYouTubeOEmbed(id);
        if (!oembed.ok) {
          return (ok: false, url: '', youtubeVideoId: null, title: '');
        }
        return (
          ok: true,
          url: 'https://www.youtube.com/watch?v=$id',
          youtubeVideoId: id,
          title: sanitized.title,
        );
      }
      final accepted = await _acceptYouTubeId(id, topic, dailyPack: true);
      if (accepted == null) {
        return (ok: false, url: '', youtubeVideoId: null, title: '');
      }
      return (
        ok: true,
        url: 'https://www.youtube.com/watch?v=$accepted',
        youtubeVideoId: accepted,
        title: sanitized.title,
      );
    }

    final reachable = await isHttpsResourceReachable(sanitized.url);
    if (!reachable) {
      return (ok: false, url: '', youtubeVideoId: null, title: '');
    }
    return (
      ok: true,
      url: sanitized.url,
      youtubeVideoId: null,
      title: sanitized.title,
    );
  }

  /// Verifies YouTube embeds via oEmbed + title relevance; clears bad IDs.
  /// Also drops unreachable / homepage / off-topic article URLs.
  ///
  /// Steps are always kept. Unavailable / irrelevant videos fall back to search.
  static Future<GeneratedLearningPath> verifyYouTubeEmbeds(
    GeneratedLearningPath path, {
    String pathGoal = '',
  }) async {
    final goalContext = pathGoal.trim().isNotEmpty ? pathGoal.trim() : path.title;
    final steps = <PathStep>[];
    final usedArticleUrls = <String>{};
    for (final step in path.steps) {
      String? youtubeId = await _acceptYouTubeId(step.youtubeVideoId, step.title);

      final resources = <ResourceLink>[];
      for (final link in step.resources) {
        if (link.type == 'video') {
          final id = extractYouTubeId(link.url);
          if (id == null) continue;
          if (youtubeId == null) {
            youtubeId = await _acceptYouTubeId(id, step.title);
            if (youtubeId == null) continue;
          } else if (await YoutubeRejectStore.isRejected(id)) {
            continue;
          }
          resources.add(link);
          continue;
        }
        if (usedArticleUrls.contains(link.url)) continue;
        final accepted = await _acceptArticleLink(link);
        if (accepted != null) resources.add(accepted);
      }
      resources.sort((a, b) {
        final byType = (a.type == 'video' ? 0 : 1).compareTo(b.type == 'video' ? 0 : 1);
        if (byType != 0) return byType;
        return _articleRelevanceScore(step.title, b)
            .compareTo(_articleRelevanceScore(step.title, a));
      });

      final hasDoc = resources.any((r) => r.type != 'video');
      if (!hasDoc) {
        final fallbackDocs = await _fallbackDocsForModule(
          step.title,
          excludeUrls: usedArticleUrls,
          pathContext: goalContext,
          pathTitle: path.title,
          limit: 2,
        );
        resources.addAll(fallbackDocs);
      }
      youtubeId ??= await _fallbackYouTubeForModule(step.title);

      for (final r in resources) {
        if (r.type != 'video') usedArticleUrls.add(r.url);
      }

      steps.add(PathStep(
        title: step.title,
        summary: step.summary,
        difficulty: step.difficulty,
        estimatedMinutes: step.estimatedMinutes,
        resources: resources,
        youtubeVideoId: youtubeId,
      ));
    }
    if (steps.isEmpty) {
      throw FormatException('No valid modules were generated');
    }
    return GeneratedLearningPath(title: path.title, steps: steps);
  }

  static Future<List<ResourceLink>> _fallbackDocsForModule(
    String moduleTitle, {
    Set<String> excludeUrls = const {},
    String pathContext = '',
    String pathTitle = '',
    int limit = 2,
  }) async {
    final items = await DailyContentFallbacks.pickForModuleRanked(
      moduleTitle: moduleTitle,
      excludeUrls: excludeUrls,
      pathContext: pathContext,
      pathTitle: pathTitle,
      limit: limit,
    );
    return [
      for (final item in items)
        ResourceLink(
          type: 'doc',
          title: item.title,
          url: item.url,
          domain: Uri.tryParse(item.url)?.host ?? '',
        ),
    ];
  }

  static Future<String?> _fallbackYouTubeForModule(String moduleTitle) async {
    final item = await DailyContentFallbacks.pick(
      type: 'video',
      topic: moduleTitle,
      dateKey: 'path',
    );
    if (item?.youtubeVideoId == null || item!.youtubeVideoId!.isEmpty) return null;
    return _acceptYouTubeId(item.youtubeVideoId, moduleTitle);
  }

  static bool isHomepageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return true;
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    if (path.isEmpty || path == '/' || path == '/en' || path == '/index.html') {
      return true;
    }
    // Site roots that are never a specific article.
    const roots = {'/docs', '/documentation', '/learn', '/en-us'};
    return roots.contains(path.toLowerCase());
  }

  /// python.org marketing/root host - docs live on docs.python.org.
  static bool _isKnownBadArticleHost(String host) {
    final h = host.toLowerCase();
    return h == 'python.org' || h == 'www.python.org';
  }

  /// True when the path looks like a real article, not a section index.
  static bool _hasRealArticleSlug(Uri uri) {
    const shallow = {'docs', 'documentation', 'learn', 'en', 'en-us', 'index.html'};
    final meaningful = uri.pathSegments.where((s) {
      if (s.isEmpty) return false;
      final lower = s.toLowerCase();
      return lower.length >= 2 && !shallow.contains(lower);
    });
    return meaningful.isNotEmpty;
  }

  static int _articleRelevanceScore(String moduleTitle, ResourceLink link) {
    final uri = Uri.tryParse(link.url);
    final haystack = '${link.title} ${uri?.path ?? ''} ${uri?.host ?? ''}';
    return isYouTubeTitleRelevant(moduleTitle, haystack) ? 1 : 0;
  }

  static Future<ResourceLink?> _acceptArticleLink(ResourceLink link) async {
    if (isHomepageUrl(link.url)) return null;
    final uri = Uri.tryParse(link.url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    // Keep the explicit python.org homepage / root reject (AI often emits it).
    if (_isKnownBadArticleHost(host) && !_hasRealArticleSlug(uri)) return null;
    if (_isKnownBadArticleHost(host) && isHomepageUrl(link.url)) return null;
    final reachable = await isHttpsResourceReachable(link.url);
    if (!reachable) return null;
    // Relevance is a preference, not a hard drop: a reachable allowlisted
    // article that is not a homepage / known-bad host is kept even when
    // title/URL token overlap is weak. Official domains with a real slug
    // are also kept when overlap fails.
    return link;
  }

  /// Best-effort article body for module notes when captions are missing.
  static Future<String> fetchArticleText(String url, {int maxChars = 4000}) async {
    if (!await isHttpsResourceReachable(url)) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          followRedirects: true,
          maxRedirects: 5,
          responseType: ResponseType.plain,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      final res = await dio.getUri(uri);
      final html = res.data?.toString() ?? '';
      if (html.trim().length < 200) return '';
      final text = html
          .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), ' ')
          .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), ' ')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text.length < 120) return '';
      return text.length > maxChars ? text.substring(0, maxChars) : text;
    } catch (_) {
      return '';
    }
  }

  static ResourceLink? sanitizeLink(Map<String, dynamic> raw) {
    final url = raw['url']?.toString().trim() ?? '';
    if (!url.startsWith('https://')) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;

    final type = raw['type']?.toString() ?? 'doc';
      if (type == 'video') {
        if (!OfficialLearningDomains.isAllowedVideo(uri.host)) return null;
        final id = extractYouTubeId(url);
        if (id == null) return null;
    } else {
      if (!OfficialLearningDomains.isAllowedDoc(uri.host)) return null;
    }

    return ResourceLink(
      type: type,
      title: raw['title']?.toString() ?? uri.host,
      url: url,
      domain: uri.host,
    );
  }

  static GeneratedLearningPath validatePath(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? 'Learning path';
    final stepsRaw = json['steps'];
    if (stepsRaw is! List) {
      throw FormatException('Missing steps array');
    }

    final steps = <PathStep>[];
    for (final item in stepsRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final resourcesRaw = map['resources'];
      final validatedResources = <ResourceLink>[];
      String? youtubeId = map['youtubeVideoId']?.toString();

      if (resourcesRaw is List) {
        for (final r in resourcesRaw) {
          if (r is! Map) continue;
          final link = sanitizeLink(Map<String, dynamic>.from(r));
          if (link != null) {
            validatedResources.add(link);
            if (link.type == 'video' && youtubeId == null) {
              youtubeId = extractYouTubeId(link.url);
            }
          }
        }
      }

      final youtubeUrl = map['youtubeUrl']?.toString();
      if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
        final link = sanitizeLink({'type': 'video', 'title': 'Video', 'url': youtubeUrl});
        if (link != null) {
          validatedResources.add(link);
          youtubeId ??= extractYouTubeId(link.url);
        }
      }

      // Keep the step even when no resources/video passed validation so the
      // module is never silently dropped.  The UI shows a search fallback
      // when youtubeId is null.

      steps.add(PathStep(
        title: map['title']?.toString() ?? 'Module ${steps.length + 1}',
        summary: map['summary']?.toString() ?? '',
        difficulty: map['difficulty']?.toString() ?? 'medium',
        estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 15,
        resources: validatedResources,
        youtubeVideoId: youtubeId,
      ));
    }

    if (steps.isEmpty) {
      throw FormatException('No valid modules with official resources');
    }

    return GeneratedLearningPath(title: title, steps: steps.take(8).toList());
  }
}

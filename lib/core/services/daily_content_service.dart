import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/remote/ai/input_kind_prompt.dart';
import '../../data/remote/ai/resource_link_validator.dart';
import '../error/app_exception.dart';
import 'agentic/goal_content_validation_agent.dart';
import 'daily_content_fallbacks.dart';
import 'goal_topic_resolver.dart';
import 'language_exam_resources.dart';
import 'learner_goal_guard.dart';
import 'skill_articles.dart';
import 'llm_manager.dart';
import 'open_knowledge/open_knowledge_service.dart';
import 'topic_goal_relevance.dart';
import 'video_chapter.dart';

class DailyContentItem {
  const DailyContentItem({
    required this.dateKey,
    required this.type,
    required this.title,
    required this.url,
    required this.summary,
    required this.topic,
    this.youtubeVideoId,
    this.chapters,
  });

  final String dateKey;
  final String type; // article | video
  final String title;
  final String url;
  final String summary;
  final String topic;
  final String? youtubeVideoId;

  /// B35 — AI-derived chapter markers, cached once generated. Null means
  /// "not yet attempted"; an empty list means "attempted, no usable
  /// transcript was found" — both render the same (no chapter row).
  final List<VideoChapter>? chapters;

  DailyContentItem copyWithChapters(List<VideoChapter> chapters) => DailyContentItem(
        dateKey: dateKey,
        type: type,
        title: title,
        url: url,
        summary: summary,
        topic: topic,
        youtubeVideoId: youtubeVideoId,
        chapters: chapters,
      );

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'type': type,
        'title': title,
        'url': url,
        'summary': summary,
        'topic': topic,
        'youtubeVideoId': youtubeVideoId,
        if (chapters != null) 'chapters': chapters!.map((c) => c.toJson()).toList(),
      };

  factory DailyContentItem.fromJson(Map<String, dynamic> json) {
    final chaptersRaw = json['chapters'];
    return DailyContentItem(
      dateKey: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'article',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString(),
      chapters: chaptersRaw is List
          ? chaptersRaw
              .whereType<Map>()
              .map((m) => VideoChapter.fromJson(Map<String, dynamic>.from(m)))
              .whereType<VideoChapter>()
              .toList()
          : null,
    );
  }
}

/// Today's validated study pack: exactly one article + one video when complete.
class DailyContentPack {
  const DailyContentPack({
    required this.dateKey,
    required this.topic,
    this.article,
    this.video,
    this.recentArticleUrls = const [],
  });

  final String dateKey;
  final String topic;
  final DailyContentItem? article;
  final DailyContentItem? video;

  /// Article URLs shown in recent daily packs (oldest first, capped), kept
  /// across days so a fixed topic doesn't resolve to the same article every
  /// time. See [DailyContentService.kMaxRecentArticleUrls].
  final List<String> recentArticleUrls;

  DailyContentPack copyWithVideo(DailyContentItem video) => DailyContentPack(
        dateKey: dateKey,
        topic: topic,
        article: article,
        video: video,
        recentArticleUrls: recentArticleUrls,
      );

  bool get isComplete =>
      article != null &&
      article!.url.isNotEmpty &&
      video != null &&
      video!.url.isNotEmpty;

  List<DailyContentItem> get items => [
        if (article != null && article!.url.isNotEmpty) article!,
        if (video != null && video!.url.isNotEmpty) video!,
      ];

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'topic': topic,
        'article': article?.toJson(),
        'video': video?.toJson(),
        'recentArticleUrls': recentArticleUrls,
      };

  factory DailyContentPack.fromJson(Map<String, dynamic> json) {
    // Legacy single-item file: { type, url, ... }
    if (json.containsKey('url') && json.containsKey('type') && !json.containsKey('article')) {
      final item = DailyContentItem.fromJson(json);
      return DailyContentPack(
        dateKey: item.dateKey,
        topic: item.topic,
        article: item.type == 'article' ? item : null,
        video: item.type == 'video' ? item : null,
      );
    }
    DailyContentItem? article;
    DailyContentItem? video;
    final a = json['article'];
    final v = json['video'];
    if (a is Map) {
      article = DailyContentItem.fromJson(Map<String, dynamic>.from(a));
    }
    if (v is Map) {
      video = DailyContentItem.fromJson(Map<String, dynamic>.from(v));
    }
    final recentRaw = json['recentArticleUrls'];
    final recentArticleUrls = recentRaw is List
        ? recentRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
        : <String>[];
    return DailyContentPack(
      dateKey: json['date']?.toString() ?? article?.dateKey ?? video?.dateKey ?? '',
      topic: json['topic']?.toString() ?? article?.topic ?? video?.topic ?? '',
      article: article,
      video: video,
      recentArticleUrls: recentArticleUrls,
    );
  }
}

/// AI-picked daily article + video for an on-goal topic. Persists to JSON (not Isar).
class DailyContentService {
  DailyContentService({
    required this.quizRepository,
    required this.learnerRepository,
    required this.llmManager,
  });

  final QuizRepository quizRepository;
  final LearnerRepository learnerRepository;
  final LlmManager llmManager;
  static final GoalContentValidationAgent _validator = GoalContentValidationAgent();

  static const _fileName = 'daily_content_v1.json';
  static const _maxAttempts = 4;

  /// How many recently-shown article URLs to remember (oldest evicted first).
  static const kMaxRecentArticleUrls = 14;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Reads the persisted recent-article-URL history regardless of whether
  /// the persisted pack matches today's date (unlike [findTodaysPack], which
  /// discards stale packs) — this history must survive across days.
  Future<List<String>> _readRecentArticleUrls() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return const [];
      final pack = DailyContentPack.fromJson(Map<String, dynamic>.from(decoded));
      return pack.recentArticleUrls;
    } catch (_) {
      return const [];
    }
  }

  /// Appends [url] to [existing] (moving it to the end if already present)
  /// and evicts the oldest entries past [kMaxRecentArticleUrls].
  static List<String> _withRecentUrl(List<String> existing, String? url) {
    if (url == null || url.isEmpty) return existing;
    final updated = [...existing.where((u) => u != url), url];
    if (updated.length > kMaxRecentArticleUrls) {
      return updated.sublist(updated.length - kMaxRecentArticleUrls);
    }
    return updated;
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  Future<DailyContentPack?> findTodaysPack() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      final pack = DailyContentPack.fromJson(Map<String, dynamic>.from(decoded));
      if (pack.dateKey != _dateKey(DateTime.now())) return null;
      if (!pack.isComplete) {
        try {
          await file.delete();
        } catch (_) {}
        return null;
      }
      if (_isStaleExamOverview(pack)) return null;
      return pack;
    } catch (_) {
      return null;
    }
  }

  /// Legacy helper — returns the article when present, else the video.
  Future<DailyContentItem?> findTodaysContent() async {
    final pack = await findTodaysPack();
    if (pack == null) return null;
    return pack.article ?? pack.video;
  }

  Future<void> _persist(DailyContentPack pack) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(pack.toJson()));
  }

  /// B35 — persists generated chapter markers onto today's video item, so
  /// they're computed once and read back on later views instead of
  /// re-fetched every time. Silently no-ops if today's pack (or its video)
  /// no longer exists — this is cache-population, never a required write.
  Future<void> saveVideoChapters(List<VideoChapter> chapters) async {
    try {
      final pack = await findTodaysPack();
      final video = pack?.video;
      if (pack == null || video == null) return;
      await _persist(pack.copyWithVideo(video.copyWithChapters(chapters)));
    } catch (_) {}
  }

  /// Deletes today's pack file (Settings reset / clear).
  Future<void> clearPersisted() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (_) {}
    try {
      final dir = await getApplicationDocumentsDirectory();
      final scheduler = File('${dir.path}/daily_content_scheduler.json');
      if (await scheduler.exists()) await scheduler.delete();
    } catch (_) {}
  }

  /// Ensures today's complete pack (1 article + 1 video). Returns null when
  /// goals missing, AI unavailable, or validation fails for either resource.
  Future<DailyContentPack?> ensureTodaysContent() async {
    final existing = await findTodaysPack();
    if (existing != null) return existing;

    final profile = await learnerRepository.getOrCreateProfile();
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: learnerRepository)) {
      return null;
    }

    final goals = learnerRepository.goalsOf(profile);
    final weak = await learnerRepository.weakTopics(limit: 3);
    final pickedTopic = _pickTopic(goals: goals, weak: weak.map((e) => e.topic).toList());
    if (pickedTopic == null || pickedTopic.isEmpty) return null;

    final resolver = GoalTopicResolver(llmManager: llmManager);
    final resolved = await resolver.resolve(pickedTopic);
    final resolvedTopic = resolved?.effectiveTopic ?? pickedTopic;
    var resolutionBlock = resolved?.promptBlock ?? '';

    final practiceTopic = SkillArticles.preferredTopic(
      resolved: resolvedTopic,
      picked: pickedTopic,
      goalContext: profile.goalContext,
      goals: goals,
    );
    final contentTopic = practiceTopic ?? resolvedTopic;

    if (practiceTopic == null && !resolutionBlock.contains('OPEN KNOWLEDGE')) {
      final openBlock =
          await OpenKnowledgeService().gatherPromptContext(resolvedTopic);
      if (openBlock.isNotEmpty) {
        resolutionBlock = resolutionBlock.isEmpty
            ? openBlock
            : '$resolutionBlock\n$openBlock';
      }
    }

    // Article URLs shown in recent packs — excluded below so a fixed topic
    // (e.g. a single-goal learner, see _pickTopic) doesn't resolve to the
    // same article every day.
    final recentArticleUrls = await _readRecentArticleUrls();
    final recentArticleUrlSet = recentArticleUrls.toSet();

    final dateKey = _dateKey(DateTime.now());
    var article = await _generateValidated(
      type: 'article',
      topic: contentTopic,
      dateKey: dateKey,
      topicResolutionBlock: resolutionBlock,
      recentArticleUrls: recentArticleUrlSet,
    );
    var video = await _generateValidated(
      type: 'video',
      topic: contentTopic,
      dateKey: dateKey,
      topicResolutionBlock: resolutionBlock,
    );
    article ??= await DailyContentFallbacks.pick(
      type: 'article',
      topic: contentTopic,
      dateKey: dateKey,
      excludeUrls: recentArticleUrlSet,
    );
    video ??= await DailyContentFallbacks.pick(
      type: 'video',
      topic: contentTopic,
      dateKey: dateKey,
    );
    article ??= await DailyContentFallbacks.pick(
      type: 'article',
      topic: contentTopic,
      dateKey: dateKey,
      trustedOnly: true,
      excludeUrls: recentArticleUrlSet,
    );
    video ??= await DailyContentFallbacks.pick(
      type: 'video',
      topic: contentTopic,
      dateKey: dateKey,
      trustedOnly: true,
    );
    article ??= await DailyContentFallbacks.topicAwareMinimumArticle(
      topic: contentTopic,
      dateKey: dateKey,
      excludeUrls: recentArticleUrlSet,
    );
    video ??= DailyContentFallbacks.topicAwareMinimumVideo(
      topic: contentTopic,
      dateKey: dateKey,
    );

    final pack = DailyContentPack(
      dateKey: dateKey,
      topic: contentTopic,
      article: article,
      video: video,
      recentArticleUrls: _withRecentUrl(recentArticleUrls, article.url),
    );
    await _persist(pack);
    return pack;
  }

  Future<DailyContentItem?> _generateValidated({
    required String type,
    required String topic,
    required String dateKey,
    String topicResolutionBlock = '',
    Set<String> recentArticleUrls = const {},
  }) async {
    final avoidUrls = <String>{};
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final raw = await llmManager.completeJson(
          userPrompt: type == 'video'
              ? _videoPrompt(topic, topicResolutionBlock: topicResolutionBlock)
              : _articlePrompt(
                  topic,
                  topicResolutionBlock: topicResolutionBlock,
                  avoidUrls: avoidUrls,
                ),
          systemPrompt:
              'You are a curriculum curator. Respond with a single valid JSON object only. No markdown.',
          recordBuiltinQuota: false,
          skipQuota: true,
        );
        final item = await _parseAndValidate(
          raw,
          expectedType: type,
          dateKey: dateKey,
          topic: topic,
        );
        if (item != null) {
          if (type == 'article' && recentArticleUrls.contains(item.url)) {
            // Same article as a recent day — nudge the LLM away from it and
            // retry instead of showing a repeat.
            avoidUrls.add(item.url);
            continue;
          }
          return item;
        }
      } on NoProviderConfiguredException {
        break;
      } on ProviderUnavailableException {
        break;
      } on BuiltInQuotaExceededException {
        break;
      } catch (_) {
        // Retry on parse/validation failure.
      }
    }
    return DailyContentFallbacks.pick(
      type: type,
      topic: topic,
      dateKey: dateKey,
      excludeUrls: type == 'article' ? recentArticleUrls : const {},
    );
  }

  String _articlePrompt(
    String topic, {
    String topicResolutionBlock = '',
    Set<String> avoidUrls = const {},
  }) {
    if (LanguageExamResources.matches(topic)) {
      return '''
Pick one FREE article that teaches an IELTS skill, starting from the basics of that skill. Topic: "$topic".
Return a single JSON object only:
{"type":"article","title":"...","url":"https://...","summary":"1-2 sentences"}

Rules:
- The article must practice or explain a real task: reading question types, listening sections, writing task 1 or 2, or speaking parts 1–3.
- Do NOT pick a Wikipedia page, a page about the history of the exam, fees, or "what IELTS stands for".
- Use ONLY https URLs on: ieltsliz.com, takeielts.britishcouncil.org, www.ielts.org, ielts.idp.com
- Prefer this order when it is a new learner: reading techniques, then listening, then writing, then speaking.
- URL must be a real article page (not a homepage or search results).
${avoidUrls.isEmpty ? '' : '- Do not suggest any of these URLs again: ${avoidUrls.join(', ')}\n'}''';
    }
    if (SkillArticles.isPracticeTopic(topic)) {
      return '''
Pick one FREE lesson that teaches a skill for "$topic", starting from the basics of that skill.
Return a single JSON object only:
{"type":"article","title":"...","url":"https://...","summary":"1-2 sentences"}

Rules:
- The page must teach a task: a tutorial, a worked example, or the first chapter of an official guide.
- Do NOT pick a Wikipedia page, a page about the history of the exam or language, fees, or "what $topic stands for".
- Use ONLY https URLs on: www.w3schools.com, www.geeksforgeeks.org, developer.mozilla.org, www.khanacademy.org, docs.python.org, react.dev, docs.flutter.dev, dart.dev, docs.aws.amazon.com, learn.microsoft.com, cloud.google.com, kubernetes.io, docs.docker.com, go.dev, kotlinlang.org, javascript.info, realpython.com, www.freecodecamp.org
- URL must be a real lesson page (not a homepage or search results).
${avoidUrls.isEmpty ? '' : '- Do not suggest any of these URLs again: ${avoidUrls.join(', ')}\n'}''';
    }
    return '''
${topicResolutionBlock.isNotEmpty ? '$topicResolutionBlock\n' : ''}${InputKindPrompt.articleRules(topic)}
Pick one FREE, real article/tutorial for this topic: "$topic".
Return a single JSON object only:
{"type":"article","title":"...","url":"https://...","summary":"1-2 sentences"}

Rules:
- Title and summary must be clearly about "$topic".
- Treat every word in the topic as mandatory scope (e.g. "Islamic history" = historical periods/events, NOT generic religious practice trivia; "Biomedical" = clinical/bioengineering, NOT general high-school biology).
- Use ONLY https URLs on these hosts (pick the best match for the topic):
  en.wikipedia.org, www.wikihow.com, www.howtogeek.com, www.khanacademy.org,
  www.investopedia.com, www.britannica.com, www.ted.com, developer.mozilla.org,
  www.w3schools.com, www.geeksforgeeks.org, www.freecodecamp.org,
  www.tutorialspoint.com, javascript.info, realpython.com, docs.python.org,
  docs.flutter.dev, dart.dev, react.dev
- For computer science, coding, or programming topics PREFER hands-on tutorial sites:
  GeeksforGeeks, W3Schools, MDN, freeCodeCamp, TutorialsPoint, Real Python, or official docs — NOT generic Wikipedia overviews unless no tutorial exists.
- For business / product / career topics prefer Wikipedia, wikiHow, How-To Geek, Investopedia, Khan Academy, or TED — not generic coding tutorials.
- URL must be a real article page (not a site homepage or search results).
- Never invent paths. Prefer a different URL on each retry.
${avoidUrls.isEmpty ? '' : '- Do not suggest any of these URLs again, pick a different real article: ${avoidUrls.join(', ')}\n'}''';
  }

  String _videoPrompt(String topic, {String topicResolutionBlock = ''}) {
    if (LanguageExamResources.matches(topic)) {
      return '''
Pick one FREE YouTube lesson that teaches an IELTS skill (reading, listening, writing, or speaking), not an overview of the exam brand. Topic: "$topic".
Return a single JSON object only:
{"type":"video","title":"...","url":"https://www.youtube.com/watch?v=VIDEO_ID","summary":"1-2 sentences"}

Rules:
- Prefer channels: IELTS Liz, E2 IELTS, IELTS Advantage, British Council.
- Do NOT suggest a video whose title is only "What is IELTS" or a band-score chart.
- URL must be a real watch URL (https://www.youtube.com/watch?v=VIDEO_ID) with an 11-character ID. Never invent IDs.
''';
    }
    if (SkillArticles.isPracticeTopic(topic)) {
      return '''
Pick one FREE YouTube lesson that teaches a skill for "$topic", starting from the basics. Not an overview of the brand or the exam.
Return a single JSON object only:
{"type":"video","title":"...","url":"https://www.youtube.com/watch?v=VIDEO_ID","summary":"1-2 sentences"}

Rules:
- Prefer a worked example, a first lesson, or a practice walkthrough.
- Do NOT suggest a video whose title is only "What is $topic" or a fee or syllabus chart.
- URL must be a real watch URL (https://www.youtube.com/watch?v=VIDEO_ID) with an 11-character ID. Never invent IDs.
''';
    }
    return '''
${topicResolutionBlock.isNotEmpty ? '$topicResolutionBlock\n' : ''}${InputKindPrompt.videoRules(topic)}
Pick one FREE, real YouTube tutorial video for this topic: "$topic".
Return a single JSON object only:
{"type":"video","title":"...","url":"https://www.youtube.com/watch?v=VIDEO_ID","summary":"1-2 sentences"}

Rules:
- Title and summary must be clearly about "$topic".
- Treat every word in the topic as mandatory scope (e.g. "Islamic history" = historical periods/events, NOT generic religious practice trivia; "Biomedical" = clinical/bioengineering, NOT general high-school biology).
- For business, product, or career topics prefer: Product School, Harvard Business Review,
  Google Careers, TED / TED-Ed, MIT Sloan — NOT generic coding bootcamp channels.
- For computer science, coding, or programming topics prefer: freeCodeCamp.org, Traversy Media, Programming with Mosh,
  The Net Ninja, Corey Schafer, Academind, Fireship, Web Dev Simplified, Tech With Tim,
  Bro Code, CodeWithHarry, Telusko, Apna College, CS50.
- Never suggest a multi-hour programming course when the topic is product management,
  business, marketing, or career skills.
- URL must be a real watch URL (https://www.youtube.com/watch?v=VIDEO_ID) with an 11-character ID
  that exists and is publicly embeddable today. Never invent or guess IDs.
- Prefer a different video each retry.
''';
  }

  Future<DailyContentItem?> _parseAndValidate(
    String raw, {
    required String expectedType,
    required String dateKey,
    required String topic,
  }) async {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map) return null;
      final data = Map<String, dynamic>.from(map);
      final type = (data['type']?.toString() ?? expectedType).toLowerCase();
      if (type != expectedType) return null;
      final url = data['url']?.toString().trim() ?? '';
      final title = data['title']?.toString().trim();
      final summary = data['summary']?.toString().trim() ?? '';
      if (url.isEmpty) return null;

      if (type == 'article' && SkillArticles.isPracticeTopic(topic)) {
        final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
        if (host.contains('wikipedia') || host.contains('wikihow') || host.contains('britannica')) {
          return null;
        }
      }

      final accepted = await ResourceLinkValidator.acceptDailyResource(
        type: type == 'video' ? 'video' : 'article',
        url: url,
        topic: topic,
        title: title,
      );
      if (!accepted.ok) return null;

      final resolvedTitle =
          (title != null && title.isNotEmpty) ? title : accepted.title;
      if (type == 'article' &&
          !_validator
              .validateOpenKnowledgeArticle(
                goal: topic,
                title: resolvedTitle,
                summary: summary,
              )
              .approved) {
        return null;
      }

      if (type == 'video' &&
          (accepted.youtubeVideoId == null || accepted.youtubeVideoId!.isEmpty)) {
        return _searchOnlyVideoItem(
          dateKey: dateKey,
          topic: topic,
          title: resolvedTitle,
          summary: summary,
        );
      }

      return DailyContentItem(
        dateKey: dateKey,
        type: type == 'video' ? 'video' : 'article',
        title: resolvedTitle,
        url: accepted.url,
        summary: summary,
        topic: topic,
        youtubeVideoId: accepted.youtubeVideoId,
      );
    } catch (_) {
      return null;
    }
  }

  static DailyContentItem _searchOnlyVideoItem({
    required String dateKey,
    required String topic,
    required String title,
    required String summary,
  }) {
    final query = Uri.encodeComponent('$topic tutorial');
    return DailyContentItem(
      dateKey: dateKey,
      type: 'video',
      title: title,
      url: 'https://www.youtube.com/results?search_query=$query',
      summary: summary.isNotEmpty
          ? summary
          : 'Search YouTube for tutorials on $topic.',
      topic: topic,
      youtubeVideoId: null,
    );
  }

  static bool _isStaleExamOverview(DailyContentPack pack) {
    final aboutSkill = SkillArticles.isPracticeTopic(pack.topic) ||
        SkillArticles.isPracticeTopic(pack.article?.topic ?? '');
    if (!aboutSkill) return false;
    final host = Uri.tryParse(pack.article?.url ?? '')?.host.toLowerCase() ?? '';
    return host.contains('wikipedia') ||
        host.contains('wikihow') ||
        host.contains('britannica');
  }

  static String? _pickTopic({required List<String> goals, required List<String> weak}) {
    if (goals.isEmpty) return null;
    final primary = goals.first;
    for (final w in weak) {
      final r = TopicGoalRelevanceGate.evaluate(
        topic: w,
        goalLabel: primary,
        goalTopics: goals,
      );
      if (r.level == TopicGoalRelevance.onGoal) return w;
    }
    return goals[DateTime.now().day % goals.length];
  }
}

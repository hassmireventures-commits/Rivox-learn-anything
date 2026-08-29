import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/remote/ai/resource_link_validator.dart';
import '../error/app_exception.dart';
import 'agentic/goal_content_validation_agent.dart';
import 'daily_content_fallbacks.dart';
import 'goal_topic_resolver.dart';
import 'learner_goal_guard.dart';
import 'llm_manager.dart';
import 'open_knowledge/open_knowledge_service.dart';
import 'topic_goal_relevance.dart';

class DailyContentItem {
  const DailyContentItem({
    required this.dateKey,
    required this.type,
    required this.title,
    required this.url,
    required this.summary,
    required this.topic,
    this.youtubeVideoId,
  });

  final String dateKey;
  final String type; // article | video
  final String title;
  final String url;
  final String summary;
  final String topic;
  final String? youtubeVideoId;

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'type': type,
        'title': title,
        'url': url,
        'summary': summary,
        'topic': topic,
        'youtubeVideoId': youtubeVideoId,
      };

  factory DailyContentItem.fromJson(Map<String, dynamic> json) {
    return DailyContentItem(
      dateKey: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'article',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString(),
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
  });

  final String dateKey;
  final String topic;
  final DailyContentItem? article;
  final DailyContentItem? video;

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
    return DailyContentPack(
      dateKey: json['date']?.toString() ?? article?.dateKey ?? video?.dateKey ?? '',
      topic: json['topic']?.toString() ?? article?.topic ?? video?.topic ?? '',
      article: article,
      video: video,
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

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
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

    if (!resolutionBlock.contains('OPEN KNOWLEDGE')) {
      final openBlock =
          await OpenKnowledgeService().gatherPromptContext(resolvedTopic);
      if (openBlock.isNotEmpty) {
        resolutionBlock = resolutionBlock.isEmpty
            ? openBlock
            : '$resolutionBlock\n$openBlock';
      }
    }

    final dateKey = _dateKey(DateTime.now());
    var article = await _generateValidated(
      type: 'article',
      topic: resolvedTopic,
      dateKey: dateKey,
      topicResolutionBlock: resolutionBlock,
    );
    var video = await _generateValidated(
      type: 'video',
      topic: resolvedTopic,
      dateKey: dateKey,
      topicResolutionBlock: resolutionBlock,
    );
    article ??= await DailyContentFallbacks.pick(
      type: 'article',
      topic: resolvedTopic,
      dateKey: dateKey,
    );
    video ??= await DailyContentFallbacks.pick(
      type: 'video',
      topic: resolvedTopic,
      dateKey: dateKey,
    );
    article ??= await DailyContentFallbacks.pick(
      type: 'article',
      topic: resolvedTopic,
      dateKey: dateKey,
      trustedOnly: true,
    );
    video ??= await DailyContentFallbacks.pick(
      type: 'video',
      topic: resolvedTopic,
      dateKey: dateKey,
      trustedOnly: true,
    );
    article ??= await DailyContentFallbacks.topicAwareMinimumArticle(
      topic: resolvedTopic,
      dateKey: dateKey,
    );
    video ??= DailyContentFallbacks.topicAwareMinimumVideo(
      topic: resolvedTopic,
      dateKey: dateKey,
    );

    final pack = DailyContentPack(
      dateKey: dateKey,
      topic: resolvedTopic,
      article: article,
      video: video,
    );
    await _persist(pack);
    return pack;
  }

  Future<DailyContentItem?> _generateValidated({
    required String type,
    required String topic,
    required String dateKey,
    String topicResolutionBlock = '',
  }) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final raw = await llmManager.completeJson(
          userPrompt: type == 'video'
              ? _videoPrompt(topic, topicResolutionBlock: topicResolutionBlock)
              : _articlePrompt(topic, topicResolutionBlock: topicResolutionBlock),
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
        if (item != null) return item;
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
    return DailyContentFallbacks.pick(type: type, topic: topic, dateKey: dateKey);
  }

  String _articlePrompt(String topic, {String topicResolutionBlock = ''}) => '''
${topicResolutionBlock.isNotEmpty ? '$topicResolutionBlock\n' : ''}Pick one FREE, real article/tutorial for this topic: "$topic".
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
''';

  String _videoPrompt(String topic, {String topicResolutionBlock = ''}) => '''
${topicResolutionBlock.isNotEmpty ? '$topicResolutionBlock\n' : ''}Pick one FREE, real YouTube tutorial video for this topic: "$topic".
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

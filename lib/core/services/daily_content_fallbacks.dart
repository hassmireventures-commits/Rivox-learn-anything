import '../../data/remote/ai/resource_link_validator.dart';
import 'coding_tutorial_sources.dart';
import 'daily_content_service.dart';
import 'goal_topic_resolver.dart';
import 'learning_article_resolver.dart';
import 'topic_grounding_service.dart';

/// Curated / deterministic picks when the LLM returns URLs that fail validation.
class DailyContentFallbacks {
  DailyContentFallbacks._();

  static final TopicGroundingService _grounding = TopicGroundingService();

  static Future<DailyContentItem?> pick({
    required String type,
    required String topic,
    required String dateKey,
    bool trustedOnly = false,
  }) async {
    if (trustedOnly) {
      return _guaranteedMinimum(type: type, topic: topic, dateKey: dateKey);
    }

    if (GoalTopicResolver.needsResolution(topic)) {
      final orgPick = await _pickForOrgDomain(
        type: type,
        topic: topic,
        dateKey: dateKey,
      );
      if (orgPick != null) return orgPick;
    }

    if (type != 'video') {
      final generic = await LearningArticleResolver.resolve(topic: topic);
      if (generic != null) {
        return DailyContentItem(
          dateKey: dateKey,
          type: 'article',
          title: generic.title,
          url: generic.url,
          summary: generic.summary,
          topic: topic,
        );
      }
    }

    if (type != 'video' && CodingTutorialSources.isCodingTopic(topic)) {
      final codingPick = await _pickCodingArticle(topic: topic, dateKey: dateKey);
      if (codingPick != null) return codingPick;
    }

    final candidates = type == 'video'
        ? _videoCandidates(topic)
        : _articleCandidates(topic);
    for (final c in candidates) {
      final accepted = await ResourceLinkValidator.acceptDailyResource(
        type: type,
        url: c.url,
        topic: topic,
        title: c.title,
        trustedFallback: c.trusted,
      );
      if (!accepted.ok) continue;
      return DailyContentItem(
        dateKey: dateKey,
        type: type == 'video' ? 'video' : 'article',
        title: c.title,
        url: accepted.url,
        summary: c.summary,
        topic: topic,
        youtubeVideoId: accepted.youtubeVideoId,
      );
    }
    return _guaranteedMinimum(type: type, topic: topic, dateKey: dateKey);
  }

  static Future<DailyContentItem?> _pickCodingArticle({
    required String topic,
    required String dateKey,
  }) async {
    for (final c in CodingTutorialSources.articleCandidates(topic)) {
      final accepted = await ResourceLinkValidator.acceptDailyResource(
        type: 'article',
        url: c.url,
        topic: topic,
        title: c.title,
        trustedFallback: true,
      );
      if (!accepted.ok) continue;
      return DailyContentItem(
        dateKey: dateKey,
        type: 'article',
        title: c.title,
        url: accepted.url,
        summary: c.summary,
        topic: topic,
      );
    }
    return null;
  }

  /// Wikipedia search + trusted AI/business videos for org/domain goals.
  static Future<DailyContentItem?> _pickForOrgDomain({
    required String type,
    required String topic,
    required String dateKey,
  }) async {
    if (type == 'article') {
      final brand = TopicGroundingService.wikipediaSearchTerm(topic);
      final queries = <String>[
        if (brand.isNotEmpty) '$brand company',
        if (brand.isNotEmpty) '$brand software',
        if (brand.isNotEmpty) brand,
        if (topic.toLowerCase().contains('.ai')) 'Artificial intelligence',
        if (brand.isNotEmpty && topic.toLowerCase().contains('.ai'))
          '$brand artificial intelligence',
        'Startup company',
        'Technology company',
      ];
      for (final q in queries) {
        final wiki = await _grounding.findWikipediaArticle(
          q,
          validateForGoal: topic,
        );
        if (wiki == null) continue;
        final accepted = await ResourceLinkValidator.acceptDailyResource(
          type: 'article',
          url: wiki.url,
          topic: topic,
          title: wiki.title,
          trustedFallback: true,
        );
        if (!accepted.ok) continue;
        return DailyContentItem(
          dateKey: dateKey,
          type: 'article',
          title: wiki.title,
          url: accepted.url,
          summary: wiki.extract.length > 200
              ? '${wiki.extract.substring(0, 197)}...'
              : wiki.extract,
          topic: topic,
        );
      }
      for (final c in _orgDomainArticleCandidates(topic)) {
        final accepted = await ResourceLinkValidator.acceptDailyResource(
          type: 'article',
          url: c.url,
          topic: topic,
          title: c.title,
          trustedFallback: true,
        );
        if (!accepted.ok) continue;
        return DailyContentItem(
          dateKey: dateKey,
          type: 'article',
          title: c.title,
          url: accepted.url,
          summary: c.summary,
          topic: topic,
        );
      }
    } else {
      for (final c in _orgDomainVideoCandidates(topic)) {
        final accepted = await ResourceLinkValidator.acceptDailyResource(
          type: 'video',
          url: c.url,
          topic: topic,
          title: c.title,
          trustedFallback: true,
        );
        if (!accepted.ok) continue;
        return DailyContentItem(
          dateKey: dateKey,
          type: 'video',
          title: c.title,
          url: accepted.url,
          summary: c.summary,
          topic: topic,
          youtubeVideoId: accepted.youtubeVideoId,
        );
      }
    }
    return null;
  }

  /// Last-resort pack pieces that skip topic-relevance gates (reachability only).
  static Future<DailyContentItem?> _guaranteedMinimum({
    required String type,
    required String topic,
    required String dateKey,
  }) async {
    if (type == 'article') {
      final wikiPick = await topicAwareMinimumArticle(topic: topic, dateKey: dateKey);
      final accepted = await ResourceLinkValidator.acceptDailyResource(
        type: 'article',
        url: wikiPick.url,
        topic: topic,
        title: wikiPick.title,
        trustedFallback: true,
      );
      if (accepted.ok) {
        return DailyContentItem(
          dateKey: dateKey,
          type: 'article',
          title: wikiPick.title,
          url: accepted.url,
          summary: wikiPick.summary,
          topic: topic,
        );
      }

      final candidates = _articleCandidates(topic);
      for (final c in candidates) {
        final ok = await ResourceLinkValidator.acceptDailyResource(
          type: 'article',
          url: c.url,
          topic: topic,
          title: c.title,
          trustedFallback: true,
        );
        if (!ok.ok) continue;
        return DailyContentItem(
          dateKey: dateKey,
          type: 'article',
          title: c.title,
          url: ok.url,
          summary: c.summary,
          topic: topic,
        );
      }
      return wikiPick;
    }

    return topicAwareMinimumVideo(topic: topic, dateKey: dateKey);
  }

  /// Offline last resort — topic-specific Wikipedia or slug when possible.
  static Future<DailyContentItem> topicAwareMinimumArticle({
    required String topic,
    required String dateKey,
  }) async {
    final trimmed = topic.trim();
    for (final q in LearningArticleResolver.buildSearchQueries(topic: trimmed)) {
      final wiki = await _grounding.findWikipediaArticle(q);
      if (wiki == null) continue;
      return DailyContentItem(
        dateKey: dateKey,
        type: 'article',
        title: wiki.title,
        url: wiki.url,
        summary: wiki.extract.length > 200
            ? '${wiki.extract.substring(0, 197)}...'
            : wiki.extract,
        topic: trimmed,
      );
    }
    final slug = _wikiSlug(trimmed);
    return DailyContentItem(
      dateKey: dateKey,
      type: 'article',
      title: trimmed,
      url: 'https://en.wikipedia.org/wiki/$slug',
      summary: 'Free overview related to $trimmed.',
      topic: trimmed,
    );
  }

  /// Search-only video fallback aligned with the pack topic (no generic TED clip).
  static DailyContentItem topicAwareMinimumVideo({
    required String topic,
    required String dateKey,
  }) {
    final trimmed = topic.trim();
    final query = Uri.encodeComponent('$trimmed tutorial');
    return DailyContentItem(
      dateKey: dateKey,
      type: 'video',
      title: trimmed,
      url: 'https://www.youtube.com/results?search_query=$query',
      summary: 'Search YouTube for tutorials on $trimmed.',
      topic: trimmed,
      youtubeVideoId: null,
    );
  }

  @Deprecated('Use topicAwareMinimumArticle')
  static DailyContentItem offlineMinimumArticle({
    required String topic,
    required String dateKey,
  }) {
    return DailyContentItem(
      dateKey: dateKey,
      type: 'article',
      title: 'Learning',
      url: 'https://en.wikipedia.org/wiki/Learning',
      summary: 'How people acquire knowledge and skills.',
      topic: topic,
    );
  }

  static DailyContentItem offlineMinimumVideo({
    required String topic,
    required String dateKey,
  }) {
    return DailyContentItem(
      dateKey: dateKey,
      type: 'video',
      title: 'How to learn effectively',
      url: 'https://www.youtube.com/watch?v=8DqXuv6dBQI',
      summary: 'Free educational video on learning strategies.',
      topic: topic,
      youtubeVideoId: '8DqXuv6dBQI',
    );
  }

  static bool _isCareerOrBusiness(String lower) {
    const keys = [
      'product', 'manager', 'management', 'business', 'marketing', 'career',
      'leadership', 'startup', 'strategy', 'consult', 'mba',
    ];
    return keys.any(lower.contains);
  }

  static bool _isTechnical(String lower) =>
      CodingTutorialSources.isCodingTopic(lower);

  static bool _isOrgDomain(String topic) => GoalTopicResolver.needsResolution(topic);

  static bool _isBiomedical(String lower) =>
      lower.contains('biomedical') ||
      lower.contains('bio medical') ||
      lower.contains('bio-medical') ||
      (lower.contains('bio') && lower.contains('medical'));

  static bool _isIslamicHistory(String lower) =>
      lower.contains('islamic history') ||
      lower.contains('history of islam') ||
      (lower.contains('islam') && lower.contains('history'));

  static bool _isHistory(String lower) =>
      _isIslamicHistory(lower) ||
      RegExp(r'\bhistory\b').hasMatch(lower) ||
      lower.contains('historical');

  static String _wikiSlug(String topic) {
    var t = topic.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (RegExp(r'^bio\s*medical$', caseSensitive: false).hasMatch(t)) {
      t = 'Biomedical engineering';
    }
    if (_isOrgDomain(t)) {
      return 'Artificial_intelligence';
    }
    return t.replaceAll(' ', '_');
  }

  static List<({String url, String title, String summary})>
      _orgDomainArticleCandidates(String topic) {
    final brand = TopicGroundingService.wikipediaSearchTerm(topic);
    final label = brand.isEmpty ? topic : brand;
    return [
      (
        url: 'https://en.wikipedia.org/wiki/Artificial_intelligence',
        title: 'Artificial intelligence',
        summary: 'Foundations of AI — relevant context for $label.',
      ),
      (
        url: 'https://en.wikipedia.org/wiki/Startup_company',
        title: 'Startup company',
        summary: 'How technology startups like $label operate and grow.',
      ),
      (
        url: 'https://en.wikipedia.org/wiki/Technology_company',
        title: 'Technology company',
        summary: 'How product and software companies build and ship.',
      ),
    ];
  }

  static List<({String url, String title, String summary})>
      _orgDomainVideoCandidates(String topic) {
    const ids = [
      'uZoWiwjQedg',
      'TQSa6E0vgYs',
      'RkXYsS23ANM',
      '8DqXuv6dBQI',
    ];
    return [
      for (final id in ids)
        (
          url: 'https://www.youtube.com/watch?v=$id',
          title: '$topic — learning video',
          summary: 'Free educational video for studying $topic.',
        ),
    ];
  }

  static Future<DailyContentItem?> pickForModule({
    required String moduleTitle,
    Set<String> excludeUrls = const {},
    String pathContext = '',
    String pathTitle = '',
  }) async {
    final ranked = await pickForModuleRanked(
      moduleTitle: moduleTitle,
      excludeUrls: excludeUrls,
      pathContext: pathContext,
      pathTitle: pathTitle,
      limit: 1,
    );
    return ranked.isEmpty ? null : ranked.first;
  }

  static Future<List<DailyContentItem>> pickForModuleRanked({
    required String moduleTitle,
    Set<String> excludeUrls = const {},
    String pathContext = '',
    String pathTitle = '',
    int limit = 2,
  }) async {
    final resolved = await LearningArticleResolver.resolveRanked(
      topic: moduleTitle,
      goalContext: pathContext,
      pathTitle: pathTitle,
      excludeUrls: excludeUrls,
      limit: limit,
    );
    return [
      for (final r in resolved)
        DailyContentItem(
          dateKey: 'path',
          type: 'article',
          title: r.title,
          url: r.url,
          summary: r.summary,
          topic: moduleTitle,
        ),
    ];
  }

  static List<({String url, String title, String summary, bool trusted})>
      moduleArticleCandidates(String moduleTitle, {String pathContext = ''}) {
    // Kept for tests and legacy callers — path modules use LearningArticleResolver.
    final trimmed = moduleTitle.trim();
    final slug = _wikiSlug(trimmed);
    final out = <({String url, String title, String summary, bool trusted})>[];

    void add(String url, String title, [String? summary, bool trusted = false]) {
      out.add((
        url: url,
        title: title,
        summary: summary ?? 'Free reading for $trimmed.',
        trusted: trusted,
      ));
    }

    add('https://en.wikipedia.org/wiki/$slug', trimmed, null, true);

    if (CodingTutorialSources.isCodingTopic(trimmed)) {
      for (final c in CodingTutorialSources.articleCandidates(trimmed)) {
        add(c.url, c.title, c.summary, true);
      }
    }

    return out;
  }

  static bool _isAiAgentAutomation(String lower) =>
      lower.contains('ai agent') ||
      lower.contains('agent and automation') ||
      (lower.contains('agent') && lower.contains('automation')) ||
      (lower.contains('artificial intelligence') && lower.contains('agent'));

  static List<({String url, String title, String summary})>
      _aiAgentArticleCandidates(String topic) {
    return [
      (
        url: 'https://en.wikipedia.org/wiki/Intelligent_agent',
        title: 'Intelligent agent',
        summary: 'Software agents that perceive and act toward goals — core to $topic.',
      ),
      (
        url: 'https://en.wikipedia.org/wiki/Artificial_intelligence',
        title: 'Artificial intelligence',
        summary: 'AI foundations for building autonomous agents.',
      ),
      (
        url: 'https://en.wikipedia.org/wiki/Automation',
        title: 'Automation',
        summary: 'Systems that run tasks with minimal human intervention.',
      ),
      (
        url: 'https://en.wikipedia.org/wiki/Robotic_process_automation',
        title: 'Robotic process automation',
        summary: 'Software bots that automate repetitive digital workflows.',
      ),
    ];
  }

  static List<String> _wikiSearchQueries(String topic) {
    return LearningArticleResolver.buildSearchQueries(topic: topic);
  }

  static List<({String url, String title, String summary, bool trusted})>
      _articleCandidates(String topic) {
    final trimmed = topic.trim();
    final slug = _wikiSlug(trimmed);
    final lower = trimmed.toLowerCase();
    final out = <({String url, String title, String summary, bool trusted})>[];

    void add(String url, String title, [String? summary, bool trusted = false]) {
      out.add((
        url: url,
        title: title,
        summary: summary ?? 'Free overview related to $trimmed.',
        trusted: trusted,
      ));
    }

    if (_isOrgDomain(trimmed)) {
      for (final c in _orgDomainArticleCandidates(trimmed)) {
        add(c.url, c.title, c.summary, true);
      }
      return out;
    }

    if (_isAiAgentAutomation(lower)) {
      for (final c in _aiAgentArticleCandidates(trimmed)) {
        add(c.url, c.title, c.summary, true);
      }
    }

    if (CodingTutorialSources.isCodingTopic(trimmed)) {
      for (final c in CodingTutorialSources.articleCandidates(trimmed)) {
        add(c.url, c.title, c.summary, true);
      }
    }

    if (_isIslamicHistory(lower)) {
      add(
        'https://en.wikipedia.org/wiki/History_of_Islam',
        'History of Islam',
        'Historical development of Islamic civilization.',
        true,
      );
      add(
        'https://www.britannica.com/topic/Islamic-world',
        'Islamic world — Britannica',
        'Historical overview of the Islamic world.',
      );
    } else if (_isBiomedical(lower)) {
      add(
        'https://en.wikipedia.org/wiki/Biomedical_engineering',
        'Biomedical engineering',
        'Medical devices, diagnostics, and bioengineering.',
        true,
      );
      add(
        'https://en.wikipedia.org/wiki/Biomedicine',
        'Biomedicine',
        'Applied biology in healthcare and clinical research.',
        true,
      );
      add(
        'https://www.khanacademy.org/science/health-and-medicine',
        'Health and medicine — Khan Academy',
        'Clinical and biomedical foundations.',
      );
    } else if (_isHistory(lower)) {
      add('https://en.wikipedia.org/wiki/$slug', trimmed);
      add(
        'https://www.britannica.com/search?query=${Uri.encodeComponent(trimmed)}',
        '$trimmed — Britannica',
      );
    }

    add('https://en.wikipedia.org/wiki/$slug', trimmed);
    if (!slug.endsWith('s')) {
      add('https://en.wikipedia.org/wiki/${slug}s', trimmed);
    }

    if (lower.contains('product') || lower.contains('manager')) {
      add(
        'https://en.wikipedia.org/wiki/Product_management',
        'Product management',
        'How teams build and ship products users need.',
      );
      add(
        'https://www.wikihow.com/Become-a-Product-Manager',
        'How to become a product manager',
        'Practical steps for breaking into product management.',
      );
    }
    if (lower.contains('market') || lower.contains('business')) {
      add(
        'https://en.wikipedia.org/wiki/Marketing',
        'Marketing fundamentals',
        'Core marketing concepts and vocabulary.',
      );
      add(
        'https://www.investopedia.com/terms/m/marketing.asp',
        'Marketing basics',
        'Business vocabulary for go-to-market work.',
      );
    }
    if (lower.contains('data') || lower.contains('analytic')) {
      add(
        'https://en.wikipedia.org/wiki/Data_analysis',
        'Data analysis',
        'Methods for turning data into decisions.',
      );
    }
    return out;
  }

  static List<({String url, String title, String summary, bool trusted})>
      _videoCandidates(String topic) {
    final lower = topic.toLowerCase();
    final ids = <String>[];

    if (_isOrgDomain(topic)) {
      ids.addAll(['uZoWiwjQedg', 'TQSa6E0vgYs', 'RkXYsS23ANM', '8DqXuv6dBQI']);
    }
    if (_isIslamicHistory(lower) || _isHistory(lower)) {
      ids.addAll([
        'nM3rMuTeJJ8',
        '8DqXuv6dBQI',
      ]);
    }
    if (_isBiomedical(lower)) {
      ids.addAll([
        '8DqXuv6dBQI',
        'aircAruvnKk',
      ]);
    }
    if (_isCareerOrBusiness(lower)) {
      ids.addAll([
        'RkXYsS23ANM',
        'TQSa6E0vgYs',
        'uZoWiwjQedg',
      ]);
    }
    if (_isTechnical(lower)) {
      ids.addAll([
        'PkZNo7MFNFg',
        '_uQrJ0TkZlc',
        'aircAruvnKk',
        '8DqXuv6dBQI',
        'rfscVS0vtbw',
      ]);
    }

    const generic = [
      '8DqXuv6dBQI',
      'uZoWiwjQedg',
      'RkXYsS23ANM',
    ];
    for (final id in generic) {
      if (!ids.contains(id)) ids.add(id);
    }

    final seen = <String>{};
    return [
      for (final id in ids)
        if (seen.add(id))
          (
            url: 'https://www.youtube.com/watch?v=$id',
            title: '$topic — video lesson',
            summary: 'Free educational video related to $topic.',
            trusted: id == '8DqXuv6dBQI' || _isOrgDomain(topic),
          ),
    ];
  }
}

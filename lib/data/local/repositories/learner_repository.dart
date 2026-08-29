import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/saved_goal.dart';
import '../../../core/services/secondary_goals_store.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../isar_service.dart';
import '../path_steps_storage.dart';
import '../models/learner_profile.dart';
import '../models/learning_path.dart';
import '../models/recommendation.dart';
import '../models/topic_edge.dart';
import '../models/topic_node.dart';

class LearnerRepository {
  LearnerRepository(this._isarService);

  final IsarService _isarService;
  final _uuid = const Uuid();
  Isar get _db => _isarService.db;

  Future<LearnerProfile> getOrCreateProfile() async {
    final existing = await _db.learnerProfiles.where().findFirst();
    if (existing != null) {
      // Migrate profiles created before goalMode/goalContext were added
      bool needsMigration = false;
      try { existing.goalMode; } catch (_) { existing.goalMode = 'learning'; needsMigration = true; }
      try { existing.goalContext; } catch (_) { existing.goalContext = ''; needsMigration = true; }
      if (existing.goalMode == 'recovery') {
        existing.goalMode = 'learning';
        needsMigration = true;
      }
      // New optional fields - leave null if already present / schema has them
      try {
        existing.examType;
      } catch (_) {
        existing.examType = null;
        needsMigration = true;
      }
      try {
        existing.roleSeniority;
      } catch (_) {
        existing.roleSeniority = null;
        needsMigration = true;
      }
      if (needsMigration) {
        await _db.writeTxn(() async { await _db.learnerProfiles.put(existing); });
      }
      return existing;
    }

    final profile = LearnerProfile()
      ..layoutMode = 'beginner'
      ..density = 'comfortable'
      ..layoutModeOverride = 'auto'
      ..goalsJson = '[]'
      ..preferredFormatsJson = jsonEncode({'quiz': 1.0, 'interactive': 0.5})
      ..goalMode = 'learning'
      ..goalContext = ''
      ..examType = null
      ..roleSeniority = null
      ..navOrderJson = jsonEncode(AppConstants.defaultNavOrder)
      ..navAffinityJson = '{}'
      ..skillLevel = 0.2
      ..helpImproveOptIn = false
      ..updatedAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.learnerProfiles.put(profile);
    });
    return profile;
  }

  Future<LearnerProfile> updateProfile({
    String? layoutMode,
    String? density,
    String? layoutModeOverride,
    List<String>? goals,
    int? dailyMinutesGoal,
    DateTime? examDate,
    bool clearExamDate = false,
    String? goalMode,
    String? goalContext,
    String? examType,
    bool clearExamType = false,
    String? roleSeniority,
    bool clearRoleSeniority = false,
    Map<String, double>? preferredFormats,
    List<String>? navOrder,
    Map<String, double>? navAffinity,
    double? skillLevel,
    bool? helpImproveOptIn,
    bool touchLayoutChange = false,
  }) async {
    final profile = await getOrCreateProfile();
    if (layoutMode != null) profile.layoutMode = layoutMode;
    if (density != null) profile.density = density;
    if (layoutModeOverride != null) profile.layoutModeOverride = layoutModeOverride;
    if (goals != null) profile.goalsJson = jsonEncode(goals);
    if (dailyMinutesGoal != null) profile.dailyMinutesGoal = dailyMinutesGoal;
    if (clearExamDate) {
      profile.examDate = null;
    } else if (examDate != null) {
      profile.examDate = examDate;
    }
    if (goalMode != null) profile.goalMode = goalMode;
    if (goalContext != null) profile.goalContext = goalContext;
    if (clearExamType) {
      profile.examType = null;
    } else if (examType != null) {
      profile.examType = examType;
    }
    if (clearRoleSeniority) {
      profile.roleSeniority = null;
    } else if (roleSeniority != null) {
      profile.roleSeniority = roleSeniority;
    }
    if (preferredFormats != null) {
      profile.preferredFormatsJson = jsonEncode(preferredFormats);
    }
    if (navOrder != null) profile.navOrderJson = jsonEncode(navOrder);
    if (navAffinity != null) profile.navAffinityJson = jsonEncode(navAffinity);
    if (skillLevel != null) profile.skillLevel = skillLevel;
    if (helpImproveOptIn != null) profile.helpImproveOptIn = helpImproveOptIn;
    if (touchLayoutChange) profile.lastLayoutChangeAt = DateTime.now();
    profile.updatedAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.learnerProfiles.put(profile);
    });
    return profile;
  }

  List<String> goalsOf(LearnerProfile p) {
    final list = jsonDecode(p.goalsJson);
    if (list is! List) return [];
    return list.map((e) => e.toString()).toList();
  }

  SavedGoal primaryGoalOf(LearnerProfile p) => SavedGoal(
        mode: p.goalMode,
        context: p.goalContext,
        topics: goalsOf(p),
        examDate: p.examDate,
        examType: p.examType,
        roleSeniority: p.roleSeniority,
      );

  List<SavedGoal> secondaryGoalsOf(LearnerProfile p) =>
      SecondaryGoalsStore.instance.current;

  List<SavedGoal> allGoalsOf(LearnerProfile p) => [
        primaryGoalOf(p),
        ...secondaryGoalsOf(p),
      ];

  Future<LearnerProfile> addSecondaryGoal(SavedGoal goal) async {
    await SecondaryGoalsStore.instance.load();
    final secondary = List<SavedGoal>.of(SecondaryGoalsStore.instance.current);
    final duplicate = secondary.any(
      (g) => g.mode == goal.mode && g.context == goal.context,
    );
    if (!duplicate) {
      secondary.add(goal);
      await SecondaryGoalsStore.instance.save(secondary);
    }
    return getOrCreateProfile();
  }

  Future<LearnerProfile> switchPrimaryGoal(SavedGoal target) async {
    await SecondaryGoalsStore.instance.load();
    final profile = await getOrCreateProfile();
    final current = primaryGoalOf(profile);
    var secondary = List<SavedGoal>.of(SecondaryGoalsStore.instance.current)
      ..removeWhere((g) => g.mode == target.mode && g.context == target.context);
    if (current.mode != target.mode || current.context != target.context) {
      secondary.add(current);
    }
    await SecondaryGoalsStore.instance.save(secondary);
    return updateProfile(
      goalMode: target.mode,
      goalContext: target.context,
      goals: target.topics,
      examDate: target.examDate,
      clearExamDate: target.examDate == null,
      examType: target.examType,
      clearExamType: target.examType == null,
      roleSeniority: target.roleSeniority,
      clearRoleSeniority: target.roleSeniority == null,
    );
  }

  List<String> navOrderOf(LearnerProfile p) {
    final list = jsonDecode(p.navOrderJson);
    if (list is! List) return AppConstants.defaultNavOrder;
    return list.map((e) => e.toString()).toList();
  }

  Map<String, double> navAffinityOf(LearnerProfile p) {
    final map = jsonDecode(p.navAffinityJson);
    if (map is! Map) return {};
    return map.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
  }

  Future<TopicNode> upsertTopic({
    required String topic,
    required bool correct,
    required double timeSeconds,
  }) async {
    final key = topic.trim();
    var node = await _db.topicNodes.filter().topicEqualTo(key, caseSensitive: false).findFirst();
    node ??= TopicNode()
      ..topic = key
      ..strength = 0.5
      ..attempts = 0
      ..correctCount = 0
      ..totalTimeSeconds = 0;

    node
      ..attempts += 1
      ..correctCount += correct ? 1 : 0
      ..totalTimeSeconds += timeSeconds
      ..lastSeenAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final accuracy = node.correctCount / node.attempts;
    node.strength = (node.strength * 0.7) + (accuracy * 0.3);

    await _db.writeTxn(() async {
      await _db.topicNodes.put(node!);
    });
    return node;
  }

  Future<List<TopicNode>> allTopics() async {
    return _db.topicNodes.where().sortByStrength().findAll();
  }

  Future<List<TopicNode>> weakTopics({int limit = 5}) async {
    final all = await allTopics();
    all.sort((a, b) => a.strength.compareTo(b.strength));
    return all.take(limit).toList();
  }

  Future<void> addEdge({
    required String from,
    required String to,
    required String relation,
    double weight = 1,
  }) async {
    var edge = await _db.topicEdges
        .filter()
        .fromTopicEqualTo(from)
        .toTopicEqualTo(to)
        .findFirst();
    edge ??= TopicEdge()
      ..fromTopic = from
      ..toTopic = to
      ..relation = relation
      ..weight = 0;
    edge
      ..weight += weight
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.topicEdges.put(edge!);
    });
  }

  Future<List<TopicEdge>> edgesFor(String topic) async {
    return _db.topicEdges.filter().fromTopicEqualTo(topic).findAll();
  }

  Future<List<RecommendationItem>> activeRecommendations({int limit = 10}) async {
    final all = await _db.recommendationItems.where().sortByCreatedAtDesc().findAll();
    return all.where((r) => !r.dismissed && !r.acted).take(limit).toList();
  }

  Future<RecommendationItem> addRecommendation({
    required String kind,
    required String title,
    required String reason,
    required double score,
    String? topic,
    Map<String, dynamic>? actionPayload,
  }) async {
    final item = RecommendationItem()
      ..uuid = _uuid.v4()
      ..kind = kind
      ..title = title
      ..reason = reason
      ..score = score
      ..topic = topic
      ..actionPayloadJson = actionPayload == null ? null : jsonEncode(actionPayload)
      ..dismissed = false
      ..acted = false
      ..shown = false
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.recommendationItems.put(item);
    });
    return item;
  }

  Future<void> markRecommendationShown(String uuid) async {
    final item = await _db.recommendationItems.filter().uuidEqualTo(uuid).findFirst();
    if (item == null) return;
    item.shown = true;
    await _db.writeTxn(() async {
      await _db.recommendationItems.put(item);
    });
  }

  Future<void> actOnRecommendation(String uuid) async {
    final item = await _db.recommendationItems.filter().uuidEqualTo(uuid).findFirst();
    if (item == null) return;
    item
      ..acted = true
      ..actedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.recommendationItems.put(item);
    });
  }

  Future<void> dismissRecommendation(String uuid) async {
    final item = await _db.recommendationItems.filter().uuidEqualTo(uuid).findFirst();
    if (item == null) return;
    item.dismissed = true;
    await _db.writeTxn(() async {
      await _db.recommendationItems.put(item);
    });
  }

  Future<void> clearOldRecommendations() async {
    final all = await _db.recommendationItems.where().findAll();
    final stale = all.where((r) => !r.acted && !r.dismissed).toList();
    await _db.writeTxn(() async {
      await _db.recommendationItems.deleteAll(stale.map((e) => e.id).toList());
    });
  }

  Future<LearningPath> savePath({
    required String title,
    required List<String> topics,
    required String source,
    List<Map<String, dynamic>>? steps,
    bool forceReplace = false,
  }) async {
    if (!forceReplace && await hasActivePath()) {
      throw const ActivePathExistsException();
    }
    final path = LearningPath()
      ..uuid = _uuid.v4()
      ..title = title
      ..topicsJson = jsonEncode(topics)
      ..status = 'active'
      ..source = source
      ..currentIndex = 0
      ..createdAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.learningPaths.put(path);
    });
    if (steps != null && steps.isNotEmpty) {
      await PathStepsStorage.instance.saveSteps(path.uuid, steps);
    }
    return path;
  }

  List<PathStepData> pathSteps(LearningPath path) => _topicsAsSteps(path);

  Future<List<PathStepData>> pathStepsAsync(LearningPath path) async {
    try {
      final list = await PathStepsStorage.instance.loadSteps(path.uuid);
      if (list.isEmpty) {
        return _topicsAsSteps(path);
      }
      return list.map((map) {
        final resourcesRaw = map['resources'];
        final resources = <PathResourceData>[];
        if (resourcesRaw is List) {
          for (final r in resourcesRaw) {
            if (r is Map) {
              resources.add(PathResourceData.fromJson(Map<String, dynamic>.from(r)));
            }
          }
        }
        return PathStepData(
          title: map['title']?.toString() ?? 'Module',
          summary: map['summary']?.toString() ?? '',
          difficulty: map['difficulty']?.toString() ?? 'medium',
          estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 15,
          resources: resources,
          youtubeVideoId: map['youtubeVideoId']?.toString(),
        );
      }).toList();
    } catch (_) {
      return _topicsAsSteps(path);
    }
  }

  List<PathStepData> _topicsAsSteps(LearningPath path) {
    return pathTopics(path)
        .map((t) => PathStepData(title: t, summary: '', difficulty: 'medium', estimatedMinutes: 15))
        .toList();
  }

  Future<List<LearningPath>> activePaths() async {
    await _enforceSingleActivePath();
    return _db.learningPaths.filter().statusEqualTo('active').sortByCreatedAtDesc().findAll();
  }

  Future<List<LearningPath>> completedPaths() async {
    return _db.learningPaths
        .filter()
        .statusEqualTo('completed')
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<bool> hasActivePath() async {
    final count = await _db.learningPaths.filter().statusEqualTo('active').count();
    return count > 0;
  }

  Future<LearningPath?> primaryActivePath() async {
    final paths = await activePaths();
    return paths.isEmpty ? null : paths.first;
  }

  Future<TopicPathMatch?> pathContainingTopic(String topic) async {
    final path = await primaryActivePath();
    if (path == null) return null;

    final steps = await pathStepsAsync(path);
    final key = topic.trim().toLowerCase();
    for (var i = 0; i < steps.length; i++) {
      final title = steps[i].title.toLowerCase();
      if (title == key || title.contains(key) || key.contains(title)) {
        return TopicPathMatch(path: path, moduleIndex: i);
      }
    }
    return TopicPathMatch(path: path);
  }

  Future<void> _enforceSingleActivePath() async {
    final paths = await _db.learningPaths.filter().statusEqualTo('active').sortByCreatedAtDesc().findAll();
    if (paths.length <= 1) return;

    for (var i = 1; i < paths.length; i++) {
      paths[i].status = 'archived';
    }
    await _db.writeTxn(() async {
      for (var i = 1; i < paths.length; i++) {
        await _db.learningPaths.put(paths[i]);
      }
    });
  }

  Future<LearningPath?> getPath(String uuid) async {
    return _db.learningPaths.filter().uuidEqualTo(uuid).findFirst();
  }

  List<String> pathTopics(LearningPath path) {
    final list = jsonDecode(path.topicsJson);
    if (list is! List) return [];
    return list.map((e) => e.toString()).toList();
  }

  bool isModuleUnlocked(LearningPath path, int moduleIndex) {
    return moduleIndex <= path.currentIndex;
  }

  Future<bool> advancePath(
    String uuid, {
    required int moduleIndex,
    required double accuracy,
    double passThreshold = 0.6,
  }) async {
    final threshold = passThreshold * 100;
    if (accuracy < threshold) {
      return false;
    }
    final path = await getPath(uuid);
    if (path == null || path.status != 'active') {
      return false;
    }
    if (moduleIndex != path.currentIndex) {
      return false;
    }

    final steps = await pathStepsAsync(path);
    path.currentIndex = (path.currentIndex + 1).clamp(0, steps.length);
    if (path.currentIndex >= steps.length) {
      path
        ..status = 'completed'
        ..completedAt = DateTime.now();
    }
    await _db.writeTxn(() async {
      await _db.learningPaths.put(path);
    });
    return true;
  }
}

class PathResourceData {
  const PathResourceData({
    required this.type,
    required this.title,
    required this.url,
    required this.domain,
  });

  final String type;
  final String title;
  final String url;
  final String domain;

  factory PathResourceData.fromJson(Map<String, dynamic> json) => PathResourceData(
        type: json['type']?.toString() ?? 'doc',
        title: json['title']?.toString() ?? 'Resource',
        url: json['url']?.toString() ?? '',
        domain: json['domain']?.toString() ?? '',
      );
}

class PathStepData {
  const PathStepData({
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.estimatedMinutes,
    this.resources = const [],
    this.youtubeVideoId,
  });

  final String title;
  final String summary;
  final String difficulty;
  final int estimatedMinutes;
  final List<PathResourceData> resources;
  final String? youtubeVideoId;
}

class TopicPathMatch {
  const TopicPathMatch({required this.path, this.moduleIndex});

  final LearningPath path;
  final int? moduleIndex;
}

import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../isar_service.dart';
import '../models/career_skill.dart';
import '../models/study_plan_item.dart';
import '../models/syllabus.dart';
import '../models/syllabus_unit.dart';
import '../models/topic_node.dart';
import '../models/goal_agent_seeds.dart';

/// Bootstraps and scores exam syllabus / career skill matrix from onboarding goals.
class GoalProgressRepository {
  GoalProgressRepository(this._isarService);

  final IsarService _isarService;
  final _uuid = const Uuid();
  Isar get _db => _isarService.db;

  Future<Syllabus?> activeSyllabus() => _db.syllabus.where().findFirst();

  Future<List<SyllabusUnit>> unitsFor(String syllabusUuid) {
    return _db.syllabusUnits
        .filter()
        .syllabusUuidEqualTo(syllabusUuid)
        .sortByOrderIndex()
        .findAll();
  }

  Future<List<CareerSkill>> allCareerSkills() {
    return _db.careerSkills.where().sortByOrderIndex().findAll();
  }

  /// Creates or refreshes syllabus units from goal topic strings.
  /// Existing units with matching titles keep mastery; missing titles are added.
  Future<Syllabus> bootstrapSyllabus({
    required String title,
    required List<String> topics,
    DateTime? examDate,
    String source = 'user',
  }) async {
    final cleaned = topics
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final displayTitle = title.trim().isEmpty ? 'Exam syllabus' : title.trim();

    var syllabus = await activeSyllabus();
    final now = DateTime.now();

    await _db.writeTxn(() async {
      if (syllabus == null) {
        syllabus = Syllabus()
          ..uuid = _uuid.v4()
          ..title = displayTitle
          ..examDate = examDate
          ..source = source
          ..createdAt = now
          ..updatedAt = now;
        await _db.syllabus.put(syllabus!);
      } else {
        syllabus!
          ..title = displayTitle
          ..examDate = examDate
          ..updatedAt = now;
        await _db.syllabus.put(syllabus!);
      }

      final existing = await _db.syllabusUnits
          .filter()
          .syllabusUuidEqualTo(syllabus!.uuid)
          .findAll();
      final byTitle = {
        for (final u in existing) u.title.toLowerCase(): u,
      };

      if (cleaned.isEmpty) {
        // Ensure at least one placeholder unit so coverage math is defined.
        if (existing.isEmpty) {
          final unit = SyllabusUnit()
            ..uuid = _uuid.v4()
            ..syllabusUuid = syllabus!.uuid
            ..title = displayTitle
            ..orderIndex = 0
            ..weight = 1.0
            ..mastery = 0.0
            ..topicKeysJson = jsonEncode([displayTitle])
            ..updatedAt = now;
          await _db.syllabusUnits.put(unit);
        }
        return;
      }

      final weight = 1.0 / cleaned.length;
      final keepTitles = <String>{};

      for (var i = 0; i < cleaned.length; i++) {
        final topic = cleaned[i];
        keepTitles.add(topic.toLowerCase());
        final prior = byTitle[topic.toLowerCase()];
        if (prior != null) {
          prior
            ..orderIndex = i
            ..weight = weight
            ..topicKeysJson = jsonEncode([topic])
            ..updatedAt = now;
          await _db.syllabusUnits.put(prior);
        } else {
          final unit = SyllabusUnit()
            ..uuid = _uuid.v4()
            ..syllabusUuid = syllabus!.uuid
            ..title = topic
            ..orderIndex = i
            ..weight = weight
            ..mastery = 0.0
            ..topicKeysJson = jsonEncode([topic])
            ..updatedAt = now;
          await _db.syllabusUnits.put(unit);
        }
      }

      for (final u in existing) {
        if (!keepTitles.contains(u.title.toLowerCase())) {
          await _db.syllabusUnits.delete(u.id);
        }
      }
    });

    await syncUnitMasteryFromTopics();
    return (await activeSyllabus())!;
  }

  Future<void> clearSyllabus() async {
    await _db.writeTxn(() async {
      await _db.syllabusUnits.clear();
      await _db.syllabus.clear();
    });
  }

  /// Creates or refreshes career skills from goal topic strings for [roleTitle].
  Future<List<CareerSkill>> bootstrapCareerSkills({
    required String roleTitle,
    required List<String> skills,
    String category = 'technical',
    double targetLevel = 0.8,
  }) async {
    final cleaned = skills
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final role = roleTitle.trim().isEmpty ? 'Target role' : roleTitle.trim();
    final now = DateTime.now();

    await _db.writeTxn(() async {
      final existing = await _db.careerSkills.where().findAll();
      final byTitle = {
        for (final s in existing) s.title.toLowerCase(): s,
      };

      if (cleaned.isEmpty) {
        if (existing.isEmpty) {
          final skill = CareerSkill()
            ..uuid = _uuid.v4()
            ..roleTitle = role
            ..title = role
            ..category = category
            ..targetLevel = targetLevel
            ..currentLevel = 0.0
            ..evidenceTopic = role
            ..orderIndex = 0
            ..weight = 1.0
            ..updatedAt = now;
          await _db.careerSkills.put(skill);
        } else {
          for (final s in existing) {
            s.roleTitle = role;
            s.updatedAt = now;
            await _db.careerSkills.put(s);
          }
        }
        return;
      }

      final keep = <String>{};
      for (var i = 0; i < cleaned.length; i++) {
        final name = cleaned[i];
        keep.add(name.toLowerCase());
        final prior = byTitle[name.toLowerCase()];
        if (prior != null) {
          prior
            ..roleTitle = role
            ..orderIndex = i
            ..evidenceTopic = name
            ..targetLevel = targetLevel
            ..weight = 1.0
            ..updatedAt = now;
          await _db.careerSkills.put(prior);
        } else {
          final skill = CareerSkill()
            ..uuid = _uuid.v4()
            ..roleTitle = role
            ..title = name
            ..category = category
            ..targetLevel = targetLevel
            ..currentLevel = 0.0
            ..evidenceTopic = name
            ..orderIndex = i
            ..weight = 1.0
            ..updatedAt = now;
          await _db.careerSkills.put(skill);
        }
      }

      for (final s in existing) {
        if (!keep.contains(s.title.toLowerCase())) {
          await _db.careerSkills.delete(s.id);
        }
      }
    });

    // Do not sync from quiz topic strength — readiness advances via path modules only.
    return allCareerSkills();
  }

  Future<void> clearCareerSkills() async {
    await _db.writeTxn(() async {
      await _db.careerSkills.clear();
    });
  }

  /// Seeds syllabus units from GoalAgent v2 JSON (weighted units + topic keys).
  Future<int> seedSyllabusFromAgent({
    required String title,
    required List<AgentSyllabusUnitSeed> units,
    DateTime? examDate,
    String source = 'agent',
  }) async {
    final cleaned = units.where((u) => u.title.isNotEmpty).toList();
    if (cleaned.isEmpty) return 0;

    var weightSum = cleaned.fold<double>(0, (sum, u) => sum + u.weight);
    if (weightSum <= 0) weightSum = cleaned.length.toDouble();

    final displayTitle = title.trim().isEmpty ? 'Exam syllabus' : title.trim();
    var syllabus = await activeSyllabus();
    final now = DateTime.now();

    await _db.writeTxn(() async {
      if (syllabus == null) {
        syllabus = Syllabus()
          ..uuid = _uuid.v4()
          ..title = displayTitle
          ..examDate = examDate
          ..source = source
          ..createdAt = now
          ..updatedAt = now;
        await _db.syllabus.put(syllabus!);
      } else {
        syllabus!
          ..title = displayTitle
          ..examDate = examDate
          ..source = source
          ..updatedAt = now;
        await _db.syllabus.put(syllabus!);
      }

      final existing = await _db.syllabusUnits
          .filter()
          .syllabusUuidEqualTo(syllabus!.uuid)
          .findAll();
      final byTitle = {for (final u in existing) u.title.toLowerCase(): u};
      final keepTitles = <String>{};

      for (var i = 0; i < cleaned.length; i++) {
        final seed = cleaned[i];
        keepTitles.add(seed.title.toLowerCase());
        final topics = seed.topics.isNotEmpty ? seed.topics : [seed.title];
        final weight = seed.weight / weightSum;
        final prior = byTitle[seed.title.toLowerCase()];
        if (prior != null) {
          prior
            ..orderIndex = i
            ..weight = weight
            ..topicKeysJson = jsonEncode(topics)
            ..mastery = prior.mastery > 0 ? prior.mastery : 0.0
            ..updatedAt = now;
          await _db.syllabusUnits.put(prior);
        } else {
          final unit = SyllabusUnit()
            ..uuid = _uuid.v4()
            ..syllabusUuid = syllabus!.uuid
            ..title = seed.title
            ..orderIndex = i
            ..weight = weight
            ..mastery = 0.0
            ..topicKeysJson = jsonEncode(topics)
            ..updatedAt = now;
          await _db.syllabusUnits.put(unit);
        }
      }

      for (final u in existing) {
        if (!keepTitles.contains(u.title.toLowerCase())) {
          await _db.syllabusUnits.delete(u.id);
        }
      }
    });

    // Start at 0% coverage; mastery rises from practice, not AI seed guesses.
    return cleaned.length;
  }

  /// Seeds career skills from GoalAgent v2 JSON.
  Future<int> seedCareerSkillsFromAgent({
    required String roleTitle,
    required List<AgentCareerSkillSeed> skills,
    String source = 'agent',
  }) async {
    final cleaned = skills.where((s) => s.title.isNotEmpty).toList();
    if (cleaned.isEmpty) return 0;

    final role = roleTitle.trim().isEmpty ? 'Target role' : roleTitle.trim();
    final now = DateTime.now();

    await _db.writeTxn(() async {
      final existing = await _db.careerSkills.where().findAll();
      final byTitle = {for (final s in existing) s.title.toLowerCase(): s};
      final keep = <String>{};

      for (var i = 0; i < cleaned.length; i++) {
        final seed = cleaned[i];
        keep.add(seed.title.toLowerCase());
        final evidence = seed.topics.isNotEmpty ? seed.topics.first : seed.title;
        final prior = byTitle[seed.title.toLowerCase()];
        if (prior != null) {
          prior
            ..roleTitle = role
            ..orderIndex = i
            ..category = seed.category
            ..targetLevel = seed.targetLevel
            ..currentLevel = prior.currentLevel > 0 ? prior.currentLevel : 0.0
            ..evidenceTopic = evidence
            ..weight = 1.0
            ..updatedAt = now;
          await _db.careerSkills.put(prior);
        } else {
          final skill = CareerSkill()
            ..uuid = _uuid.v4()
            ..roleTitle = role
            ..title = seed.title
            ..category = seed.category
            ..targetLevel = seed.targetLevel
            ..currentLevel = 0.0
            ..evidenceTopic = evidence
            ..orderIndex = i
            ..weight = 1.0
            ..updatedAt = now;
          await _db.careerSkills.put(skill);
        }
      }

      for (final s in existing) {
        if (!keep.contains(s.title.toLowerCase())) {
          await _db.careerSkills.delete(s.id);
        }
      }
    });

    // Path-module completion advances levels — not quiz topic sync.
    return cleaned.length;
  }

  Future<CareerSkill> upsertCareerSkill({
    String? uuid,
    required String roleTitle,
    required String title,
    String category = 'technical',
    double targetLevel = 0.8,
    double? currentLevel,
    String? evidenceTopic,
    double weight = 1.0,
  }) async {
    final now = DateTime.now();
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Skill title is required');
    }
    final role = roleTitle.trim().isEmpty ? 'Target role' : roleTitle.trim();
    final evidence = (evidenceTopic ?? cleanTitle).trim();

    late CareerSkill skill;
    await _db.writeTxn(() async {
      CareerSkill? existing;
      if (uuid != null) {
        existing = await _db.careerSkills.filter().uuidEqualTo(uuid).findFirst();
      }
      if (existing == null) {
        final all = await _db.careerSkills.where().findAll();
        skill = CareerSkill()
          ..uuid = _uuid.v4()
          ..roleTitle = role
          ..title = cleanTitle
          ..category = category
          ..targetLevel = targetLevel.clamp(0.1, 1.0)
          ..currentLevel = (currentLevel ?? 0.0).clamp(0.0, 1.0)
          ..evidenceTopic = evidence
          ..orderIndex = all.length
          ..weight = weight
          ..updatedAt = now;
      } else {
        skill = existing
          ..roleTitle = role
          ..title = cleanTitle
          ..category = category
          ..targetLevel = targetLevel.clamp(0.1, 1.0)
          ..evidenceTopic = evidence
          ..weight = weight
          ..updatedAt = now;
        if (currentLevel != null) {
          skill.currentLevel = currentLevel.clamp(0.0, 1.0);
        }
      }
      await _db.careerSkills.put(skill);
    });
    return skill;
  }

  Future<void> deleteCareerSkill(String uuid) async {
    await _db.writeTxn(() async {
      final skill = await _db.careerSkills.filter().uuidEqualTo(uuid).findFirst();
      if (skill != null) await _db.careerSkills.delete(skill.id);
    });
  }

  Future<List<String>> interviewDrillThemes({int limit = 6}) async {
    final skills = await allCareerSkills();
    if (skills.isEmpty) {
      return const [
        'Behavioral leadership',
        'System design',
        'Problem solving',
      ];
    }
    final gaps = [...skills]..sort((a, b) {
        final ta = a.targetLevel <= 0 ? 0.8 : a.targetLevel;
        final tb = b.targetLevel <= 0 ? 0.8 : b.targetLevel;
        return (tb - b.currentLevel).compareTo(ta - a.currentLevel);
      });
    return gaps.take(limit).map((s) => s.title).toList();
  }

  /// Pulls TopicNode.strength into unit.mastery for matching topic keys.
  Future<void> syncUnitMasteryFromTopics() async {
    final syllabus = await activeSyllabus();
    if (syllabus == null) return;
    final units = await unitsFor(syllabus.uuid);
    final now = DateTime.now();

    await _db.writeTxn(() async {
      for (final unit in units) {
        final keys = _decodeTopics(unit.topicKeysJson);
        if (keys.isEmpty) continue;
        double sum = 0;
        var n = 0;
        DateTime? lastSeen;
        for (final key in keys) {
          final node = await _db.topicNodes
              .filter()
              .topicEqualTo(key, caseSensitive: false)
              .findFirst();
          if (node == null) continue;
          sum += node.strength.clamp(0.0, 1.0);
          n++;
          if (node.lastSeenAt != null &&
              (lastSeen == null || node.lastSeenAt!.isAfter(lastSeen))) {
            lastSeen = node.lastSeenAt;
          }
        }
        if (n > 0) {
          unit.mastery = sum / n;
          unit.lastPracticedAt = lastSeen;
          unit.updatedAt = now;
          await _db.syllabusUnits.put(unit);
        }
      }
    });
  }

  Future<void> syncSkillLevelsFromTopics() async {
    final skills = await allCareerSkills();
    final now = DateTime.now();

    await _db.writeTxn(() async {
      for (final skill in skills) {
        final node = await _db.topicNodes
            .filter()
            .topicEqualTo(skill.evidenceTopic, caseSensitive: false)
            .findFirst();
        if (node == null) continue;
        skill.currentLevel = node.strength.clamp(0.0, 1.0);
        skill.updatedAt = now;
        await _db.careerSkills.put(skill);
      }
    });
  }

  /// Weighted syllabus coverage 0 - 100.
  Future<int> syllabusCoveragePercent() async {
    await syncUnitMasteryFromTopics();
    final syllabus = await activeSyllabus();
    if (syllabus == null) return 0;
    final units = await unitsFor(syllabus.uuid);
    if (units.isEmpty) return 0;
    var wSum = 0.0;
    var weighted = 0.0;
    for (final u in units) {
      final w = u.weight <= 0 ? 1.0 : u.weight;
      wSum += w;
      weighted += w * u.mastery.clamp(0.0, 1.0);
    }
    if (wSum <= 0) return 0;
    return ((weighted / wSum) * 100).round().clamp(0, 100);
  }

  /// One-time fix: zero inflated career/exam progress so readiness starts at 0%.
  /// Does not delete skills/units or change learning-path progress.
  Future<void> resetAllProgressLevelsToZero() async {
    final now = DateTime.now();
    await _db.writeTxn(() async {
      final skills = await _db.careerSkills.where().findAll();
      for (final skill in skills) {
        if (skill.currentLevel == 0.0) continue;
        skill.currentLevel = 0.0;
        skill.updatedAt = now;
        await _db.careerSkills.put(skill);
      }
      final units = await _db.syllabusUnits.where().findAll();
      for (final unit in units) {
        if (unit.mastery == 0.0) continue;
        unit.mastery = 0.0;
        unit.updatedAt = now;
        await _db.syllabusUnits.put(unit);
      }
    });
  }

  /// Weighted career readiness 0 - 100 from stored skill levels only
  /// (advanced by learning-path module completion, not quiz topic sync).
  Future<int> careerReadinessPercent() async {
    final skills = await allCareerSkills();
    if (skills.isEmpty) return 0;
    var wSum = 0.0;
    var weighted = 0.0;
    for (final s in skills) {
      final target = s.targetLevel <= 0 ? 0.8 : s.targetLevel;
      final w = s.weight <= 0 ? 1.0 : s.weight;
      wSum += w;
      weighted += w * (s.currentLevel / target).clamp(0.0, 1.0);
    }
    if (wSum <= 0) return 0;
    return ((weighted / wSum) * 100).round().clamp(0, 100);
  }

  Future<List<String>> topGapSkillTitles({int limit = 3}) async {
    final skills = await allCareerSkills();
    final scored = skills.map((s) {
      final target = s.targetLevel <= 0 ? 0.8 : s.targetLevel;
      final gap = (target - s.currentLevel).clamp(0.0, 1.0);
      return (title: s.title, gap: gap);
    }).toList()
      ..sort((a, b) => b.gap.compareTo(a.gap));
    return scored
        .where((e) => e.gap > 0.05)
        .take(limit)
        .map((e) => e.title)
        .toList();
  }

  /// Bump career skills related to a completed path module toward target.
  Future<void> advanceSkillsForPathModule({
    required String moduleTitle,
    int pathModuleCount = 6,
  }) async {
    final title = moduleTitle.trim().toLowerCase();
    if (title.isEmpty) return;
    final skills = await allCareerSkills();
    if (skills.isEmpty) return;
    final step = (1.0 / pathModuleCount.clamp(1, 20)).clamp(0.05, 0.25);
    final now = DateTime.now();
    final tokens = title
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 3)
        .toSet();

    await _db.writeTxn(() async {
      for (final skill in skills) {
        final hay = '${skill.title} ${skill.evidenceTopic}'.toLowerCase();
        final match = tokens.any((t) => hay.contains(t)) ||
            hay.split(RegExp(r'[^a-z0-9]+')).any((t) => title.contains(t) && t.length >= 3);
        if (!match) continue;
        final target = skill.targetLevel <= 0 ? 0.8 : skill.targetLevel;
        skill.currentLevel = (skill.currentLevel + step * target).clamp(0.0, target);
        skill.updatedAt = now;
        await _db.careerSkills.put(skill);
      }
    });
  }

  /// After a quiz/mock on [practicedTopics], bump matching unit mastery
  /// and topic nodes so dashboard coverage moves even when the session
  /// topic is a combined label (e.g. "Mock: A · B").
  Future<void> applyPracticeEvidence({
    required List<String> practicedTopics,
    required double accuracyRatio,
  }) async {
    final cleaned = practicedTopics
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) return;

    final now = DateTime.now();
    final delta = ((accuracyRatio.clamp(0.0, 1.0) - 0.5) * 0.2).clamp(-0.1, 0.15);

    await _db.writeTxn(() async {
      for (final topic in cleaned) {
        var node = await _db.topicNodes
            .filter()
            .topicEqualTo(topic, caseSensitive: false)
            .findFirst();
        if (node == null) {
          node = TopicNode()
            ..topic = topic
            ..strength = accuracyRatio.clamp(0.0, 1.0)
            ..attempts = 1
            ..correctCount = accuracyRatio >= 0.5 ? 1 : 0
            ..totalTimeSeconds = 0
            ..lastSeenAt = now
            ..updatedAt = now;
        } else {
          node
            ..strength = (node.strength + delta).clamp(0.0, 1.0)
            ..attempts = node.attempts + 1
            ..correctCount = node.correctCount + (accuracyRatio >= 0.5 ? 1 : 0)
            ..lastSeenAt = now
            ..updatedAt = now;
        }
        await _db.topicNodes.put(node);
      }
    });

    final syllabus = await activeSyllabus();
    if (syllabus != null) {
      final units = await unitsFor(syllabus.uuid);
      final lower = cleaned.map((e) => e.toLowerCase()).toSet();
      await _db.writeTxn(() async {
        for (final unit in units) {
          final keys = _decodeTopics(unit.topicKeysJson);
          final hit = keys.any((k) => lower.contains(k.toLowerCase())) ||
              lower.contains(unit.title.toLowerCase());
          if (!hit) continue;
          unit.mastery = (unit.mastery + delta.abs() + 0.05).clamp(0.0, 1.0);
          if (accuracyRatio < 0.45) {
            unit.mastery = (unit.mastery - 0.03).clamp(0.0, 1.0);
          }
          unit.lastPracticedAt = now;
          unit.updatedAt = now;
          await _db.syllabusUnits.put(unit);
        }
      });
    }

    final skills = await allCareerSkills();
    if (skills.isNotEmpty) {
      final lower = cleaned.map((e) => e.toLowerCase()).toSet();
      await _db.writeTxn(() async {
        for (final skill in skills) {
          if (!lower.contains(skill.evidenceTopic.toLowerCase()) &&
              !lower.contains(skill.title.toLowerCase())) {
            continue;
          }
          skill.currentLevel =
              (skill.currentLevel + delta + (accuracyRatio >= 0.6 ? 0.05 : 0))
                  .clamp(0.0, 1.0);
          skill.updatedAt = now;
          await _db.careerSkills.put(skill);
        }
      });
    }
  }

  Future<List<String>> weakUnitTitles({int limit = 3}) async {
    await syncUnitMasteryFromTopics();
    final syllabus = await activeSyllabus();
    if (syllabus == null) return [];
    final units = await unitsFor(syllabus.uuid);
    final sorted = [...units]..sort((a, b) {
        final wa = a.weight <= 0 ? 1.0 : a.weight;
        final wb = b.weight <= 0 ? 1.0 : b.weight;
        return (wa * (1 - a.mastery)).compareTo(wb * (1 - b.mastery)) * -1;
      });
    return sorted
        .where((u) => u.mastery < 0.7)
        .take(limit)
        .map((u) => u.title)
        .toList();
  }

  List<String> _decodeTopics(String json) {
    try {
      final list = jsonDecode(json);
      if (list is! List) return [];
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _weekStart(DateTime anchor) {
    final d = _dateOnly(anchor);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  Future<void> clearStudyPlan() async {
    await _db.writeTxn(() async {
      await _db.studyPlanItems.clear();
    });
  }

  /// Builds day-by-day plan from today until the day before [examDate].
  Future<void> regenerateStudyPlan({
    required DateTime examDate,
    required int dailyMinutes,
  }) async {
    final syllabus = await activeSyllabus();
    if (syllabus == null) return;

    final units = await unitsFor(syllabus.uuid);
    if (units.isEmpty) return;

    final today = _dateOnly(DateTime.now());
    final examDay = _dateOnly(examDate);
    if (!examDay.isAfter(today)) {
      await clearStudyPlan();
      return;
    }

    final priorCompleted = <String, int>{};
    final existing = await _db.studyPlanItems.where().findAll();
    for (final item in existing) {
      final key = '${_dateOnly(item.calendarDay).toIso8601String()}|${item.unitUuid}|${item.kind}';
      priorCompleted[key] = item.completedMinutes;
    }

    await clearStudyPlan();

    final sortedUnits = [...units]..sort((a, b) {
        final wa = a.weight <= 0 ? 1.0 : a.weight;
        final wb = b.weight <= 0 ? 1.0 : b.weight;
        final ga = wa * (1 - a.mastery.clamp(0.0, 1.0));
        final gb = wb * (1 - b.mastery.clamp(0.0, 1.0));
        return gb.compareTo(ga);
      });

    final minutes = dailyMinutes.clamp(5, 120);
    final items = <StudyPlanItem>[];
    var day = today;
    var dayIndex = 0;

    while (day.isBefore(examDay) && dayIndex < 120) {
      final daysLeft = examDay.difference(day).inDays;
      final unit = sortedUnits[dayIndex % sortedUnits.length];

      late final String kind;
      late final int planned;
      if (daysLeft <= 14 && day.weekday == DateTime.saturday) {
        kind = 'mock';
        planned = (minutes * 1.5).round().clamp(minutes, 120);
      } else if (daysLeft <= 7 && dayIndex % 4 == 3) {
        kind = 'review';
        planned = minutes;
      } else {
        kind = 'study';
        planned = minutes;
      }

      final key = '${day.toIso8601String()}|${unit.uuid}|$kind';
      items.add(
        StudyPlanItem()
          ..uuid = _uuid.v4()
          ..syllabusUuid = syllabus.uuid
          ..calendarDay = day
          ..unitUuid = unit.uuid
          ..plannedMinutes = planned
          ..completedMinutes = priorCompleted[key] ?? 0
          ..kind = kind
          ..updatedAt = DateTime.now(),
      );

      day = day.add(const Duration(days: 1));
      dayIndex++;
    }

    await _db.writeTxn(() async {
      await _db.studyPlanItems.putAll(items);
    });
  }

  Future<List<StudyPlanItem>> planForRange(DateTime start, DateTime end) async {
    final from = _dateOnly(start);
    final to = _dateOnly(end);
    final all = await _db.studyPlanItems.where().sortByCalendarDay().findAll();
    return all
        .where((i) {
          final d = _dateOnly(i.calendarDay);
          return !d.isBefore(from) && !d.isAfter(to);
        })
        .toList();
  }

  Future<List<StudyPlanItem>> currentWeekPlan() async {
    final start = _weekStart(DateTime.now());
    return planForRange(start, start.add(const Duration(days: 6)));
  }

  Future<List<StudyPlanItem>> upcomingMockPlanItems({int limit = 3}) async {
    final today = _dateOnly(DateTime.now());
    final all = await _db.studyPlanItems.where().sortByCalendarDay().findAll();
    return all
        .where((i) => i.kind == 'mock' && !_dateOnly(i.calendarDay).isBefore(today))
        .take(limit)
        .toList();
  }

  Future<void> creditStudyMinutes({
    required DateTime when,
    required int minutes,
    String? preferredKind,
  }) async {
    if (minutes <= 0) return;
    final day = _dateOnly(when);
    final items = await planForRange(day, day);
    if (items.isEmpty) return;

    StudyPlanItem? target;
    if (preferredKind != null) {
      target = items.where((i) => i.kind == preferredKind).firstOrNull;
    }
    target ??= items.first;

    target.completedMinutes = (target.completedMinutes + minutes).clamp(0, 9999);
    target.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.studyPlanItems.put(target!);
    });
  }

  Future<List<String>> studyPlanFocusTitles({int limit = 3}) async {
    final items = await currentWeekPlan();
    if (items.isEmpty) return [];

    final syllabus = await activeSyllabus();
    if (syllabus == null) return [];

    final units = await unitsFor(syllabus.uuid);
    final byUuid = {for (final u in units) u.uuid: u};

    final titles = <String>[];
    for (final item in items) {
      if (item.kind == 'mock') continue;
      final unit = item.unitUuid == null ? null : byUuid[item.unitUuid];
      final title = unit?.title;
      if (title != null && title.isNotEmpty && !titles.contains(title)) {
        titles.add(title);
      }
      if (titles.length >= limit) break;
    }
    return titles;
  }
}

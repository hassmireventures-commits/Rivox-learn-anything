import 'package:isar_community/isar.dart';

import '../isar_service.dart';
import '../models/career_skill.dart';
import '../models/study_plan_item.dart';
import '../models/syllabus.dart';
import '../models/syllabus_unit.dart';

/// Minimal repository for `Syllabus`/`SyllabusUnit`/`CareerSkill`/
/// `StudyPlanItem` — these four collections had no dedicated repository
/// before B13 cloud backup (Phase 2). Intentionally read-only/export-only:
/// no CRUD here, only what's needed to back up this data. Full CRUD for
/// these collections happens elsewhere in the app today (wherever creates
/// them); this repository exists solely so `CloudBackupService` has a single
/// place to pull all four for the backup manifest.
class StudyRepository {
  StudyRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  /// All syllabus/study-plan/career-skill data, for B13 cloud backup (Phase 2).
  Future<Map<String, dynamic>> exportStudyData() async {
    final syllabi = await _db.syllabus.where().findAll();
    final units = await _db.syllabusUnits.where().findAll();
    final skills = await _db.careerSkills.where().findAll();
    final items = await _db.studyPlanItems.where().findAll();

    return {
      'syllabi': syllabi
          .map((s) => {
                'uuid': s.uuid,
                'title': s.title,
                'examDate': s.examDate?.toIso8601String(),
                'source': s.source,
                'createdAt': s.createdAt.toIso8601String(),
                'updatedAt': s.updatedAt.toIso8601String(),
              })
          .toList(),
      'syllabusUnits': units
          .map((u) => {
                'uuid': u.uuid,
                'syllabusUuid': u.syllabusUuid,
                'title': u.title,
                'orderIndex': u.orderIndex,
                'weight': u.weight,
                'mastery': u.mastery,
                'lastPracticedAt': u.lastPracticedAt?.toIso8601String(),
                'pathId': u.pathId,
                'topicKeysJson': u.topicKeysJson,
                'updatedAt': u.updatedAt.toIso8601String(),
              })
          .toList(),
      'careerSkills': skills
          .map((s) => {
                'uuid': s.uuid,
                'roleTitle': s.roleTitle,
                'title': s.title,
                'category': s.category,
                'targetLevel': s.targetLevel,
                'currentLevel': s.currentLevel,
                'evidenceTopic': s.evidenceTopic,
                'orderIndex': s.orderIndex,
                'weight': s.weight,
                'updatedAt': s.updatedAt.toIso8601String(),
              })
          .toList(),
      'studyPlanItems': items
          .map((i) => {
                'uuid': i.uuid,
                'syllabusUuid': i.syllabusUuid,
                'calendarDay': i.calendarDay.toIso8601String(),
                'unitUuid': i.unitUuid,
                'plannedMinutes': i.plannedMinutes,
                'completedMinutes': i.completedMinutes,
                'kind': i.kind,
                'updatedAt': i.updatedAt.toIso8601String(),
              })
          .toList(),
    };
  }

  /// Replaces all syllabus/study-plan/career-skill data from a B13
  /// cloud-backup manifest (Phase 3 restore). Caller is responsible for
  /// clearing existing rows first (see `IsarService.clearBackupInScopeData`)
  /// — this only writes.
  Future<void> importStudyData(Map<String, dynamic> data) async {
    final syllabi = ((data['syllabi'] as List?) ?? []).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return Syllabus()
        ..uuid = m['uuid'] as String
        ..title = m['title'] as String
        ..examDate = m['examDate'] != null ? DateTime.parse(m['examDate'] as String) : null
        ..source = m['source'] as String
        ..createdAt = DateTime.parse(m['createdAt'] as String)
        ..updatedAt = DateTime.parse(m['updatedAt'] as String);
    }).toList();

    final units = ((data['syllabusUnits'] as List?) ?? []).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return SyllabusUnit()
        ..uuid = m['uuid'] as String
        ..syllabusUuid = m['syllabusUuid'] as String
        ..title = m['title'] as String
        ..orderIndex = m['orderIndex'] as int
        ..weight = (m['weight'] as num).toDouble()
        ..mastery = (m['mastery'] as num).toDouble()
        ..lastPracticedAt =
            m['lastPracticedAt'] != null ? DateTime.parse(m['lastPracticedAt'] as String) : null
        ..pathId = m['pathId'] as String?
        ..topicKeysJson = m['topicKeysJson'] as String
        ..updatedAt = DateTime.parse(m['updatedAt'] as String);
    }).toList();

    final skills = ((data['careerSkills'] as List?) ?? []).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return CareerSkill()
        ..uuid = m['uuid'] as String
        ..roleTitle = m['roleTitle'] as String
        ..title = m['title'] as String
        ..category = m['category'] as String
        ..targetLevel = (m['targetLevel'] as num).toDouble()
        ..currentLevel = (m['currentLevel'] as num).toDouble()
        ..evidenceTopic = m['evidenceTopic'] as String
        ..orderIndex = m['orderIndex'] as int
        ..weight = (m['weight'] as num).toDouble()
        ..updatedAt = DateTime.parse(m['updatedAt'] as String);
    }).toList();

    final items = ((data['studyPlanItems'] as List?) ?? []).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return StudyPlanItem()
        ..uuid = m['uuid'] as String
        ..syllabusUuid = m['syllabusUuid'] as String
        ..calendarDay = DateTime.parse(m['calendarDay'] as String)
        ..unitUuid = m['unitUuid'] as String?
        ..plannedMinutes = m['plannedMinutes'] as int
        ..completedMinutes = m['completedMinutes'] as int
        ..kind = m['kind'] as String
        ..updatedAt = DateTime.parse(m['updatedAt'] as String);
    }).toList();

    await _db.writeTxn(() async {
      await _db.syllabus.putAll(syllabi);
      await _db.syllabusUnits.putAll(units);
      await _db.careerSkills.putAll(skills);
      await _db.studyPlanItems.putAll(items);
    });
  }
}

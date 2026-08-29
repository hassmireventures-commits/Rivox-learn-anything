import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/ai_audit_event.dart';
import 'models/ai_provider_config.dart';
import 'models/ai_usage_daily.dart';
import 'models/app_settings.dart';
import 'models/career_skill.dart';
import 'models/daily_stat.dart';
import 'models/document_chunk.dart';
import 'models/embedding_chunk.dart';
import 'models/flashcard.dart';
import 'models/knowledge_source.dart';
import 'models/health_snapshot.dart';
import 'models/learner_profile.dart';
import 'models/learning_path.dart';
import 'models/model_weights.dart';
import 'models/prompt_strategy.dart';
import 'models/question.dart';
import 'models/quiz_session.dart';
import 'models/recommendation.dart';
import 'models/study_plan_item.dart';
import 'models/syllabus.dart';
import 'models/syllabus_unit.dart';
import 'models/telemetry_event.dart';
import 'models/topic_edge.dart';
import 'models/topic_node.dart';
import 'models/user_profile.dart';
import 'models/user_website.dart';

class IsarService {
  IsarService._();
  static IsarService? _instance;
  static IsarService get instance => _instance ??= IsarService._();

  /// Bump when making additive schema changes; pair with [_runMigrations].
  static const int schemaVersion = 1;

  Isar? _isar;
  Isar get db {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar has not been initialized. Call IsarService.init() first.');
    }
    return isar;
  }

  Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    await _ensureSchemaVersion(dir.path);
    _isar = await Isar.open(
      [
        UserProfileSchema,
        AppSettingsSchema,
        AiProviderConfigSchema,
        QuizSessionSchema,
        QuestionSchema,
        DailyStatSchema,
        LearnerProfileSchema,
        TelemetryEventSchema,
        TopicNodeSchema,
        TopicEdgeSchema,
        LearningPathSchema,
        RecommendationItemSchema,
        PromptStrategySchema,
        ModelWeightsSchema,
        EmbeddingChunkSchema,
        HealthSnapshotSchema,
        SyllabusSchema,
        SyllabusUnitSchema,
        CareerSkillSchema,
        StudyPlanItemSchema,
        AiAuditEventSchema,
        AiUsageDailySchema,
        KnowledgeSourceSchema,
        DocumentChunkSchema,
        UserWebsiteSchema,
        FlashcardSchema,
      ],
      directory: dir.path,
      name: 'learn_anything_db',
    );
  }

  /// Records schema version beside the DB. Additive-only migrations go in
  /// [_runMigrations]; destructive wipes are debug-only last resorts.
  Future<void> _ensureSchemaVersion(String directoryPath) async {
    final file = File('$directoryPath/isar_schema_version.txt');
    if (!file.existsSync()) {
      await file.writeAsString('$schemaVersion');
      return;
    }
    final current = int.tryParse((await file.readAsString()).trim()) ?? 0;
    if (current > schemaVersion) {
      throw StateError(
        'Isar schema version $current is newer than app version $schemaVersion. '
        'Upgrade the app.',
      );
    }
    if (current < schemaVersion) {
      await _runMigrations(from: current, to: schemaVersion);
      await file.writeAsString('$schemaVersion');
    }
  }

  Future<void> _runMigrations({required int from, required int to}) async {
    // Placeholder for additive migrations (from < n <= to).
    // Example: if (from < 2 && to >= 2) { ... }
  }

  Future<void> clearAll() async {
    await db.writeTxn(() async {
      await db.clear();
    });
  }

  Future<void> clearLearningData() async {
    await db.writeTxn(() async {
      await db.quizSessions.clear();
      await db.questions.clear();
      await db.learningPaths.clear();
      await db.dailyStats.clear();
      await db.topicNodes.clear();
      await db.topicEdges.clear();
      await db.recommendationItems.clear();
      await db.embeddingChunks.clear();
      await db.telemetryEvents.clear();
      await db.modelWeights.clear();
      await db.healthSnapshots.clear();
      await db.learnerProfiles.clear();
      await db.syllabus.clear();
      await db.syllabusUnits.clear();
      await db.careerSkills.clear();
      await db.studyPlanItems.clear();
      await db.aiAuditEvents.clear();
      await db.aiUsageDailys.clear();
      await db.knowledgeSources.clear();
      await db.documentChunks.clear();
      await db.userWebsites.clear();
      await db.flashcards.clear();
    });
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

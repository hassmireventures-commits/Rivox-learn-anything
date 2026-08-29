import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../remote/ai/models/generated_quiz.dart';
import '../../remote/ai/models/quiz_generation_request.dart';
import '../isar_service.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';

class QuizRepository {
  QuizRepository(this._isarService);

  final IsarService _isarService;
  final _uuid = const Uuid();

  Isar get _db => _isarService.db;

  Future<QuizSession> saveGeneratedQuiz({
    required QuizGenerationRequest request,
    required GeneratedQuiz generated,
    String source = 'solo',
    String? roomId,
    String quizKind = QuizKind.quick,
    String? pathId,
    int? moduleIndex,
    int? promptTokens,
    int? completionTokens,
    int? examDurationSeconds,
    int? passPercent,
    String? syllabusUuid,
    List<String>? unitFilter,
    int? attemptNumber,
    List<String> citationChunkIds = const [],
  }) async {
    final quizUuid = _uuid.v4();
    final session = QuizSession()
      ..uuid = quizUuid
      ..topic = request.topic
      ..difficulty = request.difficulty
      ..questionType = request.questionType
      ..questionCount = generated.questions.length
      // Mocks use a global exam timer - skip per-question countdown.
      ..timerSeconds = examDurationSeconds != null ? null : request.timerSeconds
      ..language = request.language
      ..randomizeQuestions = request.randomizeQuestions
      ..randomizeOptions = request.randomizeOptions
      ..generateExplanations = request.generateExplanations
      ..startedAt = DateTime.now()
      ..source = source
      ..quizKind = quizKind
      ..roomId = roomId
      ..pathId = pathId
      ..moduleIndex = moduleIndex
      ..promptTokens = promptTokens
      ..completionTokens = completionTokens
      ..examDurationSeconds = examDurationSeconds
      ..passPercent = passPercent
      ..syllabusUuid = syllabusUuid
      ..unitFilterJson =
          unitFilter == null ? null : jsonEncode(unitFilter)
      ..attemptNumber = attemptNumber
      ..citationChunkIdsJson =
          citationChunkIds.isEmpty ? null : jsonEncode(citationChunkIds);

    final questions = <Question>[];
    var questionsData = List<GeneratedQuestion>.from(generated.questions);
    if (request.randomizeQuestions) {
      questionsData.shuffle();
    }

    for (var i = 0; i < questionsData.length; i++) {
      final q = questionsData[i];
      var options = List<String>.from(q.options);
      var correctIndex = options.isEmpty
          ? 0
          : q.correctIndex.clamp(0, options.length - 1);

      // Expand letter-only MCQ options so Results never show bare "A"/"B".
      if (_isLetterOnlyOptions(options)) {
        options = [
          for (var o = 0; o < options.length; o++)
            'Option ${String.fromCharCode(65 + o)}',
        ];
      }

      // Unique options before shuffle so indexOf cannot bind the wrong duplicate.
      final normalized = _uniqueOptionsPreservingCorrect(options, correctIndex);
      options = normalized.options;
      correctIndex = normalized.correctIndex;

      if (_requiresChoiceOptions(q.type)) {
        options = ensureMinChoiceOptions(options);
        correctIndex = correctIndex.clamp(0, options.length - 1);
      }

      if (request.randomizeOptions && options.length > 1) {
        final correct = options[correctIndex];
        options = List<String>.from(options)..shuffle();
        correctIndex = options.indexOf(correct);
      }

      questions.add(
        Question()
          ..quizUuid = quizUuid
          ..orderIndex = i
          ..text = q.text
          ..optionsJson = jsonEncode(options)
          ..correctIndex = correctIndex
          ..explanation = q.explanation
          ..referencesJson = q.referencesJson
          ..type = q.type
          ..rubricJson = (q.type == 'short_answer' || q.type == 'behavioral')
              ? q.explanation
              : null,
      );
    }

    session.questionCount = questions.length;

    await _db.writeTxn(() async {
      await _db.quizSessions.put(session);
      await _db.questions.putAll(questions);
    });

    return session;
  }

  Future<QuizSession?> getSession(String uuid) async {
    return _db.quizSessions.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<List<Question>> getQuestions(String quizUuid) async {
    return _db.questions.filter().quizUuidEqualTo(quizUuid).sortByOrderIndex().findAll();
  }

  /// All-time wrongly-answered questions (most-recent quiz first), for
  /// building spaced-repetition flashcards from mistake history.
  Future<List<Question>> getWrongQuestions({int limit = 20}) async {
    final wrong = await _db.questions.filter().isCorrectEqualTo(false).findAll();
    if (wrong.isEmpty) return wrong;

    final quizUuids = wrong.map((q) => q.quizUuid).toSet();
    final completedAtByQuiz = <String, DateTime?>{};
    for (final uuid in quizUuids) {
      completedAtByQuiz[uuid] = (await getSession(uuid))?.completedAt;
    }

    wrong.sort((a, b) {
      final da = completedAtByQuiz[a.quizUuid];
      final db2 = completedAtByQuiz[b.quizUuid];
      if (da != null && db2 != null) return db2.compareTo(da);
      if (da != null) return -1;
      if (db2 != null) return 1;
      return b.id.compareTo(a.id);
    });

    return wrong.take(limit).toList();
  }

  Future<QuizSession> completeQuiz({
    required String quizUuid,
    required List<Question> answeredQuestions,
    required int timeTakenSeconds,
  }) async {
    final session = await getSession(quizUuid);
    if (session == null) throw StateError('Quiz not found');

    final correct = answeredQuestions.where((q) => q.isCorrect == true).length;
    final wrong = answeredQuestions.length - correct;
    final accuracy = answeredQuestions.isEmpty ? 0.0 : (correct / answeredQuestions.length) * 100;

    session
      ..score = correct
      ..correctCount = correct
      ..wrongCount = wrong
      ..accuracy = accuracy
      ..scorePercent = accuracy
      ..timeTakenSeconds = timeTakenSeconds
      ..completedAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.quizSessions.put(session);
      await _db.questions.putAll(answeredQuestions);
    });

    return session;
  }

  /// Completed mock attempts for trend charts (newest first).
  Future<List<QuizSession>> getRecentMocks({
    String? syllabusUuid,
    int limit = 8,
  }) async {
    var results = await _db.quizSessions
        .filter()
        .quizKindEqualTo(QuizKind.mock)
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .findAll();
    if (syllabusUuid != null && syllabusUuid.isNotEmpty) {
      results = results.where((s) => s.syllabusUuid == syllabusUuid).toList();
    }
    return results.take(limit).toList();
  }

  Future<int> nextMockAttemptNumber({String? syllabusUuid}) async {
    final prior = await getRecentMocks(syllabusUuid: syllabusUuid, limit: 1);
    if (prior.isEmpty) return 1;
    return (prior.first.attemptNumber ?? prior.length) + 1;
  }

  Future<List<QuizSession>> getRecent({int limit = 10}) async {
    return _db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<QuizSession?> getLatestCompletedForTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return null;
    return _db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .topicEqualTo(trimmed, caseSensitive: false)
        .sortByCompletedAtDesc()
        .findFirst();
  }

  Future<List<QuizSession>> _filteredHistory({
    String? search,
    String? difficulty,
    String? quizKind,
    DateTime? from,
    DateTime? to,
  }) async {
    var results = await _db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .findAll();

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      results = results.where((s) => s.topic.toLowerCase().contains(q)).toList();
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      results = results.where((s) => s.difficulty == difficulty).toList();
    }
    if (quizKind != null && quizKind.isNotEmpty) {
      results = results.where((s) => s.quizKind == quizKind).toList();
    }
    if (from != null) {
      results = results.where((s) => s.completedAt != null && !s.completedAt!.isBefore(from)).toList();
    }
    if (to != null) {
      results = results.where((s) => s.completedAt != null && !s.completedAt!.isAfter(to)).toList();
    }
    return results;
  }

  Future<int> countHistory({
    String? search,
    String? difficulty,
    String? quizKind,
    DateTime? from,
    DateTime? to,
  }) async {
    final results = await _filteredHistory(
      search: search,
      difficulty: difficulty,
      quizKind: quizKind,
      from: from,
      to: to,
    );
    return results.length;
  }

  Future<List<QuizSession>> getHistory({
    String? search,
    String? difficulty,
    String? quizKind,
    DateTime? from,
    DateTime? to,
    int offset = 0,
    int limit = 20,
  }) async {
    final results = await _filteredHistory(
      search: search,
      difficulty: difficulty,
      quizKind: quizKind,
      from: from,
      to: to,
    );

    if (offset >= results.length) return [];
    final end = (offset + limit).clamp(0, results.length);
    return results.sublist(offset, end);
  }

  Future<QuizSession?> findDailyQuizForDate(DateTime day) async {
    final todays = await listDailyQuizzesForDate(day);
    for (final s in todays) {
      if (s.completedAt == null) return s;
    }
    return todays.isEmpty ? null : todays.last;
  }

  Future<List<QuizSession>> listDailyQuizzesForDate(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final sessions = await _db.quizSessions.where().findAll();
    final todays = <QuizSession>[];
    for (final s in sessions) {
      if (s.quizKind != QuizKind.daily) continue;
      if (!s.startedAt.isBefore(start) && s.startedAt.isBefore(end)) {
        todays.add(s);
      }
    }
    todays.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return todays;
  }

  Future<void> deleteQuiz(String uuid) async {
    final session = await getSession(uuid);
    if (session == null) return;
    final questions = await getQuestions(uuid);
    await _db.writeTxn(() async {
      await _db.quizSessions.delete(session.id);
      await _db.questions.deleteAll(questions.map((q) => q.id).toList());
    });
  }

  Future<void> clearAll() async {
    await _db.writeTxn(() async {
      await _db.quizSessions.clear();
      await _db.questions.clear();
    });
  }

  Future<int> totalCompleted() async {
    return _db.quizSessions.filter().completedAtIsNotNull().count();
  }

  Future<Map<String, dynamic>> exportData() async {
    final sessions = await _db.quizSessions.where().findAll();
    final questions = await _db.questions.where().findAll();
    return {
      'sessions': sessions
          .map((s) => {
                'uuid': s.uuid,
                'topic': s.topic,
                'difficulty': s.difficulty,
                'questionType': s.questionType,
                'questionCount': s.questionCount,
                'timerSeconds': s.timerSeconds,
                'language': s.language,
                'randomizeQuestions': s.randomizeQuestions,
                'randomizeOptions': s.randomizeOptions,
                'generateExplanations': s.generateExplanations,
                'score': s.score,
                'correctCount': s.correctCount,
                'wrongCount': s.wrongCount,
                'accuracy': s.accuracy,
                'timeTakenSeconds': s.timeTakenSeconds,
                'startedAt': s.startedAt.toIso8601String(),
                'completedAt': s.completedAt?.toIso8601String(),
                'source': s.source,
                'quizKind': s.quizKind,
                'roomId': s.roomId,
                'pathId': s.pathId,
                'moduleIndex': s.moduleIndex,
                'promptTokens': s.promptTokens,
                'completionTokens': s.completionTokens,
              })
          .toList(),
      'questions': questions
          .map((q) => {
                'quizUuid': q.quizUuid,
                'orderIndex': q.orderIndex,
                'text': q.text,
                'optionsJson': q.optionsJson,
                'correctIndex': q.correctIndex,
                'explanation': q.explanation,
                'referencesJson': q.referencesJson,
                'type': q.type,
                'userAnswer': q.userAnswer,
                'isCorrect': q.isCorrect,
                'timeSpentMs': q.timeSpentMs,
              })
          .toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final sessionsJson = (data['sessions'] as List?) ?? [];
    final questionsJson = (data['questions'] as List?) ?? [];

    final sessions = sessionsJson.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return QuizSession()
        ..uuid = m['uuid'] as String
        ..topic = m['topic'] as String
        ..difficulty = m['difficulty'] as String
        ..questionType = m['questionType'] as String
        ..questionCount = m['questionCount'] as int
        ..timerSeconds = m['timerSeconds'] as int?
        ..language = m['language'] as String
        ..randomizeQuestions = m['randomizeQuestions'] as bool? ?? false
        ..randomizeOptions = m['randomizeOptions'] as bool? ?? false
        ..generateExplanations = m['generateExplanations'] as bool? ?? true
        ..score = m['score'] as int?
        ..correctCount = m['correctCount'] as int?
        ..wrongCount = m['wrongCount'] as int?
        ..accuracy = (m['accuracy'] as num?)?.toDouble()
        ..timeTakenSeconds = m['timeTakenSeconds'] as int?
        ..startedAt = DateTime.parse(m['startedAt'] as String)
        ..completedAt =
            m['completedAt'] != null ? DateTime.parse(m['completedAt'] as String) : null
        ..source = m['source'] as String? ?? 'solo'
        ..quizKind = m['quizKind'] as String? ?? QuizKind.quick
        ..roomId = m['roomId'] as String?
        ..pathId = m['pathId'] as String?
        ..moduleIndex = m['moduleIndex'] as int?
        ..promptTokens = m['promptTokens'] as int?
        ..completionTokens = m['completionTokens'] as int?;
    }).toList();

    final questions = questionsJson.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return Question()
        ..quizUuid = m['quizUuid'] as String
        ..orderIndex = m['orderIndex'] as int
        ..text = m['text'] as String
        ..optionsJson = m['optionsJson'] as String
        ..correctIndex = m['correctIndex'] as int
        ..explanation = m['explanation'] as String?
        ..referencesJson = m['referencesJson'] as String?
        ..type = m['type'] as String
        ..userAnswer = m['userAnswer'] as String?
        ..isCorrect = m['isCorrect'] as bool?
        ..timeSpentMs = m['timeSpentMs'] as int?;
    }).toList();

    await _db.writeTxn(() async {
      await _db.quizSessions.putAll(sessions);
      await _db.questions.putAll(questions);
    });
  }

  static bool _isLetterOnlyOptions(List<String> options) {
    if (options.length < 2) return false;
    return options.every((o) => RegExp(r'^[A-Da-d]$').hasMatch(o.trim()));
  }

  static bool _requiresChoiceOptions(String type) {
    final t = type.toLowerCase();
    return t != 'short_answer' && t != 'behavioral' && t != 'open';
  }

  /// Pads MCQ/TF options when dedup or bad AI output left too few choices.
  static List<String> ensureMinChoiceOptions(
    List<String> options, {
    int min = 2,
    int target = 4,
  }) {
    if (options.isEmpty || options.length >= min) return options;
    final padded = List<String>.from(options);
    const extras = [
      'None of the above',
      'Not enough information',
      'All of the above',
    ];
    for (final extra in extras) {
      if (padded.length >= target) break;
      final key = extra.toLowerCase();
      if (!padded.any((o) => o.trim().toLowerCase() == key)) {
        padded.add(extra);
      }
    }
    while (padded.length < min) {
      padded.add('Option ${String.fromCharCode(65 + padded.length)}');
    }
    return padded;
  }

  static ({List<String> options, int correctIndex}) _uniqueOptionsPreservingCorrect(
    List<String> options,
    int correctIndex,
  ) {
    if (options.isEmpty) {
      return (options: options, correctIndex: 0);
    }
    final safeIndex = correctIndex.clamp(0, options.length - 1);
    final correct = options[safeIndex];
    final seen = <String>{};
    final unique = <String>[];
    for (final option in options) {
      final key = option.trim().toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      unique.add(option);
    }
    if (unique.isEmpty) {
      return (options: [correct], correctIndex: 0);
    }
    final correctKey = correct.trim().toLowerCase();
    var newIndex = unique.indexWhere((o) => o.trim().toLowerCase() == correctKey);
    if (newIndex < 0) {
      unique.insert(0, correct);
      newIndex = 0;
    }
    return (options: unique, correctIndex: newIndex);
  }
}

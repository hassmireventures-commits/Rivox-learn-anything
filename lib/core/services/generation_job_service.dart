import 'package:flutter/foundation.dart';

import '../constants/quiz_kind.dart';
import '../error/app_exception.dart';
import '../../data/remote/ai/learning_orchestrator.dart';
import '../../data/remote/ai/models/learning_pattern_context.dart';
import 'notification_service.dart';

enum GenerationJobKind { quiz, path, dailyContent }

/// App-scoped AI generation so leaving Create/Learn screens does not cancel work.
class GenerationJobService extends ChangeNotifier {
  GenerationJobService({
    required LearningOrchestrator orchestrator,
    NotificationService? notifications,
  })  : _orchestrator = orchestrator,
        _notifications = notifications ?? NotificationService.instance;

  final LearningOrchestrator _orchestrator;
  final NotificationService _notifications;

  bool _running = false;
  /// True from start until HTTP finishes (even after soft cancel / background).
  bool _inFlight = false;
  bool _userCancelled = false;
  /// True while the blocking overlay should stay up; false after "Continue in background".
  bool _uiAttached = true;
  GenerationJobKind? _kind;
  String? _topic;
  String? _successRoute;
  String? _errorMessage;
  int _jobSeq = 0;

  bool get isRunning => _running;
  /// Use for rate-limiting new starts while another job's HTTP is still open.
  bool get isBusy => _inFlight || _running;
  bool get userCancelled => _userCancelled;
  bool get uiAttached => _uiAttached;
  GenerationJobKind? get kind => _kind;
  String? get topic => _topic;
  String? get successRoute => _successRoute;
  String? get errorMessage => _errorMessage;

  void clearTerminalState() {
    if (_running || _inFlight) return;
    _successRoute = null;
    _errorMessage = null;
    _userCancelled = false;
    _uiAttached = true;
    _kind = null;
    _topic = null;
    notifyListeners();
  }

  /// Soft cancel: UI stops waiting; in-flight HTTP may still finish.
  /// Quota is only recorded after successful persist (orchestrator).
  void cancel() {
    if (!_running && !_inFlight) return;
    _userCancelled = true;
    _uiAttached = false;
    _running = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Dismiss blocking overlay wait without cancelling the in-flight job.
  void continueInBackground() {
    if (!_running && !_inFlight) return;
    _uiAttached = false;
    notifyListeners();
  }

  void _ensureIdle() {
    if (_inFlight || _running) {
      throw const ProviderUnavailableException(
        'Another generation is already in progress.',
      );
    }
  }

  Future<void> startQuiz({
    required String topic,
    int questionCount = 20,
    String difficulty = 'medium',
    String questionType = 'mcq',
    String? language,
    bool explanations = true,
    bool randomizeQuestions = true,
    bool randomizeOptions = true,
    int? examDurationSeconds,
    int? timerSeconds,
    String quizKind = QuizKind.quick,
    String? pathId,
    int? moduleIndex,
    LearningPatternContext? learningPattern,
    String? generationMode,
  }) async {
    _ensureIdle();
    final seq = ++_jobSeq;
    _running = true;
    _inFlight = true;
    _userCancelled = false;
    _uiAttached = true;
    _kind = GenerationJobKind.quiz;
    _topic = topic;
    _successRoute = null;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orchestrator.validateQuizProviders();
      final id = await _orchestrator.runQuizGeneration(
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
        questionType: questionType,
        language: language,
        explanations: explanations,
        randomizeQuestions: randomizeQuestions,
        randomizeOptions: randomizeOptions,
        examDurationSeconds: examDurationSeconds,
        timerSeconds: timerSeconds,
        quizKind: quizKind,
        pathId: pathId,
        moduleIndex: moduleIndex,
        learningPattern: learningPattern,
        generationMode: generationMode,
      );
      if (seq != _jobSeq) return;
      final route = pathId != null && moduleIndex != null
          ? '/quiz/play/$id?pathId=$pathId&moduleIndex=$moduleIndex'
          : '/quiz/play/$id';
      _running = false;
      _successRoute = route;
      notifyListeners();
      if (!_uiAttached) {
        await _notifications.notifyGenerationReady(
          title: 'Quiz ready',
          body: 'Your quiz on "$topic" is ready.',
          route: route,
        );
      }
    } catch (e) {
      if (seq != _jobSeq) return;
      final mapped = AppException.from(
        e,
        fallback: 'Quiz generation failed. Check your connection and AI provider settings.',
        task: 'quiz',
      );
      _running = false;
      if (!_userCancelled) {
        _errorMessage = mapped.message;
        if (!_uiAttached) {
          await _notifications.notifyGenerationFailed(
            title: 'Quiz generation failed',
            body: mapped.message,
          );
        }
      }
      notifyListeners();
      throw mapped;
    } finally {
      if (seq == _jobSeq) {
        _inFlight = false;
        notifyListeners();
      }
    }
  }

  Future<void> startPath({int moduleCount = 6, String? generationMode}) async {
    _ensureIdle();
    final seq = ++_jobSeq;
    _running = true;
    _inFlight = true;
    _userCancelled = false;
    _uiAttached = true;
    _kind = GenerationJobKind.path;
    _topic = 'Learning path';
    _successRoute = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _orchestrator.generateLearningPathWithLlm(
        moduleCount: moduleCount,
        generationMode: generationMode,
      );
      if (seq != _jobSeq) return;
      final route = '/paths/$id';
      _running = false;
      _successRoute = route;
      notifyListeners();
      if (!_uiAttached) {
        await _notifications.notifyGenerationReady(
          title: 'Learning path ready',
          body: 'Your learning path is ready to open.',
          route: route,
        );
      }
    } catch (e) {
      if (seq != _jobSeq) return;
      final mapped = AppException.from(
        e,
        fallback: 'Learning path generation failed.',
        task: 'path',
      );
      _running = false;
      if (!_userCancelled) {
        _errorMessage = mapped.message;
        if (!_uiAttached) {
          await _notifications.notifyGenerationFailed(
            title: 'Learning path failed',
            body: mapped.message,
          );
        }
      }
      notifyListeners();
      throw mapped;
    } finally {
      if (seq == _jobSeq) {
        _inFlight = false;
        notifyListeners();
      }
    }
  }

  /// Background-capable daily study pack (article + video).
  Future<void> startDailyContent({
    required Future<Object?> Function() generate,
  }) async {
    _ensureIdle();
    final seq = ++_jobSeq;
    _running = true;
    _inFlight = true;
    _userCancelled = false;
    _uiAttached = true;
    _kind = GenerationJobKind.dailyContent;
    _topic = 'Daily study';
    _successRoute = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final pack = await generate();
      if (seq != _jobSeq) return;
      if (pack == null) {
        throw const ProviderUnavailableException(
          'Could not find a valid article and video. Try again when AI is online.',
        );
      }
      const route = '/daily-content';
      _running = false;
      _successRoute = route;
      notifyListeners();
      if (!_uiAttached) {
        await _notifications.notifyGenerationReady(
          title: "Today's learning pick",
          body: 'Your daily article and video are ready.',
          route: route,
        );
      }
    } catch (e) {
      if (seq != _jobSeq) return;
      final mapped = AppException.from(
        e,
        fallback: 'Daily study pack generation failed.',
        task: 'daily_content',
      );
      _running = false;
      if (!_userCancelled) {
        _errorMessage = mapped.message;
        if (!_uiAttached) {
          await _notifications.notifyGenerationFailed(
            title: 'Daily study failed',
            body: mapped.message,
          );
        }
      }
      notifyListeners();
      throw mapped;
    } finally {
      if (seq == _jobSeq) {
        _inFlight = false;
        notifyListeners();
      }
    }
  }
}

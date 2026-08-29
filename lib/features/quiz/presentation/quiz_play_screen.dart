import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/constants/quiz_kind.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/services/study_session_tracker.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/question.dart';
import '../../../data/local/models/quiz_session.dart';
import '../../../data/local/repositories/learner_repository.dart';
import '../../../data/local/repositories/quiz_repository.dart';
import '../../../data/remote/ai/interview_rubric_scorer.dart';
import '../../../shared/widgets/app_card.dart';
import '../../career/presentation/interview_voice_input_bar.dart';
import '../../career/presentation/voice_interview_theme.dart';
import '../../../core/constants/interview_persona.dart';
import '../../../core/services/voice_interview_entitlement.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.quizId,
    this.voiceMode = false,
    this.interviewPersona,
  });

  final String quizId;
  final bool voiceMode;
  final String? interviewPersona;

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  QuizSession? _session;
  List<Question> _questions = [];
  int _index = 0;
  int? _selectedIndex;
  final Set<int> _flaggedIndices = {};
  final Map<int, int?> _answers = {};
  final Map<int, String> _textAnswers = {};
  final Map<int, int> _timeSpent = {};
  final Map<int, TextEditingController> _textControllers = {};
  Timer? _timer;
  Timer? _examTimer;
  int _remaining = 0;
  int _examRemaining = 0;
  DateTime? _questionStartedAt;
  DateTime? _quizStartedAt;
  bool _loading = true;
  bool _submitting = false;

  bool get _voiceInterview => widget.voiceMode;

  bool get _isTimedMock =>
      _session?.examDurationSeconds != null || _session?.quizKind == QuizKind.mock;

  bool get _isMockExam => _session?.quizKind == QuizKind.mock;

  void _toggleFlag() {
    setState(() {
      if (_flaggedIndices.contains(_index)) {
        _flaggedIndices.remove(_index);
      } else {
        _flaggedIndices.add(_index);
      }
    });
  }

  bool _isOpenQuestion(Question q) {
    final t = q.type.toLowerCase();
    if (t == 'short_answer' || t == 'behavioral' || t == 'open') return true;
    try {
      final opts = jsonDecode(q.optionsJson);
      return opts is List && opts.length == 1 && opts.first.toString() == '__open__';
    } catch (_) {
      return false;
    }
  }

  TextEditingController _controllerFor(int index) {
    return _textControllers.putIfAbsent(
      index,
      () => TextEditingController(text: _textAnswers[index] ?? ''),
    );
  }

  @override
  void initState() {
    super.initState();
    StudySessionTracker.instance.beginStudy();
    _load();
  }

  @override
  void dispose() {
    if (widget.voiceMode) {
      ref.read(whisperSttServiceProvider).cancelRecording();
    }
    StudySessionTracker.instance.endStudy();
    _timer?.cancel();
    _examTimer?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(quizRepositoryProvider);
    final session = await repo.getSession(widget.quizId);
    var questions = await repo.getQuestions(widget.quizId);
    if (_voiceInterview) {
      questions = questions.where(_isOpenQuestion).toList();
    }
    if (!mounted) return;
    setState(() {
      _session = session;
      _questions = questions;
      _loading = false;
      _quizStartedAt = DateTime.now();
    });
    if (_isTimedMock) {
      _startExamTimer();
    } else {
      _startQuestionTimer();
    }
    if (widget.voiceMode && session?.quizKind == QuizKind.interview) {
      await VoiceInterviewEntitlement.instance.markFreeSessionUsed(
        personaId: widget.interviewPersona ?? InterviewPersona.tech.id,
      );
    }
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _timer?.cancel();
    _questionStartedAt = DateTime.now();
    final seconds = _session?.examDurationSeconds;
    if (seconds == null || seconds <= 0) return;
    setState(() => _examRemaining = seconds);
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_examRemaining <= 1) {
        timer.cancel();
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.examMockTimeUp)),
        );
        _submit();
      } else {
        setState(() => _examRemaining--);
      }
    });
  }

  void _startQuestionTimer() {
    if (_isTimedMock) {
      _questionStartedAt = DateTime.now();
      return;
    }
    _timer?.cancel();
    _questionStartedAt = DateTime.now();
    final seconds = _session?.timerSeconds;
    if (seconds == null) return;
    setState(() => _remaining = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        _recordTime();
        _autoAdvance();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _recordTime() {
    if (_questionStartedAt == null) return;
    _timeSpent[_index] =
        DateTime.now().difference(_questionStartedAt!).inMilliseconds;
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedIndex = optionIndex;
      _answers[_index] = optionIndex;
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  String _voiceAnswerText(int index) => (_textAnswers[index] ?? '').trim();

  bool _hasVoiceAnswerFor(int index) => _voiceAnswerText(index).isNotEmpty;

  bool _requiresVoiceAnswer() =>
      _voiceInterview && _isOpenQuestion(_questions[_index]);

  bool _canAdvanceFromCurrent() {
    if (!_requiresVoiceAnswer()) return true;
    return _hasVoiceAnswerFor(_index);
  }

  void _showVoiceAnswerRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.interviewVoiceAnswerRequired)),
    );
  }

  void _setVoiceTranscript(String text) {
    _textAnswers[_index] = text.trim();
    setState(() {});
  }

  void _goTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    if (index > _index && !_canAdvanceFromCurrent()) {
      _showVoiceAnswerRequired();
      return;
    }
    _dismissKeyboard();
    _recordTime();
    if (_isOpenQuestion(_questions[_index]) && !_voiceInterview) {
      _textAnswers[_index] = _controllerFor(_index).text;
    }
    setState(() {
      _index = index;
      _selectedIndex = _answers[index];
    });
    _startQuestionTimer();
  }

  void _autoAdvance() {
    if (_index < _questions.length - 1) {
      _goTo(_index + 1);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_submitting || _session == null) return;
    if (!_canAdvanceFromCurrent()) {
      _showVoiceAnswerRequired();
      return;
    }
    _dismissKeyboard();
    setState(() {
      _submitting = true;
    });
    _timer?.cancel();
    _examTimer?.cancel();
    _recordTime();

    try {
      if (_isOpenQuestion(_questions[_index]) && !_voiceInterview) {
        _textAnswers[_index] = _controllerFor(_index).text;
      }
      for (var i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        q.timeSpentMs = _timeSpent[i] ?? 0;
        if (_isOpenQuestion(q)) {
          final answer = _voiceInterview
              ? _voiceAnswerText(i)
              : (_textAnswers[i] ?? _textControllers[i]?.text ?? '').trim();
          q.userAnswer = answer;
          // Scored below for interviews; provisional until then.
          q.isCorrect = (q.userAnswer ?? '').isNotEmpty;
        } else {
          final selected = _answers[i];
          q.userAnswer = selected?.toString();
          var graded = selected != null && selected == q.correctIndex;
          if (!graded && selected != null) {
            try {
              final opts = (jsonDecode(q.optionsJson) as List).cast<String>();
              if (selected >= 0 &&
                  selected < opts.length &&
                  q.correctIndex >= 0 &&
                  q.correctIndex < opts.length) {
                graded = opts[selected].trim().toLowerCase() ==
                    opts[q.correctIndex].trim().toLowerCase();
              }
            } catch (_) {}
          }
          q.isCorrect = graded;
        }
      }

      // Interview: AI rubric score for open responses before finalizing accuracy.
      if (_session?.quizKind == QuizKind.interview) {
        try {
          final provider = await ref.read(defaultAiProviderProvider.future);
          final key = provider == null
              ? null
              : await ref.read(providerRepositoryProvider).getApiKey(provider.uuid);
          if (provider != null && key != null && key.isNotEmpty) {
            final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
            await const InterviewRubricScorer().scoreOpenAnswers(
              config: provider,
              apiKey: key,
              questions: _questions,
              roleContext: profile.goalContext,
            );
          }
        } catch (_) {}
      }

      final elapsed = _quizStartedAt == null
          ? 0
          : DateTime.now().difference(_quizStartedAt!).inSeconds;

      final completed = await ref.read(quizRepositoryProvider).completeQuiz(
            quizUuid: widget.quizId,
            answeredQuestions: _questions,
            timeTakenSeconds: elapsed,
          );
      await ref.read(statsRepositoryProvider).recordCompletion(completed);

      final learner = ref.read(learnerRepositoryProvider);
      final perQuestion = elapsed / (_questions.isEmpty ? 1 : _questions.length);
      for (final q in _questions) {
        await learner.upsertTopic(
          topic: completed.topic,
          correct: q.isCorrect == true,
          timeSeconds: (q.timeSpentMs ?? 0) / 1000.0,
        );
      }

      final accuracy = completed.accuracy ?? 0;
      final params = mounted ? GoRouterState.of(context).uri.queryParameters : const {};
      final pathId = params['pathId'];
      final moduleIndex = int.tryParse(params['moduleIndex'] ?? '');

      try {
        await ref.read(vectorStoreProvider).upsertTopic(completed.topic);
        if (_questions.length >= 2) {
          await learner.addEdge(
            from: completed.topic,
            to: completed.topic,
            relation: 'related',
            weight: 0.1,
          );
        }
        final profile = await learner.getOrCreateProfile();
        final skill =
            ((profile.skillLevel * 0.8) + ((accuracy / 100) * 0.2)).clamp(0.0, 1.0);
        await learner.updateProfile(skillLevel: skill);

        // Move syllabus/skill gauges using session topic + unit titles.
        final practiced = <String>[completed.topic];
        if (completed.unitFilterJson != null && completed.unitFilterJson!.isNotEmpty) {
          try {
            final decoded = jsonDecode(completed.unitFilterJson!);
            final ids = decoded is List
                ? decoded.map((e) => e.toString()).toSet()
                : <String>{};
            final syllabus = await ref.read(goalProgressRepositoryProvider).activeSyllabus();
            if (syllabus != null && ids.isNotEmpty) {
              final units = await ref
                  .read(goalProgressRepositoryProvider)
                  .unitsFor(syllabus.uuid);
              practiced.addAll(
                units.where((u) => ids.contains(u.uuid)).map((u) => u.title),
              );
            }
          } catch (_) {}
        }
        // Also split "Mock: A · B" / "Interview (Role): Theme" style topics.
        if (completed.topic.contains('·') || completed.topic.startsWith('Mock:')) {
          practiced.addAll(
            completed.topic
                .replaceFirst(RegExp(r'^Mock:\s*'), '')
                .split('·')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty),
          );
        }
        if (completed.quizKind == QuizKind.interview) {
          practiced.addAll(
            completed.topic
                .replaceFirst(RegExp(r'^Interview(?:\s*\([^)]*\))?:\s*'), '')
                .split(RegExp(r'[:·,]'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty),
          );
        }
        await ref.read(goalProgressRepositoryProvider).applyPracticeEvidence(
              practicedTopics: practiced,
              accuracyRatio: accuracy / 100,
            );

        if (profile.goalMode == 'exam_prep') {
          final minutes = ((completed.timeTakenSeconds ?? elapsed) / 60).ceil().clamp(1, 180);
          final preferredKind = completed.quizKind == QuizKind.mock ? 'mock' : 'study';
          await ref.read(goalProgressRepositoryProvider).creditStudyMinutes(
                when: DateTime.now(),
                minutes: minutes,
                preferredKind: preferredKind,
              );
        }

        await ref.read(telemetryServiceProvider).emit(
          completed.quizKind == QuizKind.mock
              ? 'mock_completed'
              : completed.quizKind == QuizKind.interview
                  ? 'drill_completed'
                  : 'quiz_completed',
          {
            'topic': completed.topic,
            'accuracy': accuracy,
            'questions': completed.questionCount,
            'seconds': elapsed,
            'perQuestionSeconds': perQuestion,
            'passPercent': completed.passPercent,
            'attempt': completed.attemptNumber,
            'quizKind': completed.quizKind,
            if (completed.quizKind == QuizKind.mock) ...{
              'scorePercent': completed.scorePercent ?? accuracy.round(),
              'passed': completed.passPercent != null &&
                  accuracy >= (completed.passPercent ?? 60),
            },
            if (completed.quizKind == QuizKind.interview)
              'avgAiScore': _questions
                  .where((q) => q.aiScore != null)
                  .map((q) => q.aiScore!)
                  .fold<double>(0, (a, b) => a + b) /
              (_questions.where((q) => q.aiScore != null).isEmpty
                  ? 1
                  : _questions.where((q) => q.aiScore != null).length),
          },
        );
        await ref.read(recommendationEngineProvider).refreshRecommendations();
        await ref.read(anonAnalyticsSyncProvider).syncIfOptedIn();
      } catch (_) {
        // Best-effort analytics - quiz is already saved.
      }

      if (pathId != null && moduleIndex != null) {
        final repo = ref.read(learnerRepositoryProvider);
        final path = await repo.getPath(pathId);
        final steps = path != null ? repo.pathSteps(path) : const <PathStepData>[];
        final moduleTitle = (moduleIndex >= 0 && moduleIndex < steps.length)
            ? steps[moduleIndex].title
            : '';
        final advanced = await repo.advancePath(
              pathId,
              moduleIndex: moduleIndex,
              accuracy: accuracy,
              passThreshold: 0.6,
            );
        if (advanced && moduleTitle.isNotEmpty) {
          await ref.read(goalProgressRepositoryProvider).advanceSkillsForPathModule(
                moduleTitle: moduleTitle,
                pathModuleCount: steps.isEmpty ? 6 : steps.length,
              );
        }
        if (!advanced && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.quizModuleNotAdvanced)),
          );
        }
      }

      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(personalizationProvider);
      ref.invalidate(nextDecisionProvider);
      ref.invalidate(todaysDailyQuizOfferProvider);
      ref.invalidate(todaysDailyQuizProvider);
      ref.read(learningDataEpochProvider.notifier).state++;

      if (!mounted) return;
      final resultParams = <String, String>{};
      if (pathId != null) resultParams['pathId'] = pathId;
      if (_voiceInterview) {
        resultParams['voice'] = '1';
        final persona = widget.interviewPersona;
        if (persona != null && persona.isNotEmpty) resultParams['persona'] = persona;
      }
      final suffix = resultParams.isEmpty
          ? ''
          : '?${resultParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
      context.pushReplacement('/quiz/results/${widget.quizId}$suffix');
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        final message = context.l10n.quizSubmitFailed;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.quizNotFound)),
      );
    }

    final question = _questions[_index];
    final isOpen = _isOpenQuestion(question);
    final rawOptions = isOpen
        ? const <String>[]
        : (jsonDecode(question.optionsJson) as List).cast<String>();
    final options = isOpen
        ? rawOptions
        : QuizRepository.ensureMinChoiceOptions(rawOptions);
    final progress = (_index + 1) / _questions.length;
    final sortedFlags = _flaggedIndices.toList()..sort();
    final persona = InterviewPersona.fromId(widget.interviewPersona);
    final accent = persona == InterviewPersona.hr
        ? VoiceInterviewTheme.hrAccent
        : VoiceInterviewTheme.techAccent;

    final scaffold = Scaffold(
      backgroundColor: _voiceInterview ? VoiceInterviewTheme.background : null,
      appBar: AppBar(
        backgroundColor: _voiceInterview ? Colors.transparent : null,
        elevation: _voiceInterview ? 0 : null,
        foregroundColor: _voiceInterview ? Colors.white : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.quizQuestionProgress(_index + 1, _questions.length)),
            if (_voiceInterview && persona != null)
              Text(
                persona == InterviewPersona.hr
                    ? l10n.voiceInterviewPersonaHr
                    : l10n.voiceInterviewPersonaTech,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),
        actions: [
          if (_isMockExam)
            IconButton(
              tooltip: _flaggedIndices.contains(_index)
                  ? 'Unflag question'
                  : 'Flag for review',
              icon: Icon(
                _flaggedIndices.contains(_index) ? Icons.flag : Icons.flag_outlined,
                color: _flaggedIndices.contains(_index) ? AppTheme.seedColor : null,
              ),
              onPressed: _toggleFlag,
            ),
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: Text(l10n.quizSubmit),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Semantics(
              label: l10n.quizQuestionProgress(_index + 1, _questions.length),
              value: '${((_index + 1) / _questions.length * 100).round()}%',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: _voiceInterview ? accent : null,
              ),
            ),
            if (_isTimedMock && _session!.examDurationSeconds != null) ...[
              const SizedBox(height: 12),
              Semantics(
                label: 'Exam time remaining',
                value: '$_examRemaining seconds',
                child: _ExamCountdownBar(
                  remaining: _examRemaining,
                  total: _session!.examDurationSeconds!,
                ),
              ),
            ] else if (_session!.timerSeconds != null) ...[
              const SizedBox(height: 16),
              Semantics(
                label: 'Question timer',
                value: '$_remaining seconds remaining',
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _remaining / _session!.timerSeconds!,
                        strokeWidth: 6,
                        color: _remaining <= 5 ? Colors.red : AppTheme.seedColor,
                      ),
                      Center(
                        child: Text(
                          '$_remaining',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: AppCard(
                color: _voiceInterview ? VoiceInterviewTheme.surfaceElevated : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        question.text,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _voiceInterview
                                  ? VoiceInterviewTheme.questionText
                                  : null,
                              height: 1.35,
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isOpen
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_voiceInterview)
                                  InterviewVoiceInputBar(
                                    stt: ref.read(whisperSttServiceProvider),
                                    persona: persona,
                                    darkTheme: true,
                                    onTranscript: _setVoiceTranscript,
                                  )
                                else
                                  Expanded(
                                    child: Semantics(
                                      label: l10n.quizOpenAnswerLabel,
                                      textField: true,
                                      child: TextField(
                                        controller: _controllerFor(_index),
                                        maxLines: 8,
                                        minLines: 5,
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.done,
                                        onEditingComplete: _dismissKeyboard,
                                        onChanged: (v) => _textAnswers[_index] = v,
                                        decoration: InputDecoration(
                                          labelText: l10n.quizOpenAnswerLabel,
                                          hintText: context.l10n.careerShortAnswerHint,
                                          alignLabelWithHint: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : ListView.separated(
                              itemCount: options.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final selected = _selectedIndex == i;
                                return Semantics(
                                  button: true,
                                  selected: selected,
                                  label: l10n.quizOptionSemanticLabel(i + 1, options[i]),
                                  child: Material(
                                    color: selected
                                        ? AppTheme.seedColor.withValues(alpha: 0.12)
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _selectOption(i),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 18,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              selected
                                                  ? Icons.radio_button_checked_rounded
                                                  : Icons.radio_button_off_rounded,
                                              color: selected ? AppTheme.seedColor : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                options[i],
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isMockExam && _flaggedIndices.isNotEmpty) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedFlags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final flaggedIndex = sortedFlags[i];
                    final isCurrent = flaggedIndex == _index;
                    return ActionChip(
                      avatar: const Icon(Icons.flag, size: 16),
                      label: Text('Q${flaggedIndex + 1}'),
                      backgroundColor: isCurrent
                          ? AppTheme.seedColor.withValues(alpha: 0.16)
                          : null,
                      onPressed: () => _goTo(flaggedIndex),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                      child: Text(l10n.quizPrevious),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              if (_index == _questions.length - 1) {
                                _submit();
                              } else {
                                _goTo(_index + 1);
                              }
                            },
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(
                              _index == _questions.length - 1
                                  ? l10n.quizFinish
                                  : l10n.quizNext,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
    if (!_voiceInterview) return scaffold;
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: VoiceInterviewTheme.background,
        colorScheme: ColorScheme.dark(
          primary: accent,
          onSurface: VoiceInterviewTheme.questionText,
          onSurfaceVariant: VoiceInterviewTheme.questionSubtext,
          surface: VoiceInterviewTheme.surface,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: VoiceInterviewTheme.questionText,
              displayColor: VoiceInterviewTheme.questionText,
            ),
      ),
      child: scaffold,
    );
  }
}

class _ExamCountdownBar extends StatelessWidget {
  const _ExamCountdownBar({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minutes = remaining ~/ 60;
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final urgent = remaining <= 60;
    final ratio = total <= 0 ? 0.0 : remaining / total;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: urgent ? Colors.red : const Color(0xFFE67E22),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.examMockGlobalTimeLeft(minutes, seconds),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: urgent ? Colors.red : const Color(0xFFE67E22),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0xFFE67E22).withValues(alpha: 0.15),
            color: urgent ? Colors.red : const Color(0xFFE67E22),
          ),
        ),
      ],
    );
  }
}

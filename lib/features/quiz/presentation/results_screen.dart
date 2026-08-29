import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/quiz_kind.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/document_chunk.dart';
import '../../../data/local/models/question.dart';
import '../../../data/local/models/quiz_session.dart';
import '../../../data/local/repositories/flashcard_repository.dart';
import '../../../data/local/repositories/quiz_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../career/presentation/interview_feedback_buttons.dart';
import '../../career/presentation/voice_interview_theme.dart';
import '../../../core/constants/interview_persona.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({
    super.key,
    required this.quizId,
    this.voiceInterview = false,
    this.interviewPersona,
  });

  final String quizId;
  final bool voiceInterview;
  final String? interviewPersona;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with SingleTickerProviderStateMixin {
  QuizSession? _session;
  List<Question> _questions = [];
  List<QuizSession> _mockTrend = [];
  List<String> _citationLabels = [];
  bool _loading = true;
  bool _creatingFlashcards = false;
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(quizRepositoryProvider);
    final session = await repo.getSession(widget.quizId);
    final questions = await repo.getQuestions(widget.quizId);
    List<QuizSession> trend = const [];
    List<String> citationLabels = const [];
    if (session?.quizKind == QuizKind.mock) {
      trend = await repo.getRecentMocks(
        syllabusUuid: session?.syllabusUuid,
        limit: 8,
      );
    }
    if (session?.citationChunkIdsJson != null &&
        session!.citationChunkIdsJson!.isNotEmpty) {
      try {
        final ids = (jsonDecode(session.citationChunkIdsJson!) as List).cast<String>();
        if (ids.isNotEmpty) {
          final chunks = await ref.read(knowledgeRepositoryProvider).chunksForIds(ids);
          citationLabels = chunks
              .map((DocumentChunk c) {
                final label = c.citationLabel ?? 'Source';
                if (c.page != null) return '$label (p.${c.page})';
                return label;
              })
              .toSet()
              .toList();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _session = session;
      _questions = questions;
      _mockTrend = trend;
      _citationLabels = citationLabels;
      _loading = false;
    });
    _controller.forward();
  }

  Future<void> _share() async {
    final l10n = context.l10n;
    final s = _session;
    if (s == null) return;
    final topicEnc = Uri.encodeComponent(s.topic);
    final deepLink =
        '${AppConstants.deepLinkScheme}://quiz/create?topic=$topicEnc'
        '&difficulty=${Uri.encodeComponent(s.difficulty)}'
        '&count=${s.questionCount}'
        '&type=${Uri.encodeComponent(s.questionType)}';
    final text = '${l10n.resultsShareText(
      s.correctCount ?? 0,
      s.questionCount,
      (s.accuracy ?? 0).toStringAsFixed(0),
      s.topic,
    )}\n\n${l10n.resultsShareChallengeCta}\n$deepLink\n\n${l10n.resultsShareGetApp}\n${AppConstants.playStoreUrl}';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  List<Question> get _wrongQuestions =>
      _questions.where((q) => q.isCorrect == false).toList();

  Future<void> _reviewMistakesAsFlashcards() async {
    final wrong = _wrongQuestions;
    if (wrong.isEmpty || _creatingFlashcards) return;
    setState(() => _creatingFlashcards = true);
    try {
      final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
      final cards = wrong
          .map(
            (q) => FlashcardRepository.fromWrongQuestion(
              q,
              goalMode: profile.goalMode,
              uuid: _uuid.v4(),
            ),
          )
          .toList();
      await ref.read(flashcardRepositoryProvider).addCards(cards);
      if (!mounted) return;
      context.push('/flashcards?goal=${profile.goalMode}');
    } finally {
      if (mounted) setState(() => _creatingFlashcards = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final session = _session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.resultsNotFound)),
      );
    }

    final accuracy = session.accuracy ?? 0;
    final passMark = session.passPercent ?? 60;
    final isMock = session.quizKind == QuizKind.mock;
    final passedMock = accuracy >= passMark;
    final passedModule = accuracy >= 60;
    final isModule = session.quizKind == QuizKind.module;
    final isMultiplayer = session.quizKind == QuizKind.multiplayer || session.source == 'multiplayer';
    final persona = InterviewPersona.fromId(widget.interviewPersona);
    final voiceResults = widget.voiceInterview && session.quizKind == QuizKind.interview;
    final pathId = session.pathId;
    final moduleIndex = session.moduleIndex;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (voiceResults) ...[
            AppCard(
              color: (persona == InterviewPersona.hr
                      ? VoiceInterviewTheme.hrAccent
                      : VoiceInterviewTheme.techAccent)
                  .withValues(alpha: 0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona == InterviewPersona.hr
                        ? l10n.voiceInterviewResultsHrTitle
                        : l10n.voiceInterviewResultsTechTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: persona == InterviewPersona.hr
                              ? VoiceInterviewTheme.hrAccent
                              : VoiceInterviewTheme.techAccent,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.voiceInterviewResultsSubtitle(accuracy.round()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppCard(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, _) {
                    final value = (accuracy * _scoreAnimation.value).round();
                    return Text(
                      l10n.resultsAccuracyDisplay(value.toString()),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isMock
                                ? (passedMock ? AppTheme.accentGreen : const Color(0xFFE67E22))
                                : AppTheme.seedColor,
                          ),
                    );
                  },
                ),
                if (isMock) ...[
                  const SizedBox(height: 8),
                  Text(
                    passedMock
                        ? l10n.examMockPassed(accuracy.round(), passMark)
                        : l10n.examMockFailed(accuracy.round(), passMark),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: passedMock ? AppTheme.accentGreen : const Color(0xFFE67E22),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (session.attemptNumber != null)
                    Text(l10n.examMockAttemptLabel(session.attemptNumber!)),
                ],
                const SizedBox(height: 8),
                Text(
                  session.topic,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.resultsMeta(
                    L10nHelpers.difficultyLabel(l10n, session.difficulty),
                    session.questionCount,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isMock && _mockTrend.length > 1) ...[
            const SizedBox(height: 16),
            Text(
              l10n.examMockTrendTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            AppCard(
              child: SizedBox(
                height: 120,
                child: _MockTrendChart(attempts: _mockTrend.reversed.toList()),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.resultsCorrect,
                  value: '${session.correctCount ?? 0}',
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: l10n.resultsWrong,
                  value: '${session.wrongCount ?? 0}',
                  color: AppTheme.accentPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.resultsTime,
                  value: _formatTime(l10n, session.timeTakenSeconds ?? 0),
                  color: AppTheme.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: l10n.statAccuracy,
                  value: l10n.resultsAccuracyDisplay(accuracy.toStringAsFixed(0)),
                  color: AppTheme.accentOrange,
                ),
              ),
            ],
          ),
          if (_citationLabels.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resultsGroundedInLibrary,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._citationLabels.map(
                    (label) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l10n.resultsSourceCitation(label))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.resultsExplanations,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final rawOptions = (jsonDecode(q.optionsJson) as List).cast<String>();
            final isOpen = q.type == 'short_answer' ||
                q.type == 'behavioral' ||
                (rawOptions.length == 1 && rawOptions.first == '__open__');
            final options = isOpen
                ? rawOptions
                : QuizRepository.ensureMinChoiceOptions(rawOptions);
            final selected = int.tryParse(q.userAnswer ?? '');
            final yourAnswer = () {
              if (isOpen) {
                final ans = (q.userAnswer ?? '').trim();
                return ans.isEmpty ? l10n.resultsNoAnswer : ans;
              }
              return selected != null &&
                      selected >= 0 &&
                      selected < options.length
                  ? options[selected]
                  : l10n.resultsNoAnswer;
            }();
            final unanswered = yourAnswer == l10n.resultsNoAnswer;
            final correct = q.isCorrect == true;
            final answerColor = unanswered
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : correct
                    ? AppTheme.accentGreen
                    : AppTheme.accentPink;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  leading: Icon(
                    unanswered
                        ? Icons.remove_circle_outline_rounded
                        : correct
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                    color: answerColor,
                  ),
                  title: Text(
                    l10n.resultsQuestionTitle(i + 1, q.text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.resultsYourAnswer(yourAnswer),
                        style: TextStyle(
                          color: answerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (q.aiScore != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.careerAiScoreLabel((q.aiScore! * 100).round()),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: (q.aiScore ?? 0) >= 0.6
                                ? AppTheme.accentGreen
                                : const Color(0xFFE67E22),
                          ),
                        ),
                      ),
                    ],
                    if (!(q.type == 'short_answer' || q.type == 'behavioral'))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.resultsCorrectAnswer(
                            q.correctIndex >= 0 && q.correctIndex < options.length
                                ? options[q.correctIndex]
                                : l10n.resultsNoAnswer,
                          ),
                        ),
                      ),
                    if (q.explanation != null && q.explanation!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(q.explanation!),
                      ),
                    ],
                    if (q.referencesJson != null &&
                        q.referencesJson!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.resultsAnswerReferences,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      ..._parseReferences(q.referencesJson!).map(
                        (ref) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ref['url']!.isNotEmpty
                                ? '• ${ref['title']} (${ref['url']})'
                                : '• ${ref['title']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.commonGoHome,
            icon: Icons.home_rounded,
            onPressed: () => context.go('/dashboard'),
          ),
          if (voiceResults) ...[
            const SizedBox(height: 20),
            InterviewFeedbackButtons(
              quizId: widget.quizId,
              personaId: widget.interviewPersona,
            ),
          ],
          const SizedBox(height: 10),
          if (isModule && pathId != null) ...[
            if (passedModule)
              PrimaryButton(
                label: l10n.resultsNextModule,
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  final next = (moduleIndex ?? 0) + 1;
                  context.push('/paths/$pathId?module=$next');
                },
              )
            else
              PrimaryButton(
                label: l10n.resultsRetryModuleQuiz,
                icon: Icons.refresh_rounded,
                onPressed: () => context.push('/paths/$pathId?module=${moduleIndex ?? 0}'),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.push('/paths/$pathId?module=${moduleIndex ?? 0}'),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(passedModule ? l10n.resultsReviewPath : l10n.resultsBackToModuleStudy),
            ),
          ] else if (!isMultiplayer) ...[
            OutlinedButton.icon(
              onPressed: () => context.push(
                isMock
                    ? '/exam/mock/create'
                    : session.quizKind == QuizKind.interview
                        ? (voiceResults
                            ? '/career/voice-interview'
                            : '/career/drill/create')
                        : '/quiz/create',
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                isMock
                    ? l10n.examMockRetake
                    : session.quizKind == QuizKind.interview
                        ? l10n.careerDrillRetake
                        : l10n.resultsNewQuickQuiz,
              ),
            ),
          ],
          if (_wrongQuestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _creatingFlashcards ? null : _reviewMistakesAsFlashcards,
              icon: _creatingFlashcards
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.style_rounded),
              label: Text(
                l10n.resultsReviewMistakesAsFlashcards(_wrongQuestions.length),
              ),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share_rounded),
            label: Text(l10n.resultsShareScore),
          ),
          ScrollableNativeAdSlot(slotId: 'results_${widget.quizId}'),
        ],
      ),
    );
  }

  String _formatTime(dynamic l10n, int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return l10n.resultsTimeFormat(m, s);
  }

  List<Map<String, String>> _parseReferences(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <Map<String, String>>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        out.add({
          'title': item['title']?.toString() ?? '',
          'url': item['url']?.toString() ?? '',
        });
      }
      return out;
    } catch (_) {
      return const [];
    }
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class _MockTrendChart extends StatelessWidget {
  const _MockTrendChart({required this.attempts});

  final List<QuizSession> attempts;

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) return const SizedBox.shrink();
    final maxY = 100.0;
    return CustomPaint(
      painter: _TrendPainter(
        values: attempts
            .map((a) => (a.scorePercent ?? a.accuracy ?? 0).toDouble())
            .toList(),
        maxY: maxY,
        color: const Color(0xFFE67E22),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.maxY,
    required this.color,
  });

  final List<double> values;
  final double maxY;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i * size.width / (values.length - 1);
      final y = size.height - (values[i].clamp(0, maxY) / maxY) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, paint);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i * size.width / (values.length - 1);
      final y = size.height - (values[i].clamp(0, maxY) / maxY) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values;
}

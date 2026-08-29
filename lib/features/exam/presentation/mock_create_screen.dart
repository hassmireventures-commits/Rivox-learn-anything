import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/network/network_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/syllabus_unit.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/metric_honesty_banner.dart';
import '../../../shared/widgets/primary_button.dart';

const _kDurations = [30, 60, 90, 180];
const _kPassMarks = [50, 60, 70, 80];
const _kCounts = [10, 15, 20, 25, 50];

/// Timed mock exam configuration + generation.
class MockCreateScreen extends ConsumerStatefulWidget {
  const MockCreateScreen({super.key});

  @override
  ConsumerState<MockCreateScreen> createState() => _MockCreateScreenState();
}

class _MockCreateScreenState extends ConsumerState<MockCreateScreen> {
  int _durationMinutes = 60;
  int _passPercent = 60;
  int _questionCount = 20;
  String _difficulty = 'medium';
  final Set<String> _selectedUnitIds = {};
  List<SyllabusUnit> _units = [];
  String? _syllabusUuid;
  String _examTitle = '';
  bool _loading = true;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = ref.read(goalProgressRepositoryProvider);
    final syllabus = await progress.activeSyllabus();
    if (syllabus != null) {
      final units = await progress.unitsFor(syllabus.uuid);
      if (!mounted) return;
      setState(() {
        _syllabusUuid = syllabus.uuid;
        _examTitle = syllabus.title;
        _units = units;
        _selectedUnitIds
          ..clear()
          ..addAll(units.map((u) => u.uuid));
        _loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showGenerationError(Object e, {String? fallbackMessage}) async {
    if (!mounted) return;
    setState(() {
      _generating = false;
      _error = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final mapped = e is AppException
        ? e
        : UnknownException(fallbackMessage ?? context.l10n.createQuizGenerateFailed);
    await showAppErrorDialog(
      context,
      mapped,
      onRateLimitDismissed: () async {
        await ref.read(usageTrackerProvider).clearActiveRateLimits();
        ref.invalidate(activeRateLimitProvider);
      },
    );
  }

  void _cancelGeneration() {
    if (!_generating) return;
    setState(() => _generating = false);
  }

  Future<void> _generate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = context.l10n;
    if (_selectedUnitIds.isEmpty) {
      setState(() => _error = l10n.examMockUnitsRequired);
      return;
    }
    final provider = await ref.read(defaultAiProviderProvider.future);
    if (provider == null) {
      setState(() => _error = l10n.examMockNoProvider);
      return;
    }

    final selected = _units.where((u) => _selectedUnitIds.contains(u.uuid)).toList();
    final topicParts = selected.map((u) => u.title).toList();
    final topic = topicParts.length == 1
        ? topicParts.first
        : 'Mock: ${topicParts.take(4).join(' · ')}';

    setState(() {
      _generating = true;
      _error = null;
    });

    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException catch (e) {
      await _showGenerationError(e);
      return;
    } catch (_) {}

    try {
      final settings = ref.read(settingsProvider).asData?.value;
      final language = aiLanguageName(settings?.language ?? 'en');
      final attempt = await ref.read(quizRepositoryProvider).nextMockAttemptNumber(
            syllabusUuid: _syllabusUuid,
          );

      final quizId = await ref.read(learningOrchestratorProvider).runQuizGeneration(
            topic: topic,
            questionCount: _questionCount,
            difficulty: _difficulty,
            questionType: 'mixed',
            language: language,
            explanations: true,
            quizKind: QuizKind.mock,
            examDurationSeconds: _durationMinutes * 60,
            passPercent: _passPercent,
            syllabusUuid: _syllabusUuid,
            unitFilter: selected.map((u) => u.uuid).toList(),
            syllabusUnitTitles: selected.map((u) => u.title).toList(),
            attemptNumber: attempt,
          );

      await ref.read(telemetryServiceProvider).emit('mock_started', {
        'durationMinutes': _durationMinutes,
        'passPercent': _passPercent,
        'units': selected.length,
        'questions': _questionCount,
        'attempt': attempt,
      });

      if (!mounted) return;
      context.pushReplacement('/quiz/play/$quizId');
    } on AppException catch (e) {
      await _showGenerationError(e);
    } catch (_) {
      await _showGenerationError(UnknownException(l10n.createQuizGenerateFailed));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final coverage =
        ref.watch(personalizationProvider).asData?.value.syllabusCoveragePercent ?? 0;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.examMockConfigTitle)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppCard(
                color: const Color(0xFFE67E22).withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MetricHonestyBanner(),
                    const SizedBox(height: 10),
                    Text(
                      _examTitle.isNotEmpty ? _examTitle : l10n.goalModeExamPrep,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.dashboardExamSyllabusCoverage(coverage)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.examMockDurationLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kDurations.map((m) {
                  final selected = _durationMinutes == m;
                  return FilterChip(
                    label: Text(l10n.examMockDurationMinutes(m)),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _durationMinutes = m),
                    selectedColor: const Color(0xFFE67E22).withValues(alpha: 0.15),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.examMockPassMarkLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _kPassMarks.map((p) {
                  final selected = _passPercent == p;
                  return FilterChip(
                    label: Text(l10n.examMockPassMarkValue(p)),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _passPercent = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.examMockQuestionCount, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _kCounts.map((c) {
                  final selected = _questionCount == c;
                  return FilterChip(
                    label: Text('$c'),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _questionCount = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.examMockDifficulty, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['easy', 'medium', 'hard', 'expert'].map((d) {
                  final selected = _difficulty == d;
                  return FilterChip(
                    label: Text(L10nHelpers.difficultyLabel(l10n, d)),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _difficulty = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.examMockUnitsLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                l10n.examMockUnitsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (_units.isEmpty)
                AppCard(child: Text(l10n.examMockNoUnits))
              else
                ..._units.map((unit) {
                  final selected = _selectedUnitIds.contains(unit.uuid);
                  return CheckboxListTile(
                    value: selected,
                    contentPadding: EdgeInsets.zero,
                    title: Text(unit.title),
                    subtitle: Text(
                      l10n.dashboardExamSyllabusCoverage((unit.mastery * 100).round()),
                    ),
                    activeColor: const Color(0xFFE67E22),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedUnitIds.add(unit.uuid);
                        } else {
                          _selectedUnitIds.remove(unit.uuid);
                        }
                        _error = null;
                      });
                    },
                  );
                }),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.examMockGenerate,
                icon: Icons.timer_outlined,
                isLoading: _generating,
                onPressed: _units.isEmpty
                    ? () {}
                    : _generate,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _generating ? null : () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.commonCancel),
              ),
            ],
          ),
          GenerationOverlay(
            visible: _generating,
            topic: _examTitle.isNotEmpty ? _examTitle : null,
            onCancel: _cancelGeneration,
          ),
        ],
      ),
    );
  }
}

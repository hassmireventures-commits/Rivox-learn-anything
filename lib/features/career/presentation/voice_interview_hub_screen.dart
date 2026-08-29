import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/interview_persona.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/network/network_service.dart';
import '../../../core/constants/quiz_kind.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/services/voice_interview_entitlement.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/primary_button.dart';
import 'interview_feedback_buttons.dart';
import 'voice_interview_speech_coaching.dart';
import 'voice_interview_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Voice interview entry: pick HR or Technical interviewer, one free session per install.
class VoiceInterviewHubScreen extends ConsumerStatefulWidget {
  const VoiceInterviewHubScreen({super.key});

  @override
  ConsumerState<VoiceInterviewHubScreen> createState() =>
      _VoiceInterviewHubScreenState();
}

class _VoiceInterviewHubScreenState extends ConsumerState<VoiceInterviewHubScreen>
    with SingleTickerProviderStateMixin {
  InterviewPersona _persona = InterviewPersona.tech;
  bool _loading = true;
  bool _generating = false;
  bool _used = false;
  List<String> _themes = [];
  String _theme = '';
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final l10n = context.l10n;
    final used = await VoiceInterviewEntitlement.instance.hasUsedFreeSession();
    final progress = ref.read(goalProgressRepositoryProvider);
    final knowledge = ref.read(knowledgeRepositoryProvider);
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    final skillThemes = await progress.interviewDrillThemes();
    final themes = <String>[];
    if (await knowledge.hasIndexedType(profile.goalMode, 'resume')) {
      themes.add(l10n.careerDrillSelfIntroTheme);
    }
    for (final t in skillThemes) {
      if (!themes.contains(t)) themes.add(t);
    }
    if (themes.isEmpty) themes.add('Behavioral & role fit');
    if (!mounted) return;
    setState(() {
      _used = used;
      _themes = themes;
      _theme = themes.first;
      _loading = false;
    });
  }

  Future<void> _showError(Object e) async {
    if (!mounted) return;
    setState(() => _generating = false);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await showAppErrorDialog(
      context,
      e is AppException ? e : UnknownException(context.l10n.createQuizGenerateFailed),
      onRateLimitDismissed: () async {
        await ref.read(usageTrackerProvider).clearActiveRateLimits();
        ref.invalidate(activeRateLimitProvider);
      },
    );
  }

  Future<void> _beginInterview() async {
    if (_used) return;
    final hasKey = await ref.read(whisperSttServiceProvider).hasAnyApiKey();
    if (!mounted) return;
    if (!hasKey) {
      await _showError(UnknownException(context.l10n.interviewVoiceNoKey));
      return;
    }
    if (!await VoiceInterviewEntitlement.instance.canStartVoiceInterview()) {
      setState(() => _used = true);
      return;
    }

    final provider = await ref.read(defaultAiProviderProvider.future);
    if (provider == null) {
      await _showError(const NoProviderConfiguredException());
      return;
    }

    setState(() => _generating = true);
    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException catch (e) {
      await _showError(e);
      return;
    } catch (_) {}

    try {
      final l10n = context.l10n;
      final settings = ref.read(settingsProvider).asData?.value;
      final language = aiLanguageName(settings?.language ?? 'en');
      final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
      final knowledge = ref.read(knowledgeRepositoryProvider);
      final role = profile.goalContext.trim();
      final company = await knowledge.extractCompanyFromJd(profile.goalMode);
      final personaLabel = _persona == InterviewPersona.hr
          ? l10n.voiceInterviewPersonaHr
          : l10n.voiceInterviewPersonaTech;
      final roleLabel = role.isEmpty
          ? (company != null ? '@ $company' : '')
          : (company != null ? '$role @ $company' : role);
      final topic = roleLabel.isEmpty
          ? 'Voice interview ($personaLabel): $_theme'
          : 'Voice interview ($personaLabel · $roleLabel): $_theme';

      final hasResume = await knowledge.hasIndexedType(profile.goalMode, 'resume');
      final hasJd = await knowledge.hasIndexedType(profile.goalMode, 'jd');
      final generationMode = (hasResume || hasJd) ? 'grounded' : null;

      final quizId = await ref.read(learningOrchestratorProvider).runQuizGeneration(
            topic: topic,
            questionCount: 6,
            difficulty: 'medium',
            questionType: 'interview',
            language: language,
            explanations: true,
            quizKind: QuizKind.interview,
            passPercent: 60,
            generationMode: generationMode,
            interviewPersona: _persona.id,
            voiceInterviewOnly: true,
          );

      await ref.read(telemetryServiceProvider).emit('voice_interview_started', {
        'persona': _persona.id,
        'theme': _theme,
      });

      if (!mounted) return;
      context.pushReplacement(
        '/quiz/play/$quizId?voice=1&persona=${_persona.id}',
      );
    } on AppException catch (e) {
      await _showError(e);
    } catch (_) {
      await _showError(UnknownException(context.l10n.createQuizGenerateFailed));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _showApiKeyDialog() async {
    final l10n = context.l10n;
    final stt = ref.read(whisperSttServiceProvider);
    final controller = TextEditingController(text: await stt.getUserApiKey() ?? '');
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.voiceInterviewApiKeyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.voiceInterviewApiKeyDescription,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: l10n.voiceInterviewApiKeyHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await stt.clearUserApiKey();
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.voiceInterviewApiKeyCleared)),
              );
            },
            child: Text(l10n.voiceInterviewApiKeyClear),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              await stt.setUserApiKey(controller.text);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.voiceInterviewApiKeySaved)),
              );
            },
            child: Text(l10n.voiceInterviewApiKeySave),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: VoiceInterviewTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: VoiceInterviewTheme.techAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: VoiceInterviewTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.voiceInterviewHubTitle),
        actions: [
          IconButton(
            tooltip: l10n.voiceInterviewApiKeyMenuTooltip,
            icon: const Icon(Icons.vpn_key_outlined),
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: VoiceInterviewTheme.backgroundGradient(
            accent: _persona == InterviewPersona.hr
                ? InterviewAccent.hr
                : InterviewAccent.tech,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return Container(
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              VoiceInterviewTheme.techAccent.withValues(alpha: 0.2),
                              VoiceInterviewTheme.hrAccent.withValues(alpha: 0.8),
                              VoiceInterviewTheme.techAccent.withValues(alpha: 0.2),
                            ],
                            stops: [
                              0,
                              0.5 + 0.4 * math.sin(_pulse.value * math.pi * 2),
                              1,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    l10n.voiceInterviewHubSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VoiceInterviewTheme.techAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: VoiceInterviewTheme.techAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.tips_and_updates_outlined,
                          color: VoiceInterviewTheme.techAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            VoiceInterviewSpeechCoaching.primaryTip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _used ? Icons.lock_outline_rounded : Icons.stars_rounded,
                          color: _used ? Colors.orangeAccent : VoiceInterviewTheme.techAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _used
                                ? l10n.voiceInterviewUsedTitle
                                : l10n.voiceInterviewFreeOnce,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_used) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.voiceInterviewUsedBody,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 16),
                    InterviewFeedbackButtons(compact: true),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/career/drill/create'),
                      icon: const Icon(Icons.record_voice_over_outlined),
                      label: Text(l10n.careerDrillGenerate),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.voiceInterviewPickInterviewer,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PersonaCard(
                      selected: _persona == InterviewPersona.hr,
                      accent: InterviewAccent.hr,
                      title: l10n.voiceInterviewPersonaHr,
                      subtitle: l10n.voiceInterviewPersonaHrDesc,
                      icon: Icons.groups_rounded,
                      onTap: () => setState(() => _persona = InterviewPersona.hr),
                    ),
                    const SizedBox(height: 12),
                    _PersonaCard(
                      selected: _persona == InterviewPersona.tech,
                      accent: InterviewAccent.tech,
                      title: l10n.voiceInterviewPersonaTech,
                      subtitle: l10n.voiceInterviewPersonaTechDesc,
                      icon: Icons.memory_rounded,
                      onTap: () => setState(() => _persona = InterviewPersona.tech),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.careerDrillThemeLabel,
                      style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _themes.map((t) {
                        final selected = _theme == t;
                        final accent = _persona == InterviewPersona.hr
                            ? VoiceInterviewTheme.hrAccent
                            : VoiceInterviewTheme.techAccent;
                        return FilterChip(
                          label: Text(t),
                          selected: selected,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                          ),
                          selectedColor: accent.withValues(alpha: 0.35),
                          backgroundColor: VoiceInterviewTheme.surface,
                          side: BorderSide(
                            color: selected ? accent : Colors.white12,
                          ),
                          onSelected: (_) => setState(() => _theme = t),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              if (!_used)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: PrimaryButton(
                    label: l10n.voiceInterviewBegin,
                    icon: Icons.mic_rounded,
                    isLoading: _generating,
                    onPressed: _generating ? null : _beginInterview,
                  ),
                ),
              GenerationOverlay(
                visible: _generating,
                topic: _theme,
                onCancel: () => setState(() => _generating = false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  const _PersonaCard({
    required this.selected,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final InterviewAccent accent;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent == InterviewAccent.hr
        ? VoiceInterviewTheme.hrAccent
        : VoiceInterviewTheme.techAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: VoiceInterviewTheme.personaCard(
            selected: selected,
            accent: accent,
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/career_skill.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/metric_honesty_banner.dart';
import '../../../shared/widgets/primary_button.dart';

final careerSkillsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(goalProgressRepositoryProvider).allCareerSkills();
});

/// Skill matrix with CRUD + gap quiz / interview drill CTAs.
class SkillMatrixScreen extends ConsumerWidget {
  const SkillMatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final skillsAsync = ref.watch(careerSkillsProvider);
    final personalization = ref.watch(personalizationProvider).asData?.value;
    final readiness = personalization?.careerReadinessPercent ?? 0;
    final role = personalization?.goalContextLabel ?? '';

    String categoryLabel(String category) => switch (category) {
          'technical' => 'Technical',
          'behavioral' => 'Behavioral',
          'tool' => 'Tool',
          'domain' => 'Domain',
          _ => category,
        };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careerMatrixTitle),
        actions: [
          IconButton(
            tooltip: l10n.careerAddSkill,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _editSkill(context, ref, role: role),
          ),
        ],
      ),
      body: skillsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (skills) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppCard(
                onTap: () => context.push('/library?goal=career'),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_open_rounded),
                  title: Text(l10n.libraryUploadCareerDocs),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MetricHonestyBanner(
                      message:
                          'Readiness is estimated from practice quizzes in the app - not an employer or interview score.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.dashboardCareerReadiness,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(l10n.dashboardCareerRole(role)),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      l10n.careerReadinessPct(readiness),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: readiness / 100,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF27AE60).withValues(alpha: 0.15),
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/career/drill/create'),
                      icon: const Icon(Icons.record_voice_over_rounded),
                      label: Text(l10n.careerStartDrill),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF27AE60),
                        side: const BorderSide(color: Color(0xFF27AE60)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/career/voice-interview'),
                      icon: const Icon(Icons.mic_rounded),
                      label: Text(l10n.interviewVoiceStart),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.careerSkillsSection,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (skills.isEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.careerMatrixEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: l10n.careerAddSkill,
                        icon: Icons.add_rounded,
                        onPressed: () => _editSkill(context, ref, role: role),
                      ),
                    ],
                  ),
                )
              else
                ...skills.map((skill) {
                  final target = skill.targetLevel <= 0 ? 0.8 : skill.targetLevel;
                  final ratio = (skill.currentLevel / target).clamp(0.0, 1.0);
                  final gap = (target - skill.currentLevel).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  skill.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${(ratio * 100).round()}%',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await _editSkill(context, ref, role: role, skill: skill);
                                  } else if (value == 'delete') {
                                    await ref
                                        .read(goalProgressRepositoryProvider)
                                        .deleteCareerSkill(skill.uuid);
                                    ref.invalidate(careerSkillsProvider);
                                    ref.invalidate(personalizationProvider);
                                  } else if (value == 'practice') {
                                    final topic = Uri.encodeComponent(skill.evidenceTopic);
                                    if (context.mounted) {
                                      context.push('/quiz/create?topic=$topic');
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'practice', child: Text(l10n.careerPracticeGap)),
                                  PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),
                                  PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categoryLabel(skill.category),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            gap > 0.05
                                ? l10n.careerGapLabel(skill.title)
                                : l10n.careerSkillOnTrack,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              backgroundColor: const Color(0xFF27AE60).withValues(alpha: 0.12),
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                final topic = Uri.encodeComponent(skill.evidenceTopic);
                                context.push('/quiz/create?topic=$topic');
                              },
                              icon: const Icon(Icons.quiz_outlined, size: 18),
                              label: Text(l10n.careerPracticeGap),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                PrimaryButton(
                  label: l10n.careerAddSkill,
                  icon: Icons.add_rounded,
                  onPressed: () => _editSkill(context, ref, role: role),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Future<void> _editSkill(
  BuildContext context,
  WidgetRef ref, {
  required String role,
  CareerSkill? skill,
}) async {
  final l10n = context.l10n;
  final titleCtrl = TextEditingController(text: skill?.title ?? '');
  final evidenceCtrl = TextEditingController(text: skill?.evidenceTopic ?? '');
  var category = skill?.category ?? 'technical';
  var target = ((skill?.targetLevel ?? 0.8) * 100).round().toDouble();
  var current = ((skill?.currentLevel ?? 0.0) * 100).round().toDouble();

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(skill == null ? l10n.careerAddSkill : l10n.careerEditSkill),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: l10n.careerSkillTitleLabel),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: evidenceCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.careerEvidenceTopicLabel,
                      hintText: l10n.careerEvidenceTopicHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.careerCategoryLabel),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['technical', 'behavioral', 'tool', 'domain'].map((c) {
                      final label = switch (c) {
                        'technical' => 'Technical',
                        'behavioral' => 'Behavioral',
                        'tool' => 'Tool',
                        'domain' => 'Domain',
                        _ => c,
                      };
                      return ChoiceChip(
                        label: Text(label),
                        selected: category == c,
                        onSelected: (_) => setLocal(() => category = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.careerTargetLevelLabel(target.round())),
                  Slider(
                    value: target,
                    min: 40,
                    max: 100,
                    divisions: 12,
                    label: '${target.round()}%',
                    onChanged: (v) => setLocal(() => target = v),
                  ),
                  Text(l10n.careerCurrentLevelLabel(current.round())),
                  Slider(
                    value: current,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${current.round()}%',
                    onChanged: (v) => setLocal(() => current = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.commonSave),
              ),
            ],
          );
        },
      );
    },
  );

  if (saved != true) return;
  final title = titleCtrl.text.trim();
  if (title.isEmpty) return;

  final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
  final roleTitle = role.isNotEmpty ? role : (profile.goalContext.isNotEmpty ? profile.goalContext : 'Target role');

  await ref.read(goalProgressRepositoryProvider).upsertCareerSkill(
        uuid: skill?.uuid,
        roleTitle: roleTitle,
        title: title,
        category: category,
        targetLevel: target / 100,
        currentLevel: current / 100,
        evidenceTopic: evidenceCtrl.text.trim().isEmpty ? title : evidenceCtrl.text.trim(),
      );

  ref.invalidate(careerSkillsProvider);
  ref.invalidate(personalizationProvider);
  await ref.read(telemetryServiceProvider).emit('skill_updated', {
    'title': title,
    'category': category,
    'isNew': skill == null,
  });
}

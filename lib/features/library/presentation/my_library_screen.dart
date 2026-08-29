import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai_platform/ai_consent_gate.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/knowledge_source.dart';
import '../../../data/remote/ai/flashcard_generation_service.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';
import '../../../shared/widgets/primary_button.dart';

class MyLibraryScreen extends ConsumerStatefulWidget {
  const MyLibraryScreen({super.key, this.initialGoalMode});

  final String? initialGoalMode;

  @override
  ConsumerState<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends ConsumerState<MyLibraryScreen> {
  String _goalMode = 'learning';
  bool _consent = false;
  bool _busy = false;
  bool _busyFlashcards = false;

  @override
  void initState() {
    super.initState();
    _goalMode = widget.initialGoalMode ?? 'learning';
    _loadGoalFromProfile();
  }

  Future<void> _loadGoalFromProfile() async {
    if (widget.initialGoalMode != null) return;
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    if (mounted) setState(() => _goalMode = profile.goalMode);
  }

  Future<bool> _confirmResumeUpload() async {
    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resumeUploadConsentTitle),
        content: Text(l10n.resumeUploadConsentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.resumeUploadConsentDecline),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.resumeUploadConsentAccept),
          ),
        ],
      ),
    );
    return accepted == true;
  }

  String _libraryErrorMessage(Object e) {
    final l10n = context.l10n;
    if (e is LibraryException) {
      return switch (e.code) {
        'invalidUrl' => l10n.libraryErrorInvalidUrl,
        'httpsOnly' => l10n.libraryErrorHttpsOnly,
        'emptyPage' => l10n.libraryErrorEmptyPage,
        'notEnoughText' => l10n.libraryErrorNotEnoughText,
        'noContent' => l10n.libraryErrorNoContent,
        'invalidUpload' => l10n.libraryErrorInvalidUpload,
        'notResume' => l10n.libraryErrorNotResume,
        'notJd' => l10n.libraryErrorNotJd,
        'indexFailed' => l10n.libraryErrorIndexFailed,
        _ => l10n.libraryErrorIndexFailed,
      };
    }
    return l10n.libraryErrorIndexFailed;
  }

  Future<void> _upload(String type) async {
    final l10n = context.l10n;
    if (type == 'resume') {
      final accepted = await _confirmResumeUpload();
      if (!accepted) return;
    }
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.libraryConsentRequired)),
      );
      return;
    }
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'md', 'pdf'],
    );
    if (picked == null || picked.path == null) return;
    final path = picked.path!;
    final title = picked.name;

    setState(() => _busy = true);
    try {
      final repo = ref.read(knowledgeRepositoryProvider);
      final source = await repo.addFileSource(
        goalMode: _goalMode,
        type: type,
        title: title,
        sourceFilePath: path,
        consent: _consent,
      );
      try {
        await repo.indexSource(source.uuid);
      } catch (e) {
        await repo.deleteSource(source.uuid);
        rethrow;
      }
      ref.invalidate(knowledgeSourcesProvider(_goalMode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.libraryIndexed(title))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_libraryErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addWebsite() async {
    final l10n = context.l10n;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.libraryConsentRequired)),
      );
      return;
    }
    final urlController = TextEditingController();
    final titleController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.libraryAddWebsite),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: l10n.librarySourceTitle),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: l10n.libraryWebsiteUrl),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonAdd)),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(knowledgeRepositoryProvider);
      final url = urlController.text.trim();
      await repo.addAndIndexWebsite(
        goalMode: _goalMode,
        title: titleController.text.trim().isEmpty ? url : titleController.text.trim(),
        url: url,
        consent: _consent,
      );
      ref.invalidate(knowledgeSourcesProvider(_goalMode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.libraryIndexed(
            titleController.text.trim().isEmpty ? url : titleController.text.trim(),
          ))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_libraryErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generateFlashcards() async {
    if (_busyFlashcards) return;
    final provider = await ref.read(defaultAiProviderProvider.future);
    if (provider == null) return;
    final apiKey = await ref.read(providerRepositoryProvider).getApiKey(provider.uuid);
    if (apiKey == null || apiKey.isEmpty) return;

    setState(() => _busyFlashcards = true);
    try {
      final service = FlashcardGenerationService(
        aiPipeline: ref.read(aiRequestPipelineProvider),
        knowledgeRepository: ref.read(knowledgeRepositoryProvider),
        flashcardRepository: ref.read(flashcardRepositoryProvider),
      );
      final count = await service.generateFromLibrary(
        config: provider,
        apiKey: apiKey,
        goalMode: _goalMode,
      );
      if (!mounted) return;
      final l10n = context.l10n;
      if (count > 0) {
        ref.invalidate(flashcardsDueCountProvider(_goalMode));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.flashcardsCreatedSnackbar(count))),
        );
        context.push('/flashcards?goal=$_goalMode');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.libraryErrorNoContent)),
        );
      }
    } catch (e) {
      if (mounted) {
        await showAppErrorDialog(context, e, onRetry: _generateFlashcards);
      }
    } finally {
      if (mounted) setState(() => _busyFlashcards = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sourcesAsync = ref.watch(knowledgeSourcesProvider(_goalMode));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.librarySubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: 'learning',
                label: Text(
                  l10n.goalModeShortLearning,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              ButtonSegment(
                value: 'exam_prep',
                label: Text(
                  l10n.goalModeShortExam,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              ButtonSegment(
                value: 'career',
                label: Text(
                  l10n.goalModeShortCareer,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            selected: {_goalMode},
            onSelectionChanged: (v) => setState(() => _goalMode = v.first),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _consent,
            onChanged: (v) async {
              final enabled = v ?? false;
              setState(() => _consent = enabled);
              final current = AiConsentGate.instance.current;
              await AiConsentGate.instance.save(
                AiConsentPreferences(
                  piiUploadConsent: enabled,
                  sendChunksToProvider: enabled,
                  generationMode: current.generationMode,
                  economyMode: false,
                  transparencySeen: current.transparencySeen,
                ),
              );
            },
            title: Text(l10n.libraryRightsConsent),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (_goalMode == 'career') ...[
            PrimaryButton(
              label: l10n.libraryUploadResume,
              icon: Icons.upload_file_rounded,
              isLoading: _busy,
              onPressed: _busy ? null : () => _upload('resume'),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: l10n.libraryUploadJd,
              icon: Icons.work_outline_rounded,
              isLoading: _busy,
              onPressed: _busy ? null : () => _upload('jd'),
            ),
          ] else ...[
            PrimaryButton(
              label: l10n.libraryUploadNotes,
              icon: Icons.note_add_outlined,
              isLoading: _busy,
              onPressed: _busy ? null : () => _upload('notes'),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: l10n.libraryUploadBook,
              icon: Icons.menu_book_outlined,
              isLoading: _busy,
              onPressed: _busy ? null : () => _upload('book'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _addWebsite,
            icon: const Icon(Icons.language_rounded),
            label: Text(l10n.libraryAddWebsite),
          ),
          const SizedBox(height: 20),
          Text(l10n.libraryYourSources, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          sourcesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (sources) {
              final list = sources.cast<KnowledgeSource>();
              if (list.isEmpty) {
                return AppCard(child: Text(l10n.libraryEmpty));
              }
              return Column(
                children: list.map((s) => _SourceTile(source: s, goalMode: _goalMode)).toList(),
              );
            },
          ),
          Builder(
            builder: (context) {
              final sources = sourcesAsync.asData?.value ?? const [];
              final hasEnabledIndexed = sources
                  .cast<KnowledgeSource>()
                  .any((s) => s.enabled && s.status == 'indexed');
              if (!hasEnabledIndexed) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: _busyFlashcards ? null : _generateFlashcards,
                  icon: _busyFlashcards
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.style_rounded),
                  label: Text(l10n.libraryGenerateFlashcards),
                ),
              );
            },
          ),
          const ScrollableNativeAdSlot(slotId: 'my_library'),
        ],
      ),
    );
  }
}

class _SourceTile extends ConsumerWidget {
  const _SourceTile({required this.source, required this.goalMode});

  final KnowledgeSource source;
  final String goalMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repo = ref.read(knowledgeRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(source.title),
          subtitle: Text(
            source.statusMessage != null && source.statusMessage!.isNotEmpty
                ? '${l10n.librarySourceMeta(source.type, source.status)} - ${source.statusMessage}'
                : l10n.librarySourceMeta(source.type, source.status),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (action) async {
              switch (action) {
                case 'reindex':
                  await repo.indexSource(source.uuid);
                  ref.invalidate(knowledgeSourcesProvider(goalMode));
                case 'delete':
                  await repo.deleteSource(source.uuid);
                  ref.invalidate(knowledgeSourcesProvider(goalMode));
                case 'toggle':
                  await repo.setSourceEnabled(source.uuid, !source.enabled);
                  ref.invalidate(knowledgeSourcesProvider(goalMode));
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'reindex', child: Text(l10n.libraryReindex)),
              PopupMenuItem(
                value: 'toggle',
                child: Text(source.enabled ? l10n.libraryDisable : l10n.libraryEnable),
              ),
              PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
            ],
          ),
        ),
      ),
    );
  }
}

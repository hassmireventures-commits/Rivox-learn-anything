import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/agents/goal_agent.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/ai_engine_mode_store.dart';
import '../../../core/services/ai_status_service.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../shared/widgets/built_in_quota_dialog.dart';
import '../../../data/local/models/ai_provider_config.dart';
import '../../../data/remote/ai/ai_provider.dart';
import '../../../data/remote/ai/provider_connection_tester.dart';
import '../../../shared/widgets/ai_status_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/guidance/provider_guide_sheet.dart';
import '../../../shared/widgets/primary_button.dart';

class ProvidersScreen extends ConsumerStatefulWidget {
  const ProvidersScreen({super.key});

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(builtInQuotaProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final providersAsync = ref.watch(aiProvidersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.providersTitle),
        toolbarHeight: 56,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: const [AiStatusBadge(), SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openProviderEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.providersAddOwnButton),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          _BuiltInEngineInfo(),
          const SizedBox(height: 20),
          providersAsync.when(
            data: (providers) {
              if (providers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.providersEmptyState,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < providers.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    _ProviderTile(provider: providers[index]),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ],
      ),
    );
  }
}

Future<void> openProviderEditor(
  BuildContext context,
  WidgetRef ref, {
  AiProviderConfig? existing,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _ProviderEditor(existing: existing),
    ),
  );
  ref.invalidate(aiProvidersProvider);
  ref.invalidate(defaultAiProviderProvider);
}

class _BuiltInEngineInfo extends StatelessWidget {
  const _BuiltInEngineInfo();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.providersEngineSectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.providersBuiltinEngineHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends ConsumerWidget {
  const _ProviderTile({required this.provider});

  final AiProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final type = AiProviderType.fromId(provider.providerType);
    final isBuiltin = provider.uuid == BuiltInAiConfig.uuid || type.isBuiltin;
    final builtinRemaining =
        isBuiltin ? ref.watch(builtInQuotaProvider).asData?.value.remaining : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isBuiltin ? l10n.providersBuiltinName : provider.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (provider.isDefault)
                Chip(
                  label: Text(l10n.providersDefaultBadge),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isBuiltin
                ? l10n.providersBuiltinSubtitle
                : '${type.label} · ${provider.defaultModel}',
          ),
          if (!isBuiltin && provider.baseUrl != null) ...[
            const SizedBox(height: 2),
            Text(
              provider.baseUrl!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (builtinRemaining != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.providersBuiltinQuotaRemaining(builtinRemaining),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (isBuiltin)
                TextButton.icon(
                  onPressed: () async {
                    await showBuiltInQuotaDialog(context);
                    ref.invalidate(builtInQuotaProvider);
                  },
                  icon: const Icon(Icons.smart_display_outlined),
                  label: Text(l10n.builtinQuotaWatchAd),
                ),
              if (!provider.isDefault)
                TextButton(
                  onPressed: () async {
                    await ref.read(providerRepositoryProvider).setDefault(provider.uuid);
                    await ref.read(llmManagerProvider).setMode(AiEngineMode.cloud);
                    ref.invalidate(aiProvidersProvider);
                    ref.invalidate(defaultAiProviderProvider);
                    ref.invalidate(settingsProvider);
                    ref.invalidate(aiEngineModeProvider);
                    ref.invalidate(aiStudyPulseProvider);
                    ref.invalidate(aiStatusProvider);
                  },
                  child: Text(l10n.providersSetDefault),
                ),
              if (!isBuiltin)
                TextButton(
                  onPressed: () => openProviderEditor(context, ref, existing: provider),
                  child: Text(l10n.commonEdit),
                ),
              if (!isBuiltin)
                TextButton(
                  onPressed: () async {
                    await ref.read(providerRepositoryProvider).delete(provider.uuid);
                    ref.invalidate(aiProvidersProvider);
                    ref.invalidate(defaultAiProviderProvider);
                  },
                  child: Text(
                    l10n.commonDelete,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderEditor extends ConsumerStatefulWidget {
  const _ProviderEditor({this.existing});
  final AiProviderConfig? existing;

  @override
  ConsumerState<_ProviderEditor> createState() => _ProviderEditorState();
}

class _ProviderEditorState extends ConsumerState<_ProviderEditor> {
  final _formKey = GlobalKey<FormState>();
  late AiProviderType _type;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  bool _saving = false;
  bool _testing = false;
  String? _testResult;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing != null
        ? AiProviderType.fromId(existing.providerType)
        : AiProviderType.openai;
    _nameController = TextEditingController(text: existing?.name ?? _type.label);
    _keyController = TextEditingController();
    _baseUrlController = TextEditingController(
      text: existing?.baseUrl ?? _type.defaultBaseUrl,
    );
    _modelController = TextEditingController(
      text: existing?.defaultModel ?? _type.defaultModel,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<String?> _resolveApiKey() async {
    final trimmed = _keyController.text.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (widget.existing != null) {
      return ref.read(providerRepositoryProvider).getApiKey(widget.existing!.uuid);
    }
    return null;
  }

  AiProviderConfig _draftConfig() {
    final existing = widget.existing;
    final config = AiProviderConfig()
      ..providerType = _type.name
      ..defaultModel = _modelController.text.trim()
      ..baseUrl = _baseUrlController.text.trim().isEmpty
          ? null
          : _baseUrlController.text.trim()
      ..name = _nameController.text.trim();
    if (existing != null) {
      config
        ..uuid = existing.uuid
        ..createdAt = existing.createdAt
        ..isDefault = existing.isDefault;
    }
    return config;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final apiKey = await _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.providersApiKeyRequired)),
      );
      return;
    }

    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final result = await ProviderConnectionTester.testWithGreeting(
        config: _draftConfig(),
        apiKey: apiKey,
      );
      if (!mounted) return;
      setState(() => _testResult = l10n.providersConnectionOk);
      await _showGreetingDialog(result.reply);
      ref.read(aiStatusProvider.notifier).checkNow();
    } on AppException catch (e) {
      if (mounted) setState(() => _testResult = e.message);
    } catch (e) {
      if (mounted) setState(() => _testResult = '$e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _showGreetingDialog(String reply) async {
    if (!mounted) return;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.providersTestGreetingTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.providersTestGreetingSent,
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.providersTestGreetingReply,
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              reply,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonDismiss),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();

    final baseUrl = _baseUrlController.text.trim();
    if (baseUrl.isNotEmpty && baseUrl.startsWith('http://')) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.providersInsecureEndpointTitle),
          content: Text(l10n.providersInsecureEndpointBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.providersInsecureUseAnyway)),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (baseUrl.isNotEmpty &&
        !baseUrl.startsWith('https://') &&
        !baseUrl.startsWith('http://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.providersBaseUrlMustHttps)),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(providerRepositoryProvider);
    try {
      final apiKey = await _resolveApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw const InvalidApiKeyException();
      }

      final draft = _draftConfig();
      await ProviderConnectionTester.test(config: draft, apiKey: apiKey);

      AiProviderConfig saved;
      if (widget.existing == null) {
        saved = await repo.add(
          name: _nameController.text,
          providerType: _type.name,
          apiKey: apiKey,
          defaultModel: _modelController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
          setAsDefault: true,
        );
      } else {
        saved = await repo.update(
          uuid: widget.existing!.uuid,
          name: _nameController.text,
          providerType: _type.name,
          defaultModel: _modelController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
          apiKey: _keyController.text.trim().isEmpty ? null : _keyController.text.trim(),
        );
      }
      ref.read(circuitBreakerProvider).reset(saved.uuid);
      await ref.read(llmManagerProvider).setMode(AiEngineMode.cloud);
      ref.invalidate(aiEngineModeProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.pop(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.providersSavedSnackbar)),
      );
      ref.read(aiStatusProvider.notifier).checkNow();
      // First-time provider → trigger AI goal seeding in background
      if (widget.existing == null) {
        final topicCount = await ref.read(learnerRepositoryProvider).allTopics().then((t) => t.length);
        if (topicCount == 0) {
          unawaited(GoalAgent(ref).seedOnFirstProvider());
          messenger?.showSnackBar(
            SnackBar(content: Text(l10n.goalAgentSeeding)),
          );
        }
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.providersSaveFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? l10n.providersAddTitle : l10n.providersEditTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AiProviderType>(
                key: ValueKey(_type),
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.providersProviderLabel),
                items: AiProviderType.values
                    .where((t) => !t.isBuiltin)
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    if (widget.existing == null) {
                      _nameController.text = value.label;
                      _modelController.text = value.defaultModel;
                      _baseUrlController.text = value.defaultBaseUrl;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.providersDisplayName),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.commonRequired : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => showProviderGuideSheet(context, type: _type),
                  icon: const Icon(Icons.help_outline_rounded),
                  label: Text(l10n.providerGuideHowTo),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _keyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: widget.existing == null ? l10n.providersApiKey : l10n.providersApiKeyOptional,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                validator: (v) {
                  if (widget.existing == null && (v == null || v.trim().isEmpty)) {
                    return l10n.providersApiKeyRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(
                  labelText: l10n.providersBaseUrl,
                  hintText: l10n.providersBaseUrlHint,
                ),
                validator: (v) {
                  if (_type == AiProviderType.custom && (v == null || v.trim().isEmpty)) {
                    return l10n.providersBaseUrlRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: l10n.providersDefaultModel),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.commonRequired : null,
              ),
              const SizedBox(height: 20),
              if (_testResult != null) ...[
                Text(
                  _testResult!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _testResult == l10n.providersConnectionOk
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_saving || _testing) ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering_rounded),
                      label: Text(_testing ? l10n.providersTesting : l10n.providersTestConnection),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.providersSaveButton,
                      isLoading: _saving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/ai_engine_mode_store.dart';
import '../../../core/services/ai_status_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/ai_provider_config.dart';
import '../../../data/remote/ai/ai_provider.dart';
import '../../../data/remote/ai/provider_connection_tester.dart';
import '../../../data/remote/ai/provider_error_mapper.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/guidance/provider_guide_sheet.dart';
import '../../../shared/widgets/primary_button.dart';

/// Onboarding AI step: Built-in AI (skip) or add a cloud provider.
class OnboardingProviderStep extends ConsumerStatefulWidget {
  const OnboardingProviderStep({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.onTryDemo,
    this.requireLegalConsent = false,
    this.showHeader = true,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  /// Optional demo path (unused on welcome; kept for callers).
  final VoidCallback? onTryDemo;
  final bool requireLegalConsent;
  final bool showHeader;

  @override
  ConsumerState<OnboardingProviderStep> createState() => _OnboardingProviderStepState();
}

enum _OnboardingAiPath { choose, cloud }

class _OnboardingProviderStepState extends ConsumerState<OnboardingProviderStep> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  AiProviderType _type = AiProviderType.openai;
  bool _saving = false;
  String? _error;
  bool _obscureKey = true;
  bool _legalAccepted = false;
  _OnboardingAiPath _path = _OnboardingAiPath.choose;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  bool get _canProceed => !widget.requireLegalConsent || _legalAccepted;

  Future<void> _saveCloudAndContinue() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'API key is required for a cloud provider.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final draft = AiProviderConfig()
        ..providerType = _type.name
        ..defaultModel = _type.defaultModel
        ..baseUrl = _type.defaultBaseUrl.isEmpty ? null : _type.defaultBaseUrl;

      await ProviderConnectionTester.test(config: draft, apiKey: key);

      await ref.read(providerRepositoryProvider).add(
            name: _type.label,
            providerType: _type.name,
            apiKey: key,
            defaultModel: _type.defaultModel,
            baseUrl: _type.defaultBaseUrl.isEmpty ? null : _type.defaultBaseUrl,
            setAsDefault: true,
          );

      await ref.read(llmManagerProvider).setMode(AiEngineMode.cloud);
      ref.invalidate(aiProvidersProvider);
      ref.invalidate(defaultAiProviderProvider);
      ref.invalidate(aiEngineModeProvider);
      ref.read(aiStatusProvider.notifier).checkNow();

      if (!mounted) return;
      widget.onContinue();
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is DioException
              ? ProviderErrorMapper.map(e).message
              : 'Could not save cloud provider. Check the API key and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader) ...[
          Text(
            l10n.onboardingConnectAiTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingConnectAiSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppTheme.cardGap),
        ],
        if (widget.requireLegalConsent) ...[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _legalAccepted,
                  onChanged: (v) => setState(() => _legalAccepted = v ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.legalAgreeCheckbox, style: theme.textTheme.bodyMedium),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/legal/terms'),
                            child: Text(l10n.legalViewTerms),
                          ),
                          TextButton(
                            onPressed: () => context.push('/legal/privacy'),
                            child: Text(l10n.legalViewPrivacy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.cardGap),
        ],
        if (_path == _OnboardingAiPath.choose) ...[
          _ChoiceCard(
            title: l10n.onboardingEngineCloudTitle,
            subtitle: l10n.onboardingEngineCloudSubtitle,
            icon: Icons.cloud_outlined,
            onTap: _canProceed && !_saving
                ? () => setState(() => _path = _OnboardingAiPath.cloud)
                : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: _saving || !_canProceed ? null : widget.onSkip,
            child: Text(
              l10n.onboardingSkipProvider,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.85)),
            ),
          ),
        ] else if (_path == _OnboardingAiPath.cloud) ...[
          Form(
            key: _formKey,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<AiProviderType>(
                    initialValue: _type,
                    decoration: InputDecoration(
                      labelText: l10n.providersProviderLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: AiProviderType.values
                        .where((t) => !t.isBuiltin)
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                  ),
                  const SizedBox(height: 8),
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
                      labelText: l10n.providersApiKey,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.cardGap),
          PrimaryButton(
            label: l10n.onboardingConnectAiContinue,
            icon: Icons.key_rounded,
            isLoading: _saving,
            onPressed: _canProceed ? _saveCloudAndContinue : null,
          ),
          TextButton(
            onPressed: _saving
                ? null
                : () => setState(() {
                      _path = _OnboardingAiPath.choose;
                      _error = null;
                    }),
            child: Text(l10n.onboardingEngineBackToChoice),
          ),
        ],
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              enabled ? Icons.chevron_right_rounded : Icons.schedule_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

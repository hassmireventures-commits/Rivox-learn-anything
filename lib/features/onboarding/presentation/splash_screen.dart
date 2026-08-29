import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/daily_content_scheduler.dart';
import '../../../core/services/daily_quiz_scheduler.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final startTime = DateTime.now();
    try {
      await _bootstrapCore().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Never block the user on optional startup work.
    }

    // Show the logo for at least 400ms on fast devices; skip the wait if
    // bootstrap itself took longer (removes the old hard 700ms waste).
    const minimum = Duration(milliseconds: 400);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minimum) {
      await Future<void>.delayed(minimum - elapsed);
    }

    if (!mounted) return;

    final profile = await ref.read(profileRepositoryProvider).getProfile();
    if (!mounted) return;

    if (profile == null) {
      context.go('/welcome');
      return;
    }

    context.go('/dashboard');
  }

  Future<void> _bootstrapCore() async {
    final telemetry = ref.read(telemetryServiceProvider);
    telemetry.startSession();
    await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    try {
      await ref.read(providerRepositoryProvider).ensureBuiltInSeeded();
      ref.invalidate(aiProvidersProvider);
      ref.invalidate(defaultAiProviderProvider);
      ref.invalidate(aiEngineModeProvider);
    } catch (_) {}
    await ref.read(learningOrchestratorProvider).ensureStrategies();
    try {
      await ref.read(recommendationEngineProvider).refreshRecommendations();
      unawaited(ref.read(dailyQuizSchedulerProvider).trySchedule());
      unawaited(ref.read(dailyContentSchedulerProvider).trySchedule());
      unawaited(
        ref.read(anonAnalyticsSyncProvider).syncIfOptedIn().catchError((_) {}),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryPurpleGradient,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  AppConstants.brandingLogoAsset,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 72, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.splashByOrganization(l10n.organizationName),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.brandGold,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.organizationTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

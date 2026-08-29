import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import 'ai_readiness_service.dart';
import 'ai_study_pulse_service.dart';

enum AiProviderCheckStatus { connecting, online, offline }

class AiProviderStatusState {
  const AiProviderStatusState({
    required this.status,
    this.providerName,
    this.detail,
    this.lastChecked,
    this.handshakeLatencyMs,
  });

  final AiProviderCheckStatus status;
  final String? providerName;
  final String? detail;
  final DateTime? lastChecked;
  final int? handshakeLatencyMs;

  AiProviderStatusState copyWith({
    AiProviderCheckStatus? status,
    String? providerName,
    String? detail,
    DateTime? lastChecked,
    int? handshakeLatencyMs,
  }) {
    return AiProviderStatusState(
      status: status ?? this.status,
      providerName: providerName ?? this.providerName,
      detail: detail ?? this.detail,
      lastChecked: lastChecked ?? this.lastChecked,
      handshakeLatencyMs: handshakeLatencyMs ?? this.handshakeLatencyMs,
    );
  }

  bool get isOnline => status == AiProviderCheckStatus.online;
}

class AiStatusNotifier extends Notifier<AiProviderStatusState>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  AiProviderStatusState build() {
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => _runCheck(isManual: true));
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _runCheck());
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
    });
    return const AiProviderStatusState(status: AiProviderCheckStatus.connecting);
  }

  Future<void> checkNow() => _runCheck(isManual: true);

  AiReadinessService _readiness() {
    return AiReadinessService(
      providerRepository: ref.read(providerRepositoryProvider),
      usageTracker: ref.read(usageTrackerProvider),
      circuitBreaker: ref.read(circuitBreakerProvider),
    );
  }

  Future<void> _runCheck({bool isManual = false}) async {
    if (!ref.mounted) return;
    if (isManual) {
      _readiness().invalidateCache();
      state = state.copyWith(status: AiProviderCheckStatus.connecting, detail: null);
    }

    final result = await _readiness().evaluate(forceRefresh: isManual);
    if (!ref.mounted) return;

    state = AiProviderStatusState(
      status: result.ready ? AiProviderCheckStatus.online : AiProviderCheckStatus.offline,
      providerName: result.providerName,
      detail: result.detail,
      lastChecked: DateTime.now(),
      handshakeLatencyMs: result.handshakeLatencyMs,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 60),
        (_) => _runCheck(),
      );
      _runCheck();
    }
  }
}

final aiStatusProvider =
    NotifierProvider<AiStatusNotifier, AiProviderStatusState>(AiStatusNotifier.new);

final aiReadinessServiceProvider = Provider<AiReadinessService>((ref) {
  return AiReadinessService(
    providerRepository: ref.watch(providerRepositoryProvider),
    usageTracker: ref.watch(usageTrackerProvider),
    circuitBreaker: ref.watch(circuitBreakerProvider),
  );
});

final aiStudyPulseProvider =
    AsyncNotifierProvider<AiStudyPulseNotifier, AiStudyPulseResult>(
  AiStudyPulseNotifier.new,
);

class AiStudyPulseNotifier extends AsyncNotifier<AiStudyPulseResult> {
  @override
  Future<AiStudyPulseResult> build() => _fetch(forceRefresh: false);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
    await ref.read(aiStatusProvider.notifier).checkNow();
  }

  Future<AiStudyPulseResult> _fetch({required bool forceRefresh}) async {
    final personalization = await ref.read(personalizationProvider.future);
    final service = AiStudyPulseService(
      llmManager: ref.read(llmManagerProvider),
    );
    return service.load(
      goalMode: personalization.goalMode,
      goalLabel: personalization.goalContextLabel,
      weakTopics: personalization.weakTopics,
      focusTitles: personalization.focusTitles,
      forceRefresh: forceRefresh,
    );
  }
}

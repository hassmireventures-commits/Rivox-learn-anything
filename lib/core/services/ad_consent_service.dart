import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Requests ad consent where required (UMP on Android/iOS).
///
/// Returns `true` only when ads may be requested. Transient failures are
/// retried after a cooldown so widgets are not permanently blocked.
class AdConsentService {
  AdConsentService._();

  static bool? _canRequestAds;
  static Completer<bool>? _inFlight;
  static DateTime? _lastDeniedAt;
  static const _retryCooldown = Duration(seconds: 45);

  /// Last resolved consent result, or `null` while UMP has not finished.
  static bool? get canRequestAds => _canRequestAds;

  /// Whether [requestIfNeeded] has completed (success or fail-closed).
  static bool get isResolved => _canRequestAds != null;

  /// Clears a cached denial so the next load can re-run UMP (e.g. after retry).
  static void invalidateCachedDenial() {
    if (_canRequestAds == true) return;
    _canRequestAds = null;
    _lastDeniedAt = null;
    _inFlight = null;
  }

  static bool _shouldRetryAfterDenial() {
    if (_canRequestAds != false) return true;
    final deniedAt = _lastDeniedAt;
    if (deniedAt == null) return true;
    return DateTime.now().difference(deniedAt) >= _retryCooldown;
  }

  /// Completes when UMP has finished (form shown if needed) and reports whether
  /// [ConsentInformation.canRequestAds] is true.
  static Future<bool> requestIfNeeded() async {
    if (_canRequestAds == true) return true;
    if (!_shouldRetryAfterDenial()) return false;
    if (_canRequestAds == false) {
      invalidateCachedDenial();
    }
    if (_inFlight != null) return _inFlight!.future;

    final completer = Completer<bool>();
    _inFlight = completer;

    try {
      if (kIsWeb) {
        _finish(false, completer);
        return false;
      }

      final params = ConsentRequestParameters(
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyOther,
              )
            : null,
      );

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            if (await ConsentInformation.instance.isConsentFormAvailable()) {
              final formCompleter = Completer<void>();
              ConsentForm.loadAndShowConsentFormIfRequired((formError) {
                if (formError != null && kDebugMode) {
                  debugPrint(
                    '[UMP] Consent form error: ${formError.errorCode} '
                    '${formError.message}',
                  );
                }
                if (!formCompleter.isCompleted) formCompleter.complete();
              });
              await formCompleter.future.timeout(const Duration(seconds: 20));
            }
            final canRequest =
                await ConsentInformation.instance.canRequestAds();
            if (kDebugMode) {
              debugPrint('[UMP] canRequestAds=$canRequest');
            }
            _finish(canRequest, completer);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[UMP] Consent flow exception: $e');
            }
            await _finishFromCanRequestAdsFallback(completer);
          }
        },
        (FormError error) async {
          if (kDebugMode) {
            debugPrint(
              '[UMP] requestConsentInfoUpdate failed: ${error.errorCode} '
              '${error.message}',
            );
          }
          await _finishFromCanRequestAdsFallback(completer);
        },
      );

      return await completer.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () async {
          if (kDebugMode) {
            debugPrint('[UMP] Consent timed out — checking canRequestAds');
          }
          await _finishFromCanRequestAdsFallback(completer);
          return _canRequestAds ?? false;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[UMP] Consent unavailable: $e');
      await _finishFromCanRequestAdsFallback(completer);
      return _canRequestAds ?? false;
    }
  }

  static Future<void> _finishFromCanRequestAdsFallback(
    Completer<bool> completer,
  ) async {
    try {
      final canRequest = await ConsentInformation.instance.canRequestAds();
      _finish(canRequest, completer);
    } catch (_) {
      // Release builds stay fail-closed; debug allows SDK test ads after init.
      _finish(kDebugMode, completer);
    }
  }

  static void _finish(bool value, Completer<bool> completer) {
    _canRequestAds = value;
    if (!value) {
      _lastDeniedAt = DateTime.now();
    } else {
      _lastDeniedAt = null;
    }
    if (!completer.isCompleted) completer.complete(value);
    if (identical(_inFlight, completer)) _inFlight = null;
  }
}

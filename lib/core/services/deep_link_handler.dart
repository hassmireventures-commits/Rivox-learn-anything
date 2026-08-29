import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';

/// Handles `learnanything://…` cold starts and warm links.
class DeepLinkHandler {
  DeepLinkHandler._();
  static final instance = DeepLinkHandler._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GoRouter? _router;

  void bindRouter(GoRouter router) {
    _router = router;
  }

  Future<void> start() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _open(initial);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DeepLink initial: $e');
    }
    await _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      _open,
      onError: (e) {
        if (kDebugMode) debugPrint('DeepLink stream: $e');
      },
    );
  }

  void _open(Uri uri) {
    final router = _router;
    if (router == null) return;
    if (uri.scheme != AppConstants.deepLinkScheme) return;

    // learnanything://quiz/create?topic=...&difficulty=...&count=...
    final path = uri.host.isNotEmpty
        ? '/${uri.host}${uri.path}'
        : (uri.path.startsWith('/') ? uri.path : '/${uri.path}');
    final normalized = path.replaceAll(RegExp(r'/+'), '/');
    final location = uri.hasQuery ? '$normalized?${uri.query}' : normalized;
    router.go(location.isEmpty ? '/dashboard' : location);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}

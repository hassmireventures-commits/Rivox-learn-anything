import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';

/// Global floating entry point into the RAG chat (B1), added to the same
/// [Stack] as [GenerationTopBanner] in `app.dart` so it doesn't require
/// touching Home/Learn/Settings screen files.
///
/// Hidden on screens where it would only get in the way: onboarding
/// (splash/welcome), the chat screen itself, and while a quiz is actively
/// being played.
class ChatEntryFab extends StatefulWidget {
  const ChatEntryFab({super.key});

  @override
  State<ChatEntryFab> createState() => _ChatEntryFabState();
}

class _ChatEntryFabState extends State<ChatEntryFab> {
  static const _hiddenOnPrefixes = [
    '/splash',
    '/welcome',
    '/chat',
    '/quiz/play',
    // Already has its own bottom-right FAB (add provider).
    '/settings/providers',
  ];

  // Home/Learn/History live inside AppShell, which has its own
  // bottomNavigationBar — lift the FAB clear of it there.
  static const _shellRoutePrefixes = ['/dashboard', '/learn', '/history'];

  @override
  void initState() {
    super.initState();
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() => setState(() {});

  String get _currentPath => appRouter.routerDelegate.currentConfiguration.uri.path;

  bool get _shouldShow {
    final path = _currentPath;
    return !_hiddenOnPrefixes.any((prefix) => path.startsWith(prefix));
  }

  bool get _onShellRoute {
    final path = _currentPath;
    return _shellRoutePrefixes.any((prefix) => path.startsWith(prefix));
  }

  @override
  Widget build(BuildContext context) {
    final show = _shouldShow;
    // Home/Learn/History have their own bottomNavigationBar (~72dp) — clear it.
    final bottomInset = _onShellRoute ? 88.0 : 16.0;
    return IgnorePointer(
      ignoring: !show,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: show ? Offset.zero : const Offset(0, 1.4),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: show ? 1 : 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 16, bottomInset),
                child: FloatingActionButton(
                  heroTag: 'chatEntryFab',
                  onPressed: () => appRouter.push('/chat'),
                  child: const Icon(Icons.forum_outlined),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

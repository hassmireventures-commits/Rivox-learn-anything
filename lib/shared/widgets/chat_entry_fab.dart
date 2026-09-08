import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_path_observer.dart';
import '../../core/services/chat_fab_position_store.dart';

/// Global floating entry point into the RAG chat (B1), added to the same
/// [Stack] as [GenerationTopBanner] in `app.dart` so it doesn't require
/// touching Home/Learn/Settings screen files.
///
/// Shown only when [currentRoutePath] is `null` — i.e. nothing is pushed on
/// top of a shell tab (Home/Learn/History). This is a general fix (not a
/// per-screen special case): every pushed screen (Settings, Create Quiz,
/// quiz play, the chat screen itself, Library, career/exam modules, legal,
/// etc.) reliably hides it, regardless of whether it was reached via
/// `push()` or `go()` — see `route_path_observer.dart` for why the old
/// `routerDelegate.currentConfiguration.uri.path` check couldn't do this.
///
/// Draggable, Samsung-Edge-panel-handle style: the user can drag it
/// vertically and it snaps to whichever side (left/right) is closer on
/// release, remembering that choice via [ChatFabPositionStore].
class ChatEntryFab extends StatefulWidget {
  const ChatEntryFab({super.key});

  @override
  State<ChatEntryFab> createState() => _ChatEntryFabState();
}

class _ChatEntryFabState extends State<ChatEntryFab> {
  static const _fabSize = 56.0;
  static const _edgeMargin = 16.0;
  // Keep clear of the status bar / top banners above, and the bottom-nav /
  // composer zones below, on every screen this can show on.
  static const _topSafeMargin = 96.0;
  static const _bottomSafeMargin = 96.0;

  ChatFabPosition _position = ChatFabPositionStore.instance.current;
  double? _dragVerticalFraction;
  bool? _dragOnRight;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    currentRoutePath.addListener(_onRouteChanged);
    _load();
  }

  Future<void> _load() async {
    final pos = await ChatFabPositionStore.instance.load();
    if (!mounted) return;
    setState(() {
      _position = pos;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    currentRoutePath.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() => setState(() {});

  bool get _shouldShow => currentRoutePath.value == null;

  double _fractionFromGlobalDy(double globalDy, double safeTop, double availableHeight) {
    if (availableHeight <= 0) return _position.verticalFraction;
    return ((globalDy - safeTop) / availableHeight).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final show = _shouldShow;
    final size = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top + _topSafeMargin;
    final safeBottom = MediaQuery.paddingOf(context).bottom + _bottomSafeMargin;
    final availableHeight = (size.height - safeTop - safeBottom - _fabSize).clamp(
      0.0,
      double.infinity,
    );

    final dragging = _dragVerticalFraction != null;
    final verticalFraction = _dragVerticalFraction ?? _position.verticalFraction;
    final onRight = dragging ? (_dragOnRight ?? true) : _position.edge != 'left';
    final top = safeTop + verticalFraction * availableHeight;

    return IgnorePointer(
      ignoring: !show || !_loaded,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: dragging ? Duration.zero : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            right: onRight ? _edgeMargin : null,
            left: onRight ? null : _edgeMargin,
            top: top,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: show ? 1 : 0,
              child: GestureDetector(
                onPanStart: (_) {
                  setState(() {
                    _dragVerticalFraction = verticalFraction;
                    _dragOnRight = onRight;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragVerticalFraction = _fractionFromGlobalDy(
                      details.globalPosition.dy,
                      safeTop,
                      availableHeight,
                    );
                    _dragOnRight = details.globalPosition.dx > size.width / 2;
                  });
                },
                onPanEnd: (_) async {
                  final newPosition = ChatFabPosition(
                    edge: (_dragOnRight ?? true) ? 'right' : 'left',
                    verticalFraction: _dragVerticalFraction ?? _position.verticalFraction,
                  );
                  setState(() {
                    _position = newPosition;
                    _dragVerticalFraction = null;
                    _dragOnRight = null;
                  });
                  await ChatFabPositionStore.instance.save(newPosition);
                },
                child: FloatingActionButton(
                  heroTag: 'chatEntryFab',
                  onPressed: () => appRouter.push('/chat'),
                  child: const Icon(Icons.forum_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

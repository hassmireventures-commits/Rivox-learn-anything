import 'package:ai_quiz_app/core/router/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Minimal copy of the real router's shape: a StatefulShellRoute with keyed
/// branch navigators, plus a root-level /chat route pushed above it.
GoRouter _router() {
  final root = GlobalKey<NavigatorState>();
  final homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final historyKey = GlobalKey<NavigatorState>(debugLabel: 'history');
  return GoRouter(
    navigatorKey: root,
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: Text('tab ${shell.currentIndex}'),
        ),
        branches: [
          StatefulShellBranch(navigatorKey: homeKey, routes: [
            GoRoute(path: '/dashboard', builder: (_, _) => const Text('HOME BODY')),
          ]),
          StatefulShellBranch(navigatorKey: historyKey, routes: [
            GoRoute(path: '/history', builder: (_, _) => const Text('HISTORY BODY')),
          ]),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (context, _) => Scaffold(
          body: TextButton(
            onPressed: () => openAppRoute(context, '/history'),
            child: const Text('open history'),
          ),
        ),
      ),
    ],
  );
}

void main() {
  test('isShellTabRoute matches tab paths, with or without query', () {
    expect(isShellTabRoute('/history'), isTrue);
    expect(isShellTabRoute('/learn?tab=paths'), isTrue);
    expect(isShellTabRoute('/dashboard'), isTrue);
    expect(isShellTabRoute('/library'), isFalse);
    expect(isShellTabRoute('/quiz/play/abc'), isFalse);
  });

  testWidgets('opening a tab route from chat shows the tab body, not a blank shell',
      (tester) async {
    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/chat');
    await tester.pumpAndSettle();

    await tester.tap(find.text('open history'));
    await tester.pumpAndSettle();

    expect(find.text('HISTORY BODY'), findsOneWidget);
    expect(find.text('tab 1'), findsOneWidget);
    expect(find.text('open history'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

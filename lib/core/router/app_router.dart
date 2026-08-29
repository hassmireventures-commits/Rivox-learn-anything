import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../locale/app_localizations_ext.dart';
import '../services/daily_content_service.dart';

import '../../features/career/presentation/drill_create_screen.dart';
import '../../features/career/presentation/voice_interview_hub_screen.dart';
import '../../features/career/presentation/skill_matrix_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/exam/presentation/mock_create_screen.dart';
import '../../features/exam/presentation/study_plan_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/learn/presentation/daily_content_detail_screen.dart';
import '../../features/learn/presentation/flashcard_review_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/learn/presentation/path_detail_screen.dart';
import '../../features/learn/presentation/resource_webview_args.dart';
import '../../features/learn/presentation/resource_webview_screen.dart';
import '../../features/learn/presentation/saved_articles_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/quiz/presentation/create_quiz_screen.dart';
import '../../features/quiz/presentation/quiz_play_screen.dart';
import '../../features/quiz/presentation/results_screen.dart';
import '../../features/settings/presentation/providers_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/legal/presentation/legal_document_screen.dart';
import '../../features/guidance/presentation/help_center_screen.dart';
import '../../features/library/presentation/my_library_screen.dart';
import '../../features/support/presentation/support_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorLearnKey = GlobalKey<NavigatorState>(debugLabel: 'learn');
final _shellNavigatorHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'history');

/// Zero-duration cut - used only for /splash and /welcome (no spatial context).
Page<void> _instantPage({required Widget child, LocalKey? key}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

/// Standard push - delegates to the platform transition defined in AppTheme.
/// All content routes (quiz, settings, paths, results, …) use this.
Page<void> _pushPage({required Widget child, LocalKey? key}) {
  return MaterialPage<void>(key: key, child: child);
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _instantPage(child: const SplashScreen()),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) => _instantPage(child: const WelcomeScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLearnKey,
          routes: [
            GoRoute(
              path: '/learn',
              pageBuilder: (context, state) => const NoTransitionPage(child: LearnScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHistoryKey,
          routes: [
            GoRoute(
              path: '/history',
              pageBuilder: (context, state) => const NoTransitionPage(child: HistoryScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/saved-articles',
      pageBuilder: (context, state) => _pushPage(
        child: const SavedArticlesScreen(),
      ),
    ),
    GoRoute(
      path: '/flashcards',
      pageBuilder: (context, state) {
        final goal = state.uri.queryParameters['goal'];
        return _pushPage(child: FlashcardReviewScreen(goalMode: goal));
      },
    ),
    GoRoute(
      path: '/resource',
      pageBuilder: (context, state) {
        final extra = state.extra;
        late final String url;
        late final String title;
        late final String topic;
        if (extra is ResourceWebViewArgs) {
          url = extra.url;
          title = extra.title;
          topic = extra.topic;
        } else {
          url = (state.uri.queryParameters['url'] ?? '').trim();
          title = (state.uri.queryParameters['title'] ?? 'Resource').trim();
          topic = (state.uri.queryParameters['topic'] ?? '').trim();
        }
        return _pushPage(
          child: ResourceWebViewScreen(
            url: url,
            title: title.isEmpty ? 'Resource' : title,
            topic: topic,
          ),
        );
      },
    ),
    GoRoute(
      path: '/daily-content',
      pageBuilder: (context, state) {
        final extra = state.extra;
        DailyContentPack? pack;
        DailyContentItem? item;
        if (extra is DailyContentPack) {
          pack = extra;
        } else if (extra is DailyContentItem) {
          item = extra;
        }
        return _pushPage(
          child: DailyContentDetailScreen(
            initialPack: pack,
            initialItem: item,
          ),
        );
      },
    ),
    GoRoute(
      path: '/paths/:id',
      pageBuilder: (context, state) => _pushPage(
        child: PathDetailScreen(pathId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/quiz/create',
      pageBuilder: (context, state) {
        final topic = state.uri.queryParameters['topic'];
        return _pushPage(
          child: CreateQuizScreen(initialTopic: topic),
        );
      },
    ),
    GoRoute(
      path: '/quiz/play/:id',
      pageBuilder: (context, state) => _pushPage(
        child: QuizPlayScreen(
          quizId: state.pathParameters['id']!,
          voiceMode: state.uri.queryParameters['voice'] == '1',
          interviewPersona: state.uri.queryParameters['persona'],
        ),
      ),
    ),
    GoRoute(
      path: '/quiz/results/:id',
      pageBuilder: (context, state) => _pushPage(
        child: ResultsScreen(
          quizId: state.pathParameters['id']!,
          voiceInterview: state.uri.queryParameters['voice'] == '1',
          interviewPersona: state.uri.queryParameters['persona'],
        ),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _pushPage(child: const SettingsScreen()),
    ),
    GoRoute(
      path: '/exam/mock/create',
      pageBuilder: (context, state) => _pushPage(child: const MockCreateScreen()),
    ),
    GoRoute(
      path: '/exam/plan',
      pageBuilder: (context, state) => _pushPage(child: const StudyPlanScreen()),
    ),
    GoRoute(
      path: '/career/matrix',
      pageBuilder: (context, state) => _pushPage(child: const SkillMatrixScreen()),
    ),
    GoRoute(
      path: '/career/voice-interview',
      pageBuilder: (context, state) => _pushPage(child: const VoiceInterviewHubScreen()),
    ),
    GoRoute(
      path: '/career/drill/create',
      pageBuilder: (context, state) => _pushPage(child: const DrillCreateScreen()),
    ),
    GoRoute(
      path: '/settings/providers',
      pageBuilder: (context, state) => _pushPage(child: const ProvidersScreen()),
    ),
    GoRoute(
      path: '/legal/:docId',
      pageBuilder: (context, state) => _pushPage(
        child: LegalDocumentScreen(documentId: state.pathParameters['docId']!),
      ),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => _pushPage(child: const HelpCenterScreen()),
    ),
    GoRoute(
      path: '/library',
      pageBuilder: (context, state) {
        final goal = state.uri.queryParameters['goal'];
        return _pushPage(child: MyLibraryScreen(initialGoalMode: goal));
      },
    ),
    GoRoute(
      path: '/support',
      pageBuilder: (context, state) => _pushPage(child: const SupportScreen()),
    ),
  ],
  errorBuilder: (context, state) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(child: Text(l10n.routerPageNotFound(state.uri.toString()))),
    );
  },
);

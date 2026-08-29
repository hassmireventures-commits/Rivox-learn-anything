import '../../l10n/app_localizations.dart';

class L10nHelpers {
  L10nHelpers._();

  static List<String> quizGenerationMessages(AppLocalizations l10n) => [
        l10n.generationQuizConnecting,
        l10n.generationQuizReadingPattern,
        l10n.generationQuizCrafting,
        l10n.generationQuizPolishing,
        l10n.generationQuizChecking,
        l10n.generationQuizAlmostReady,
      ];

  static List<String> pathGenerationMessages(AppLocalizations l10n) => [
        l10n.generationPathMapping,
        l10n.generationPathScanningDocs,
        l10n.generationPathCurating,
        l10n.generationPathFindingVideos,
        l10n.generationPathSequencing,
        l10n.generationPathBuilding,
      ];

  static String difficultyLabel(AppLocalizations l10n, String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'easy' => l10n.difficultyEasy,
      'medium' => l10n.difficultyMedium,
      'hard' => l10n.difficultyHard,
      'expert' => l10n.difficultyExpert,
      _ => difficulty,
    };
  }

  static String quizKindLabel(AppLocalizations l10n, String quizKind) {
    return switch (quizKind) {
      'module' => l10n.quizKindModule,
      'multiplayer' => l10n.quizKindMultiplayer,
      'mock' => l10n.quizKindMock,
      'interview' => l10n.quizKindInterview,
      'daily' => l10n.quizKindDaily,
      _ => l10n.quizKindQuick,
    };
  }

  static String pathModuleStatus(AppLocalizations l10n, {required bool done, required bool current}) {
    if (done) return l10n.pathStatusCompleted;
    if (current) return l10n.pathStatusUpNext;
    return l10n.pathStatusUpcoming;
  }

  static String greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

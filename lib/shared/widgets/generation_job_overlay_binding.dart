import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/generation_job_service.dart';

/// Overlay/strip visibility derived from [GenerationJobService] for a given
/// [GenerationJobKind] — the exact boolean shape duplicated across the quiz
/// and learning-path create screens.
class GenerationJobOverlayState {
  const GenerationJobOverlayState({
    required this.showOverlay,
    required this.showStrip,
  });

  final bool showOverlay;
  final bool showStrip;
}

GenerationJobOverlayState watchGenerationJobOverlay(
  WidgetRef ref,
  GenerationJobKind kind,
) {
  final job = ref.watch(generationJobServiceProvider);
  final generating = job.isRunning && job.kind == kind;
  return GenerationJobOverlayState(
    showOverlay: generating && job.uiAttached,
    showStrip: generating && !job.uiAttached,
  );
}

/// Auto-navigates to [GenerationJobService.successRoute] when a job of
/// [kind] finishes successfully while backgrounded (user tapped "Continue
/// in background" and the result arrived after they stopped watching).
///
/// Only fits screens that navigate to a route on success — daily content
/// generation refreshes in place instead, so it does not use this helper.
void listenGenerationJobBackgroundSuccess(
  WidgetRef ref,
  GenerationJobKind kind, {
  required void Function(String route) onSuccess,
}) {
  ref.listen<GenerationJobService>(generationJobServiceProvider, (prev, next) {
    if (prev?.isRunning == true &&
        !next.isRunning &&
        next.kind == kind &&
        !next.uiAttached &&
        !next.userCancelled &&
        next.successRoute != null) {
      onSuccess(next.successRoute!);
    }
  });
}

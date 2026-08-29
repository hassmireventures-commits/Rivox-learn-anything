import 'package:ai_quiz_app/core/services/ai_study_pulse_service.dart';
import 'package:ai_quiz_app/core/services/built_in_ai_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuiltInAiRouter output validation', () {
    test('detects instruction leak from Nemotron-style output', () {
      const leak =
          'We need to output JSON only, no markdown. Must be a single valid JSON object with key brief.';
      expect(BuiltInAiRouter.isReasoningOrInstructionLeak(leak), isTrue);
      expect(
        BuiltInAiRouter.isUnusableModelOutput(leak, expectJson: true),
        isTrue,
      );
    });

    test('accepts valid JSON brief', () {
      const json = '{"brief":"Keep practicing Azure pipelines today."}';
      expect(BuiltInAiRouter.isUnusableModelOutput(json, expectJson: true), isFalse);
    });
  });

  group('AiStudyPulseService brief extraction', () {
    test('rejects instruction leak as brief', () {
      const leak =
          'We need to output JSON only. Must not use em dashes or en dashes.';
      expect(AiStudyPulseService.isValidBrief(leak), isFalse);
    });

    test('extracts brief from JSON', () {
      const raw =
          '{"brief":"You are on track with Azure DevOps. Review pipelines today."}';
      expect(
        AiStudyPulseService.parseBrief(raw),
        'You are on track with Azure DevOps. Review pipelines today.',
      );
    });
  });
}

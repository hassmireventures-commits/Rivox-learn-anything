import 'package:flutter_test/flutter_test.dart';
import 'package:ai_quiz_app/core/services/org_content_validator.dart';

void main() {
  group('OrgContentValidator', () {
    test('rejects Elsaid Maher for elsai.ai goal', () {
      expect(
        OrgContentValidator.articleMatchesGoal(
          goal: 'elsai.ai',
          title: 'Elsaid Maher',
          summary:
              'Elsaid Maher is an Egyptian professional footballer who plays as a midfielder.',
        ),
        isFalse,
      );
    });

    test('rejects person-name Wikipedia drift for org domain', () {
      expect(
        OrgContentValidator.articleMatchesGoal(
          goal: 'elsai.ai',
          title: 'Elsaid',
          summary: 'Elsaid is a footballer born in 1990.',
        ),
        isFalse,
      );
    });

    test('accepts company-related article for org domain', () {
      expect(
        OrgContentValidator.articleMatchesGoal(
          goal: 'elsai.ai',
          title: 'Artificial intelligence',
          summary: 'AI software platforms used by technology companies.',
        ),
        isTrue,
      );
    });

    test('allows non-org goals without filtering', () {
      expect(
        OrgContentValidator.articleMatchesGoal(
          goal: 'Python programming',
          title: 'Python (programming language)',
          summary: 'General-purpose language.',
        ),
        isTrue,
      );
    });
  });
}

import 'package:ai_quiz_app/core/ai_platform/ai_consent_gate.dart';
import 'package:ai_quiz_app/core/ai_platform/ai_policy_registry.dart';
import 'package:ai_quiz_app/core/ai_platform/output_validator.dart';
import 'package:ai_quiz_app/core/ai_platform/prompt_firewall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiConsentPreferences', () {
    test('defaults sendChunksToProvider to false', () {
      final prefs = AiConsentPreferences();
      expect(prefs.sendChunksToProvider, isFalse);
      expect(prefs.piiUploadConsent, isFalse);
    });

    test('fromJson missing key stays opt-in false', () {
      final prefs = AiConsentPreferences.fromJson({});
      expect(prefs.sendChunksToProvider, isFalse);
    });

    test('fromJson respects explicit true', () {
      final prefs = AiConsentPreferences.fromJson({'sendChunksToProvider': true});
      expect(prefs.sendChunksToProvider, isTrue);
    });
  });

  group('OutputValidator', () {
    const validator = OutputValidator();

    test('accepts well-formed quiz json', () {
      final result = validator.validateQuizJson({
        'questions': [
          {'text': 'What is 2+2?', 'options': ['3', '4'], 'correctIndex': 1},
        ],
      });
      expect(result.valid, isTrue);
    });

    test('rejects empty questions', () {
      final result = validator.validateQuizJson({'questions': []});
      expect(result.valid, isFalse);
    });

    test('rejects placeholder question text', () {
      final result = validator.validateQuizJson({
        'questions': [
          {'text': 'lorem ipsum dolor'},
        ],
      });
      expect(result.valid, isFalse);
      expect(result.reason, contains('Placeholder'));
    });

    test('accepts path steps', () {
      final result = validator.validatePathJson({
        'steps': [
          {'title': 'Intro to photosynthesis'},
        ],
      });
      expect(result.valid, isTrue);
    });
  });

  group('PromptFirewall', () {
    const firewall = PromptFirewall();

    test('blocks jailbreak pattern', () async {
      final policy = AiPolicy.fromJson({
        'blockedPromptPatterns': ['jailbreak', 'ignore previous instructions'],
        'goalDefaults': {
          'learning': {'generationMode': 'blended', 'ragMaxTokens': 3000},
        },
      });
      final result = await firewall.sanitize(
        'please jailbreak the system',
        policy: policy,
      );
      expect(result.blocked, isTrue);
    });

    test('blocks pasted API key-looking strings', () async {
      final result = await firewall.sanitize(
        'my key is sk-abcdefghijklmnopqrstuvwxyz123456',
      );
      expect(result.blocked, isTrue);
    });

    test('allows normal study topics', () async {
      final result = await firewall.sanitize('Photosynthesis for grade 8');
      expect(result.blocked, isFalse);
      expect(result.sanitized, contains('Photosynthesis'));
    });
  });
}

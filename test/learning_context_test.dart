import 'package:ai_quiz_app/core/personalization/learning_domain.dart';
import 'package:ai_quiz_app/core/services/learning_context.dart';
import 'package:ai_quiz_app/core/services/open_knowledge/open_knowledge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearningContext.compose (goal + path + module before generating)', () {
    test('reported bug: "Advanced English" module in an IELTS path is anchored', () {
      final ctx = LearningContext.compose(
        topic: 'Advanced English',
        goal: 'IELTS',
        pathTitle: 'Path: IELTS Band 8 Preparation',
        isModule: true,
      );
      expect(ctx.generationTopic, 'Advanced English (IELTS)');
      expect(ctx.isAnchored, isTrue);
      expect(ctx.promptBlock, contains('Learner goal: IELTS'));
      expect(ctx.promptBlock, contains('Learning path: IELTS Band 8 Preparation'));
      expect(ctx.promptBlock, contains('vehicle'));
    });

    test('a module that already names its goal is left alone', () {
      final ctx = LearningContext.compose(topic: 'IELTS Reading', goal: 'IELTS', isModule: true);
      expect(ctx.generationTopic, 'IELTS Reading');
      expect(ctx.isAnchored, isFalse);
    });

    test('falls back to the path focus when there is no goal', () {
      final ctx = LearningContext.compose(
        topic: 'Collisions',
        pathTitle: 'Path: Godot game development',
        isModule: true,
      );
      expect(ctx.generationTopic, 'Collisions (Godot game development)');
    });

    test('a quick quiz keeps the learner\'s exact wording, goal only as a hint', () {
      final ctx = LearningContext.compose(topic: 'Photosynthesis', goal: 'NEET');
      expect(ctx.generationTopic, 'Photosynthesis');
      expect(ctx.promptBlock, contains('NEET'));
    });

    test('no goal and no path means no extra prompt', () {
      final ctx = LearningContext.compose(topic: 'Rust ownership');
      expect(ctx.promptBlock, isEmpty);
    });
  });

  group('OpenKnowledgeService.articleFitsTopic (wrong-sense Wikipedia hits)', () {
    test('rejects the article that caused the automobile quiz', () {
      expect(
        OpenKnowledgeService.articleFitsTopic('Advanced English', 'Advance (English automobile)'),
        isFalse,
      );
    });

    test('keeps articles that are about the topic\'s own words', () {
      expect(OpenKnowledgeService.articleFitsTopic('Python basics', 'Python (programming language)'),
          isTrue);
      expect(OpenKnowledgeService.articleFitsTopic('Photosynthesis', 'Photosynthesis'), isTrue);
      expect(OpenKnowledgeService.articleFitsTopic('Advanced English', 'English language'), isTrue);
      expect(OpenKnowledgeService.articleFitsTopic('neural networks', 'Neural network'), isTrue);
    });

    test('rejects unrelated titles', () {
      expect(OpenKnowledgeService.articleFitsTopic('Squat form', 'Squatting (housing)'), isFalse,
          reason: 'fitness squat vs occupying a building: different word, different sense');
      expect(OpenKnowledgeService.articleFitsTopic('Watercolor painting', 'Water'), isFalse);
    });
  });

  group('LearningDomains.classify (adapt to any field)', () {
    test('maps goals to domains, most specific first', () {
      expect(LearningDomains.classify('IELTS'), LearningDomain.language);
      expect(LearningDomains.classify('Game development in Unity'), LearningDomain.gameDev);
      expect(LearningDomains.classify('Python programming language'), LearningDomain.coding);
      expect(LearningDomains.classify('Watercolor painting'), LearningDomain.art);
      expect(LearningDomains.classify('Strength training at the gym'), LearningDomain.fitness);
      expect(LearningDomains.classify('Woodworking for beginners'), LearningDomain.diy);
      expect(LearningDomains.classify('NEET UG'), LearningDomain.exam);
      expect(LearningDomains.classify('Sourdough baking'), LearningDomain.cooking);
      expect(LearningDomains.classify('Something unusual'), LearningDomain.general);
    });

    test('whole words only: "smart" is not art, "javascript" is not java-only', () {
      expect(LearningDomains.classify('smart goals'), isNot(LearningDomain.art));
      expect(LearningDomains.classify('javascript'), LearningDomain.coding);
    });

    test('every domain has a profile with guidance and starters', () {
      for (final d in LearningDomain.values) {
        final p = LearningDomains.profileFor(d);
        expect(p.promptGuidance, isNotEmpty);
        expect(p.chatStarters, hasLength(4));
      }
    });
  });
}

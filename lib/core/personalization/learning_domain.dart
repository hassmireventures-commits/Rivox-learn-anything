import 'package:flutter/material.dart';

/// What kind of thing the learner is learning. Drives how generation
/// practices it (prompt guidance), the words the UI uses, and a few small
/// visual cues, so the same app feels right for IELTS, a deadlift, a
/// bookshelf, a watercolour, or a Godot game, without separate screens
/// ("less UI, more UX").
enum LearningDomain {
  language,
  exam,
  coding,
  gameDev,
  art,
  music,
  fitness,
  diy,
  cooking,
  business,
  science,
  general,
}

/// Per-domain behaviour. Everything here is additive guidance; nothing in a
/// profile changes data or removes a feature.
class LearningDomainProfile {
  const LearningDomainProfile({
    required this.domain,
    required this.label,
    required this.icon,
    required this.accent,
    required this.practiceNoun,
    required this.promptGuidance,
    required this.chatStarters,
  });

  final LearningDomain domain;
  final String label;
  final IconData icon;
  final Color accent;

  /// What a practice set is called here ("quiz", "workout check", ...).
  final String practiceNoun;

  /// Added to quiz and path prompts: how to make practice useful for this
  /// kind of skill (scenario, form cue, code reading, critique, ...).
  final String promptGuidance;

  /// Empty-chat starter prompts, in the learner's voice.
  final List<String> chatStarters;
}

class LearningDomains {
  LearningDomains._();

  /// Ordered most specific first: "game development in C#" must land on
  /// gameDev, not coding; "IELTS" on language, not exam.
  static const List<(LearningDomain, List<String>)> _keywords = [
    (LearningDomain.language, [
      'ielts', 'toefl', 'toeic', 'pte', 'duolingo english', 'cambridge english', 'delf', 'dele',
      'jlpt', 'hsk', 'topik', 'goethe', 'spoken english', 'english grammar', 'vocabulary',
      'learn spanish', 'learn french', 'learn german', 'learn japanese', 'learn korean',
      'learn arabic', 'learn hindi', 'learn english', 'english', 'foreign language',
      'second language', 'language learning', 'pronunciation', 'fluency',
    ]),
    (LearningDomain.gameDev, [
      'game dev', 'game development', 'gamedev', 'unity', 'unreal', 'godot', 'game design',
      'level design', 'game engine', 'pygame', 'roblox', 'shader',
    ]),
    (LearningDomain.coding, [
      'python', 'javascript', 'typescript', 'java', 'kotlin', 'swift', 'flutter', 'dart',
      'react', 'node', 'c++', 'c#', 'golang', 'rust', 'sql', 'coding', 'programming',
      'software', 'developer', 'web development', 'frontend', 'backend', 'devops', 'aws',
      'azure', 'docker', 'kubernetes', 'data structures', 'algorithms', 'leetcode',
      'machine learning', 'data science',
    ]),
    (LearningDomain.art, [
      'drawing', 'painting', 'sketch', 'watercolor', 'watercolour', 'illustration',
      'digital art', 'procreate', 'calligraphy', 'photography', 'graphic design', 'art',
      'animation', 'figma', 'ui design', 'pottery', 'sculpt',
    ]),
    (LearningDomain.music, [
      'guitar', 'piano', 'violin', 'drums', 'singing', 'vocals', 'music theory', 'ukulele',
      'music production', 'ableton', 'chords',
    ]),
    (LearningDomain.fitness, [
      'fitness', 'workout', 'gym', 'strength', 'weight loss', 'bodybuilding', 'yoga',
      'pilates', 'running', 'marathon', 'calisthenics', 'nutrition', 'personal trainer',
      'mobility', 'cardio', 'powerlifting', 'swimming',
    ]),
    (LearningDomain.cooking, [
      'cooking', 'baking', 'recipe', 'chef', 'cuisine', 'pastry', 'barista', 'culinary',
    ]),
    (LearningDomain.diy, [
      'diy', 'woodworking', 'carpentry', 'plumbing', 'electrical', 'electrician', 'welding',
      'home repair', 'furniture', 'gardening', 'sewing', 'knitting', 'crochet', 'car repair',
      'mechanic', 'handyman', '3d printing', 'electronics', 'arduino', 'soldering',
    ]),
    (LearningDomain.exam, [
      'neet', 'jee', 'upsc', 'gate', 'cat', 'gmat', 'gre', 'sat', 'act', 'mcat', 'lsat',
      'ssc', 'bank po', 'clat', 'cfa', 'cpa', 'acca', 'pmp', 'certification', 'exam',
      'board exam', 'nclex', 'usmle',
    ]),
    (LearningDomain.business, [
      'marketing', 'sales', 'product manager', 'product management', 'finance', 'accounting',
      'investing', 'trading', 'startup', 'entrepreneur', 'leadership', 'management', 'mba',
      'interview', 'career', 'excel', 'business',
    ]),
    (LearningDomain.science, [
      'physics', 'chemistry', 'biology', 'math', 'calculus', 'statistics', 'astronomy',
      'medicine', 'anatomy', 'history', 'geography', 'economics', 'psychology', 'philosophy',
    ]),
  ];

  /// Classifies [text] (goal, goal context, path focus...). Whole-word,
  /// case-insensitive; returns [LearningDomain.general] when nothing fits.
  static LearningDomain classify(String text) {
    final lower = ' ${text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9+#]+'), ' ')} ';
    for (final (domain, words) in _keywords) {
      for (final w in words) {
        final needle = ' ${w.replaceAll(RegExp(r'[^a-z0-9+#]+'), ' ').trim()} ';
        if (lower.contains(needle)) return domain;
      }
    }
    return LearningDomain.general;
  }

  /// Classifies from several sources; the first one that is not general wins.
  static LearningDomain classifyAll(Iterable<String> texts) {
    for (final t in texts) {
      final d = classify(t);
      if (d != LearningDomain.general) return d;
    }
    return LearningDomain.general;
  }

  static LearningDomainProfile profileFor(LearningDomain domain) => _profiles[domain]!;

  static LearningDomainProfile profileForGoal(Iterable<String> texts) =>
      profileFor(classifyAll(texts));

  static const Map<LearningDomain, LearningDomainProfile> _profiles = {
    LearningDomain.language: LearningDomainProfile(
      domain: LearningDomain.language,
      label: 'Language',
      icon: Icons.translate_rounded,
      accent: Color(0xFF00B4D8),
      practiceNoun: 'practice set',
      promptGuidance:
          'This is a language skill. Practise it in use: short passages, dialogue '
          'lines, gap-fills in real sentences, word choice in context, error spotting, '
          'and paraphrase. Never ask trivia about the language or the exam itself.',
      chatStarters: [
        'Quiz me on vocabulary I keep missing',
        'Correct this sentence for me',
        'Give me a speaking prompt to practise',
        'Explain a grammar rule simply',
      ],
    ),
    LearningDomain.exam: LearningDomainProfile(
      domain: LearningDomain.exam,
      label: 'Exam prep',
      icon: Icons.fact_check_rounded,
      accent: Color(0xFF6B5BFF),
      practiceNoun: 'practice paper',
      promptGuidance:
          'This is exam preparation. Match the real paper: its question styles, its '
          'syllabus wording, and its difficulty. Prefer application and calculation '
          'items over definitions. Never ask about the exam\'s fees, dates, or rules.',
      chatStarters: [
        'Quiz me on my weakest topic',
        'What should I revise today?',
        'Explain a tricky concept simply',
        'How am I doing this week?',
      ],
    ),
    LearningDomain.coding: LearningDomainProfile(
      domain: LearningDomain.coding,
      label: 'Coding',
      icon: Icons.code_rounded,
      accent: Color(0xFF00B894),
      practiceNoun: 'coding check',
      promptGuidance:
          'This is a programming skill. Use short code snippets: predict the output, '
          'find the bug, pick the right fix, choose the correct API or complexity. '
          'Keep code under 10 lines and syntactically valid. Prefer doing over naming.',
      chatStarters: [
        'Give me a bug to find',
        'Quiz me on what this code prints',
        'Explain this concept with a tiny example',
        'What should I build next to practise?',
      ],
    ),
    LearningDomain.gameDev: LearningDomainProfile(
      domain: LearningDomain.gameDev,
      label: 'Game development',
      icon: Icons.sports_esports_rounded,
      accent: Color(0xFF9D4EDD),
      practiceNoun: 'build check',
      promptGuidance:
          'This is game development. Ask about building real game features: the game '
          'loop, input, physics and collisions, scenes and nodes or game objects, '
          'animation states, and engine-specific APIs for the engine named. Use '
          'small scenarios ("the player falls through the floor; which fix?").',
      chatStarters: [
        'Quiz me on game loop basics',
        'Help me plan a tiny first game',
        'Why does my player fall through the floor?',
        'Explain collisions simply',
      ],
    ),
    LearningDomain.art: LearningDomainProfile(
      domain: LearningDomain.art,
      label: 'Art',
      icon: Icons.palette_rounded,
      accent: Color(0xFFFF6B9D),
      practiceNoun: 'technique check',
      promptGuidance:
          'This is a visual art skill. Practise technique and seeing: values, colour '
          'mixing, composition, perspective, materials and tools, and what to change '
          'in a described piece. Describe the scenario in words; do not rely on images.',
      chatStarters: [
        'Give me a 15-minute drawing exercise',
        'Quiz me on colour theory',
        'How do I fix a muddy painting?',
        'Explain perspective simply',
      ],
    ),
    LearningDomain.music: LearningDomainProfile(
      domain: LearningDomain.music,
      label: 'Music',
      icon: Icons.music_note_rounded,
      accent: Color(0xFFFDCB6E),
      practiceNoun: 'ear and theory check',
      promptGuidance:
          'This is a music skill. Practise theory in use: chords in a key, intervals, '
          'rhythm counting, technique fixes, and practice routines. Name notes and '
          'chords in text.',
      chatStarters: [
        'Quiz me on chords in a key',
        'Give me a 10-minute practice routine',
        'Explain rhythm counting simply',
        'How do I stop rushing the beat?',
      ],
    ),
    LearningDomain.fitness: LearningDomainProfile(
      domain: LearningDomain.fitness,
      label: 'Fitness',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFFF7675),
      practiceNoun: 'workout check',
      promptGuidance:
          'This is a fitness skill. Practise form cues, safe progression, sets and '
          'reps, recovery, warm-ups, and common mistakes, as scenarios ("your knees '
          'cave in on the squat; which cue?"). Stay general and safety-first; never '
          'give medical, injury-treatment, or diet-prescription advice.',
      chatStarters: [
        'Quiz me on squat form cues',
        'Plan a 20-minute beginner workout',
        'How do I progress safely?',
        'What should I eat around training?',
      ],
    ),
    LearningDomain.cooking: LearningDomainProfile(
      domain: LearningDomain.cooking,
      label: 'Cooking',
      icon: Icons.restaurant_rounded,
      accent: Color(0xFFFDCB6E),
      practiceNoun: 'kitchen check',
      promptGuidance:
          'This is a cooking skill. Practise technique, ratios, timing, temperatures, '
          'substitutions, and food safety, as kitchen scenarios ("the sauce split; '
          'what now?").',
      chatStarters: [
        'Quiz me on knife and heat basics',
        'What can I cook with what I have?',
        'Why did my bread not rise?',
        'Explain a technique step by step',
      ],
    ),
    LearningDomain.diy: LearningDomainProfile(
      domain: LearningDomain.diy,
      label: 'DIY and making',
      icon: Icons.handyman_rounded,
      accent: Color(0xFFC9A962),
      practiceNoun: 'build check',
      promptGuidance:
          'This is a hands-on making skill. Practise the right tool, material, step '
          'order, measurement, and safety for real jobs, as scenarios ("the screw '
          'keeps spinning; what next?"). Always include the safety step where one '
          'applies; for mains electrics or gas, say to use a licensed professional.',
      chatStarters: [
        'Quiz me on which tool to use',
        'Walk me through a first project',
        'What safety gear do I need?',
        'Why does my joint keep splitting?',
      ],
    ),
    LearningDomain.business: LearningDomainProfile(
      domain: LearningDomain.business,
      label: 'Career and business',
      icon: Icons.work_rounded,
      accent: Color(0xFF74B9FF),
      practiceNoun: 'case check',
      promptGuidance:
          'This is a professional skill. Practise judgement on short workplace cases: '
          'what to do next, which metric matters, how to phrase it. Prefer realistic '
          'decisions over definitions.',
      chatStarters: [
        'Give me a quick case to solve',
        'Quiz me for my next interview',
        'Explain a metric simply',
        'What should I learn next for my role?',
      ],
    ),
    LearningDomain.science: LearningDomainProfile(
      domain: LearningDomain.science,
      label: 'Academic',
      icon: Icons.science_rounded,
      accent: Color(0xFF6B5BFF),
      practiceNoun: 'quiz',
      promptGuidance:
          'This is an academic subject. Mix recall with application: worked problems, '
          'cause and effect, and "which explains this observation".',
      chatStarters: [
        'Quiz me on my weakest topic',
        'Explain a tricky concept simply',
        'Give me a worked example',
        'How am I doing this week?',
      ],
    ),
    LearningDomain.general: LearningDomainProfile(
      domain: LearningDomain.general,
      label: 'Learning',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFF6B5BFF),
      practiceNoun: 'quiz',
      promptGuidance:
          'Practise the skill as it is used: prefer scenarios and application over '
          'definitions.',
      chatStarters: [
        'Quiz me on my weakest topic',
        'What should I study next?',
        'Explain a tricky concept simply',
        'How am I doing this week?',
      ],
    ),
  };
}

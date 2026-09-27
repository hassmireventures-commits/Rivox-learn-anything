/// Entrance exams and professional certifications, plus basics-first lessons.
/// Not Wikipedia, and not a product name that merely contains "Azure".
class ExamCertResources {
  ExamCertResources._();

  static final _cloud = RegExp(
    r'\b(aws|azure|gcp|google cloud|kubernetes|k8s|docker|terraform|cka|ckad|az-900|saa-c0\d)\b',
    caseSensitive: false,
  );
  static final _aptitude = RegExp(
    r'\b(upsc|ssc|ibps|rrb|sbi|nda|clat|cuet|bank(?:ing)?\s+po)\b',
    caseSensitive: false,
  );
  static final _network = RegExp(
    r'\b(comptia|ccna|ccnp|cissp|security\s*\+)\b',
    caseSensitive: false,
  );
  static final _stem = RegExp(
    r'\b(jee|neet|gmat|gre|usmle|plab|nclex)\b',
    caseSensitive: false,
  );
  static final _professional = RegExp(
    r'\b(pmp|capm|cfa|cpa)\b',
    caseSensitive: false,
  );

  static bool matches(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return false;
    // Azure DevOps is a product, not the Azure certification.
    final t = raw.replaceAll(
      RegExp(r'\bazure\s+devops\b', caseSensitive: false),
      ' ',
    );
    if (_namedPaper(t)) return true;
    return _cloud.hasMatch(t) ||
        _aptitude.hasMatch(t) ||
        _network.hasMatch(t) ||
        _stem.hasMatch(t) ||
        _professional.hasMatch(t);
  }

  /// SAT / ACT / CAT / GATE only when the text is the exam, not "logic gate" or "sat" as a verb.
  static bool _namedPaper(String t) {
    if (RegExp(r'\b(SAT|ACT|CAT)\b').hasMatch(t)) return true;
    if (RegExp(
      r'\b(sat|act|cat)\s+(exam|prep|preparation|test|dilr)\b',
      caseSensitive: false,
    ).hasMatch(t)) {
      return true;
    }
    if (RegExp(r'\blogic\s+gates?\b', caseSensitive: false).hasMatch(t)) {
      return false;
    }
    if (RegExp(r'\bgateway\b', caseSensitive: false).hasMatch(t)) return false;
    return RegExp(r'^gate(?:\b|[\s-].*)', caseSensitive: false).hasMatch(t) ||
        RegExp(r'\bgate\s+(cse|ece|ee|me|pyq|exam|prep)', caseSensitive: false)
            .hasMatch(t);
  }

  static List<({String url, String title, String summary})> articlesFor(
    String topic,
  ) {
    if (!matches(topic)) return const [];
    final t = topic.toLowerCase();
    if (_cloud.hasMatch(t)) return _cloudArticles;
    if (_network.hasMatch(t)) return _networkArticles;
    if (_professional.hasMatch(t)) return _professionalArticles;
    if (_aptitude.hasMatch(t) || RegExp(r'\b(CAT|cat\s+)').hasMatch(topic)) {
      return _aptitudeArticles;
    }
    return _stemArticles;
  }

  static ({String url, String title, String summary})? nextArticle(
    String topic, {
    Set<String> excludeUrls = const {},
  }) {
    final all = articlesFor(topic);
    if (all.isEmpty) return null;
    for (final article in all) {
      if (!excludeUrls.contains(article.url)) return article;
    }
    return all.first;
  }

  static const _stemArticles = <({String url, String title, String summary})>[
    (
      url: 'https://www.khanacademy.org/math/algebra',
      title: 'Algebra basics',
      summary:
          'Start here: equations, functions, and the algebra entrance papers actually test.',
    ),
    (
      url: 'https://www.khanacademy.org/science/physics',
      title: 'Physics basics',
      summary:
          'Motion, forces, and energy, practiced as problems rather than definitions.',
    ),
    (
      url: 'https://www.khanacademy.org/science/chemistry',
      title: 'Chemistry basics',
      summary:
          'Atoms, reactions, and stoichiometry from the first topics on a science paper.',
    ),
    (
      url: 'https://www.khanacademy.org/science/biology',
      title: 'Biology basics',
      summary:
          'Cells, genetics, and physiology in the order a first-year course uses.',
    ),
  ];

  static const _aptitudeArticles = <({String url, String title, String summary})>[
    (
      url: 'https://www.geeksforgeeks.org/quantitative-aptitude/',
      title: 'Quantitative aptitude from the basics',
      summary:
          'Number systems, percentages, and the other topics SSC and bank papers start with.',
    ),
    (
      url: 'https://www.khanacademy.org/math/algebra',
      title: 'Algebra for aptitude tests',
      summary: 'Equation practice that shows up in quant sections.',
    ),
  ];

  static const _cloudArticles = <({String url, String title, String summary})>[
    (
      url: 'https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html',
      title: 'AWS overview: core services',
      summary:
          'What the main AWS services are for, as a starting point for the associate exams.',
    ),
    (
      url: 'https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/',
      title: 'Azure fundamentals: cloud concepts',
      summary: 'The first official module for AZ-900 style cloud basics.',
    ),
    (
      url: 'https://cloud.google.com/docs/overview',
      title: 'Google Cloud overview',
      summary: 'How Google Cloud products fit together, from the official docs.',
    ),
    (
      url: 'https://kubernetes.io/docs/tutorials/kubernetes-basics/',
      title: 'Kubernetes basics',
      summary: 'Official interactive tutorial: pods, deployments, and services.',
    ),
    (
      url: 'https://docs.docker.com/get-started/',
      title: 'Docker get started',
      summary: 'Images, containers, and the first workflow Docker exams assume.',
    ),
  ];

  static const _networkArticles = <({String url, String title, String summary})>[
    (
      url: 'https://www.geeksforgeeks.org/computer-network-tutorials/',
      title: 'Computer networks from the basics',
      summary:
          'OSI, TCP/IP, and the topics CompTIA, CCNA, and security certs start with.',
    ),
  ];

  static const _professionalArticles = <({String url, String title, String summary})>[
    (
      url: 'https://www.khanacademy.org/economics-finance-domain/core-finance',
      title: 'Finance basics',
      summary:
          'Interest, risk, and statements, the ground layer under CFA and CPA study.',
    ),
    (
      url: 'https://www.geeksforgeeks.org/software-engineering-software-project-management-spm/',
      title: 'Software project management basics',
      summary:
          'Scope, schedule, and planning ideas that PMP-style questions are built on.',
    ),
  ];
}

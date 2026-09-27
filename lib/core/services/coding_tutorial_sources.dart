/// Curated allowlisted tutorial URLs for computer science and coding topics.
class CodingTutorialSources {
  CodingTutorialSources._();

  static bool isCodingTopic(String topic) {
    final lower = topic.trim().toLowerCase();
    if (lower.isEmpty) return false;
    const keys = [
      'python', 'javascript', 'typescript', 'java', 'c++', 'c#', 'csharp',
      'program', 'coding', 'computer science',
      'computerscience', ' cs ', 'algorithm', 'data structure', 'web dev',
      'frontend', 'backend', 'full stack', 'fullstack', 'html', 'css',
      'react', 'node', 'nodejs', 'sql', 'database', 'flutter', 'dart',
      'kotlin', 'swift', 'golang', ' go ', 'rust', 'php', 'ruby',
      'machine learning', 'deep learning', 'git',
      'object oriented', 'oop', 'compiler', 'operating system',
    ];
    if (keys.any((k) => lower.contains(k.trim()))) return true;
    if (RegExp(r'\bcs\b').hasMatch(lower)) return true;
    return false;
  }

  /// Known-good article URLs on GeeksforGeeks, W3Schools, MDN, etc. (not homepages).
  static List<({String url, String title, String summary})> articleCandidates(
    String topic,
  ) {
    final lower = topic.trim().toLowerCase();
    final out = <({String url, String title, String summary})>[];

    void add(String url, String title, String summary) {
      out.add((url: url, title: title, summary: summary));
    }

    if (_matches(lower, ['python'])) {
      add(
        'https://www.w3schools.com/python/default.asp',
        'Python Tutorial — W3Schools',
        'Hands-on Python basics and syntax.',
      );
      add(
        'https://www.geeksforgeeks.org/python-programming-language/',
        'Python — GeeksforGeeks',
        'Python fundamentals, data types, and practice problems.',
      );
      add(
        'https://docs.python.org/3/tutorial/index.html',
        'Python official tutorial',
        'The official Python language tutorial.',
      );
      add(
        'https://realpython.com/python-basics/',
        'Python basics — Real Python',
        'Practical introduction to Python programming.',
      );
    }
    if (_matches(lower, ['javascript', 'js', 'typescript', 'ts'])) {
      add(
        'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
        'JavaScript Guide — MDN',
        'Structured guide to JavaScript for web development.',
      );
      add(
        'https://www.w3schools.com/js/default.asp',
        'JavaScript Tutorial — W3Schools',
        'Interactive JavaScript lessons and examples.',
      );
      add(
        'https://javascript.info/',
        'Modern JavaScript Tutorial',
        'In-depth modern JS from basics to advanced topics.',
      );
      add(
        'https://www.geeksforgeeks.org/javascript/',
        'JavaScript — GeeksforGeeks',
        'JS concepts, DOM, and interview-oriented notes.',
      );
    }
    if (_matches(lower, ['java']) && !lower.contains('javascript')) {
      add(
        'https://www.w3schools.com/java/default.asp',
        'Java Tutorial — W3Schools',
        'Java syntax, OOP, and core APIs.',
      );
      add(
        'https://www.geeksforgeeks.org/java/',
        'Java — GeeksforGeeks',
        'Java programming tutorials and examples.',
      );
    }
    if (_matches(lower, ['html', 'css', 'web dev', 'frontend', 'web'])) {
      add(
        'https://www.w3schools.com/html/default.asp',
        'HTML Tutorial — W3Schools',
        'Build web pages with HTML elements and structure.',
      );
      add(
        'https://www.w3schools.com/css/default.asp',
        'CSS Tutorial — W3Schools',
        'Style and layout for web pages.',
      );
      add(
        'https://developer.mozilla.org/en-US/docs/Learn',
        'Web development — MDN Learn',
        'Structured front-end learning paths.',
      );
    }
    if (_matches(lower, ['sql', 'database'])) {
      add(
        'https://www.w3schools.com/sql/default.asp',
        'SQL Tutorial — W3Schools',
        'Query relational databases with SQL.',
      );
      add(
        'https://www.geeksforgeeks.org/sql/',
        'SQL — GeeksforGeeks',
        'SQL commands, joins, and practice queries.',
      );
    }
    if (_matches(lower, ['react'])) {
      add(
        'https://react.dev/learn',
        'React — official docs',
        'Learn React step by step from the React team.',
      );
      add(
        'https://www.geeksforgeeks.org/reactjs/',
        'ReactJS — GeeksforGeeks',
        'Components, hooks, and React patterns.',
      );
    }
    if (_matches(lower, ['flutter', 'dart'])) {
      add(
        'https://docs.flutter.dev/get-started/install',
        'Get started with Flutter',
        'Official Flutter setup and first app guide.',
      );
      add(
        'https://dart.dev/overview',
        'Dart language overview',
        'Official Dart language introduction.',
      );
    }
    if (_matches(lower, [
      'algorithm',
      'data structure',
      'computer science',
      'competitive programming',
    ])) {
      add(
        'https://www.geeksforgeeks.org/data-structures/',
        'Data Structures — GeeksforGeeks',
        'Arrays, trees, graphs, and core DS topics.',
      );
      add(
        'https://www.geeksforgeeks.org/fundamentals-of-algorithms/',
        'Algorithms — GeeksforGeeks',
        'Sorting, searching, DP, and algorithm patterns.',
      );
      add(
        'https://www.geeksforgeeks.org/learn-data-structures-and-algorithms-dsa-tutorial/',
        'DSA tutorial — GeeksforGeeks',
        'Structured DSA learning path for CS students.',
      );
    }
    if (_matches(lower, ['machine learning', 'deep learning', 'data science'])) {
      add(
        'https://www.geeksforgeeks.org/machine-learning/',
        'Machine Learning — GeeksforGeeks',
        'ML concepts, models, and interview prep.',
      );
      add(
        'https://www.w3schools.com/ai/default.asp',
        'AI Tutorial — W3Schools',
        'Intro to artificial intelligence concepts.',
      );
    }
    if (_matches(lower, ['c++', 'cpp'])) {
      add(
        'https://www.geeksforgeeks.org/c-plus-plus/',
        'C++ — GeeksforGeeks',
        'C++ syntax, STL, and problem-solving.',
      );
      add(
        'https://www.w3schools.com/cpp/default.asp',
        'C++ Tutorial — W3Schools',
        'C++ basics and standard library intro.',
      );
    }
    if (_matches(lower, ['c#', 'csharp', '.net'])) {
      add(
        'https://www.w3schools.com/cs/index.php',
        'C# Tutorial — W3Schools',
        'C# language fundamentals and .NET basics.',
      );
      add(
        'https://www.geeksforgeeks.org/c-sharp/',
        'C# — GeeksforGeeks',
        'C# programming tutorials and examples.',
      );
    }
    if (_matches(lower, ['git'])) {
      add(
        'https://www.w3schools.com/git/default.asp',
        'Git Tutorial — W3Schools',
        'Commits, branches, and the first Git commands.',
      );
      add(
        'https://docs.github.com/en/get-started/using-git/about-git',
        'About Git — GitHub Docs',
        'What a repository, commit, and branch are, from the official docs.',
      );
    }
    if (_matches(lower, ['operating system', 'compiler'])) {
      add(
        'https://www.geeksforgeeks.org/operating-systems/',
        'Operating systems — GeeksforGeeks',
        'Processes, memory, and scheduling from the first OS topics.',
      );
    }
    if (_matches(lower, ['object oriented', 'oop'])) {
      add(
        'https://www.geeksforgeeks.org/introduction-of-object-oriented-programming/',
        'Object-oriented programming — GeeksforGeeks',
        'Classes, objects, and the four OOP ideas with examples.',
      );
    }
    if (_matches(lower, ['golang', ' go '])) {
      add(
        'https://go.dev/tour/welcome/1',
        'A Tour of Go',
        'Official Go tutorial, starting from the first program.',
      );
    }
    if (_matches(lower, ['rust'])) {
      add(
        'https://doc.rust-lang.org/book/ch01-00-getting-started.html',
        'The Rust book: getting started',
        'Install Rust and write the first program.',
      );
    }
    if (_matches(lower, ['kotlin'])) {
      add(
        'https://kotlinlang.org/docs/getting-started.html',
        'Get started with Kotlin',
        'Official Kotlin basics and the first program.',
      );
    }
    if (_matches(lower, ['php'])) {
      add(
        'https://www.php.net/manual/en/introduction.php',
        'PHP introduction',
        'What a PHP page looks like, from the official manual.',
      );
    }
    if (_matches(lower, ['ruby'])) {
      add(
        'https://www.ruby-lang.org/en/documentation/quickstart/',
        'Ruby in twenty minutes',
        'Official Ruby quickstart, from the first program.',
      );
    }
    if (_matches(lower, ['node', 'nodejs'])) {
      add(
        'https://www.w3schools.com/nodejs/default.asp',
        'Node.js Tutorial — W3Schools',
        'Run JavaScript on the server, starting from the first script.',
      );
    }

    // Language-specific coding fallbacks only — never generic DSA for unrelated goals.
    if (out.isEmpty && isCodingTopic(topic)) {
      if (_matches(lower, ['python'])) {
        add(
          'https://www.w3schools.com/python/default.asp',
          'Python Tutorial — W3Schools',
          'Popular entry point for learning to code.',
        );
      } else if (_matches(lower, ['javascript', 'js', 'typescript'])) {
        add(
          'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
          'JavaScript Guide — MDN',
          'Structured guide to JavaScript for web development.',
        );
      } else if (_matches(lower, [
        'algorithm',
        'data structure',
        'computer science',
        'competitive programming',
      ])) {
        add(
          'https://www.geeksforgeeks.org/learn-data-structures-and-algorithms-dsa-tutorial/',
          'DSA tutorial — GeeksforGeeks',
          'Core computer science: data structures and algorithms.',
        );
      }
    }

    return out;
  }

  /// Next unseen tutorial. Null when this coding topic has no curated page.
  static ({String url, String title, String summary})? nextArticle(
    String topic, {
    Set<String> excludeUrls = const {},
  }) {
    final all = articleCandidates(topic);
    if (all.isEmpty) return null;
    for (final article in all) {
      if (!excludeUrls.contains(article.url)) return article;
    }
    return all.first;
  }

  static bool _matches(String lower, List<String> keys) {
    for (final k in keys) {
      final key = k.trim();
      if (key.length <= 3) {
        if (RegExp('\\b${RegExp.escape(key)}\\b').hasMatch(lower)) return true;
      } else if (lower.contains(key)) {
        return true;
      }
    }
    return false;
  }
}

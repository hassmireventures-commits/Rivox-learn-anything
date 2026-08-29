class OfficialLearningDomains {
  /// Free / official article hosts for learning paths and daily study.
  static const docDomains = {
    'developer.android.com',
    'docs.flutter.dev',
    'developer.mozilla.org',
    'docs.python.org',
    'learn.microsoft.com',
    'kubernetes.io',
    'react.dev',
    'dart.dev',
    'docs.github.com',
    'www.w3schools.com',
    'w3schools.com',
    'developer.apple.com',
    'nodejs.org',
    'go.dev',
    'www.postgresql.org',
    'docs.aws.amazon.com',
    'cloud.google.com',
    'firebase.google.com',
    'docs.docker.com',
    'www.rust-lang.org',
    'kotlinlang.org',
    // Free tutorial sites (daily study + path resources)
    'www.geeksforgeeks.org',
    'geeksforgeeks.org',
    'www.freecodecamp.org',
    'freecodecamp.org',
    'www.tutorialspoint.com',
    'tutorialspoint.com',
    'www.javatpoint.com',
    'javatpoint.com',
    'www.programiz.com',
    'programiz.com',
    'css-tricks.com',
    'www.digitalocean.com',
    'digitalocean.com',
    'dev.to',
    'www.coursera.org',
    'javascript.info',
    'www.javascript.info',
    'realpython.com',
    'www.realpython.com',
    // Non-technical / general education
    'www.khanacademy.org',
    'khanacademy.org',
    'www.britannica.com',
    'britannica.com',
    'en.wikipedia.org',
    'wikipedia.org',
    'simple.wikipedia.org',
    'www.investopedia.com',
    'investopedia.com',
    'www.nationalgeographic.com',
    'nationalgeographic.com',
    'www.bbc.co.uk',
    'bbc.co.uk',
    'www.history.com',
    'history.com',
    'openstax.org',
    'www.openstax.org',
    'owl.purdue.edu',
    'www.merriam-webster.com',
    'merriam-webster.com',
    'www.ted.com',
    'ted.com',
    'plato.stanford.edu',
    'www.wikihow.com',
    'wikihow.com',
    'www.howtogeek.com',
    'howtogeek.com',
  };

  static const videoDomains = {
    'youtube.com',
    'youtu.be',
    'www.youtube.com',
    'm.youtube.com',
    'www.youtube-nocookie.com',
    'youtube-nocookie.com',
  };

  /// oEmbed author_name substrings for trusted solo / org YouTube channels.
  static const trustedYouTubeAuthors = {
    'freecodecamp',
    'free code camp',
    'traversy media',
    'programming with mosh',
    'the net ninja',
    'corey schafer',
    'academind',
    'fireship',
    'tech with tim',
    'web dev simplified',
    'kevin powell',
    'the coding train',
    'cs dojo',
    'harvard cs50',
    'mit opencourseware',
    'sentdex',
    'derek banas',
    'thenewboston',
    'programmingknowledge',
    'telusko',
    'code with harry',
    'apna college',
    'bro code',
    'coding with mosh',
    'product school',
    'google careers',
    'harvard business review',
    'mit sloan',
    'ted-ed',
    'ted ed',
  };

  static bool isAllowedDoc(String host) {
    final h = host.toLowerCase();
    if (docDomains.contains(h)) return true;
    final bare = h.startsWith('www.') ? h.substring(4) : h;
    if (docDomains.contains(bare) || docDomains.contains('www.$bare')) return true;
    for (final d in docDomains) {
      final apex = d.startsWith('www.') ? d.substring(4) : d;
      if (h == apex || h.endsWith('.$apex')) return true;
    }
    return h.endsWith('.gov') || h.endsWith('.edu');
  }

  static bool isAllowedVideo(String host) {
    return videoDomains.contains(host.toLowerCase());
  }

  static bool isTrustedYouTubeAuthor(String? authorName) {
    if (authorName == null || authorName.trim().isEmpty) return false;
    final a = authorName.toLowerCase().trim();
    return trustedYouTubeAuthors.any((t) => a.contains(t));
  }
}

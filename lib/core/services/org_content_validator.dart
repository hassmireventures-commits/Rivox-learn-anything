import 'goal_topic_resolver.dart';

/// Validates open-knowledge hits (Wikipedia, etc.) against org/domain goals so
/// near-miss pages (e.g. "Elsaid Maher" for elsai.ai) are rejected before display.
class OrgContentValidator {
  OrgContentValidator._();

  static bool articleMatchesGoal({
    required String goal,
    required String title,
    required String summary,
  }) {
    if (!GoalTopicResolver.needsResolution(goal)) return true;

    final brand = GoalTopicResolver.brandLabel(goal).toLowerCase();
    if (brand.length < 3) return true;

    final t = title.toLowerCase().trim();
    final s = summary.toLowerCase().trim();
    final hay = '$t $s';

    if (_isOffBrandPersonHit(brand: brand, title: title, summary: summary)) {
      return false;
    }

    final brandWord = RegExp(r'\b' + RegExp.escape(brand) + r'\b');
    if (brandWord.hasMatch(t) || brandWord.hasMatch(s)) return true;

    return _hasOrgSignals(t, s);
  }

  /// True when a Wikipedia hit is likely a person biography, not the org/product.
  static bool _isOffBrandPersonHit({
    required String brand,
    required String title,
    required String summary,
  }) {
    final t = title.toLowerCase().trim();
    final s = summary.toLowerCase().trim();
    final hay = '$t $s';
    final firstWord = t.split(RegExp(r'\s+')).firstWhere((w) => w.isNotEmpty, orElse: () => '');

    if (firstWord.isNotEmpty) {
      // elsaid / elsaid maher when brand is elsai
      if (firstWord != brand &&
          firstWord.startsWith(brand) &&
          firstWord.length <= brand.length + 4) {
        return true;
      }
      if (_isSimilarPrefixDrift(firstWord, brand)) return true;
    }

    const bioHints = [
      'born',
      'died',
      'footballer',
      'football player',
      'association football',
      'midfielder',
      'striker',
      'goalkeeper',
      'defender',
      'singer',
      'actor',
      'actress',
      'politician',
      'writer',
      'author',
      'nationality',
      'years old',
      'professional player',
      'egyptian',
      'is a former',
      'is an egyptian',
      'played for',
      'club career',
    ];
    if (bioHints.any(hay.contains) && !_hasOrgSignals(t, s)) return true;

    // "First Last" person-style title with no org/product signals.
    final words = t.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
    if (words.length >= 2 &&
        words.length <= 4 &&
        !_hasOrgSignals(t, s) &&
        !brandWordInText(brand, hay)) {
      if (words.first.startsWith(brand.substring(0, brand.length.clamp(1, 4))) ||
          _isSimilarPrefixDrift(words.first, brand)) {
        return true;
      }
    }

    return false;
  }

  static bool brandWordInText(String brand, String hay) =>
      RegExp(r'\b' + RegExp.escape(brand) + r'\b').hasMatch(hay);

  /// Catches elsaid vs elsai (one extra trailing letter on the brand token).
  static bool _isSimilarPrefixDrift(String token, String brand) {
    if (token == brand) return false;
    if (token.length < brand.length || token.length > brand.length + 3) {
      return false;
    }
    if (!token.startsWith(brand)) {
      // Allow one missing/extra char at end: elsai vs elsaid
      final shorter = token.length < brand.length ? token : brand;
      final longer = token.length >= brand.length ? token : brand;
      if (!longer.startsWith(shorter)) return false;
      return longer.length - shorter.length <= 2;
    }
    return token.length > brand.length;
  }

  static bool _hasOrgSignals(String title, String summary) {
    const orgSignals = [
      'company',
      'startup',
      'corporation',
      'inc.',
      ' ltd',
      'platform',
      'software',
      'product',
      'saas',
      'technology',
      'artificial intelligence',
      'machine learning',
      'founded',
      'headquarters',
      'enterprise',
      'organization',
      'organisation',
      'business',
      'services',
    ];
    final hay = '$title $summary';
    return orgSignals.any(hay.contains);
  }
}

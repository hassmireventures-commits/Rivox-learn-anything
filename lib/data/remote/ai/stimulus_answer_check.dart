import 'models/question_stimulus.dart';

/// Repairs a question whose marked answer does not follow from its chart,
/// table, passage, or transcript. Leaves ordinary questions unchanged.
class StimulusAlignment {
  const StimulusAlignment({
    required this.text,
    required this.correctIndex,
    required this.explanation,
    required this.changed,
    required this.drop,
  });

  final String text;
  final int correctIndex;
  final String? explanation;
  final bool changed;
  final bool drop;

  factory StimulusAlignment.keep({
    required String text,
    required int correctIndex,
    required String? explanation,
  }) {
    return StimulusAlignment(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
      changed: false,
      drop: false,
    );
  }
}

class StimulusAnswerCheck {
  StimulusAnswerCheck._();

  static const _stop = {
    'the', 'a', 'an', 'of', 'to', 'in', 'on', 'and', 'or', 'for', 'is', 'it',
    'was', 'were', 'they', 'have', 'has', 'about', 'there', 'this', 'that',
    'with', 'from', 'your', 'their', 'what', 'which', 'who', 'when', 'where',
    'how', 'does', 'did', 'main', 'topic', 'conversation', 'passage', 'graph',
    'chart', 'table', 'shows', 'show', 'average', 'over', 'past', 'week',
  };

  static const _high = {
    'highest', 'higher', 'warmest', 'warmer', 'hottest', 'hotter', 'greatest',
    'greater', 'most', 'maximum', 'largest', 'biggest', 'bigger',
  };

  static const _low = {
    'lowest', 'lower', 'coldest', 'colder', 'coolest', 'least', 'minimum',
    'smallest', 'fewer',
  };

  static StimulusAlignment align({
    required String text,
    required List<String> options,
    required int correctIndex,
    required String type,
    String? stimulusJson,
    String? explanation,
  }) {
    final keep = StimulusAlignment.keep(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
    );
    if (options.length < 2 || correctIndex < 0 || correctIndex >= options.length) {
      return keep;
    }
    if (type == 'short_answer' || type == 'behavioral' || type == 'open') {
      return keep;
    }
    final stimulus = QuestionStimulus.tryParse(stimulusJson);
    if (stimulus == null) return keep;
    if (stimulus.isChart) {
      return _figure(
        text: text,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        type: type,
        points: stimulus.points,
        title: stimulus.title,
      );
    }
    if (stimulus.isTable) {
      final points = _pointsFromTable(stimulus);
      if (points.length < 2) return _drop();
      return _figure(
        text: text,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        type: type,
        points: points,
        title: stimulus.title,
      );
    }
    if (stimulus.isTranscript || stimulus.isPassage || stimulus.isCue) {
      return _prose(
        text: text,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        type: type,
        body: stimulus.body,
      );
    }
    return keep;
  }

  static StimulusAlignment _figure({
    required String text,
    required List<String> options,
    required int correctIndex,
    required String? explanation,
    required String type,
    required List<({String label, double value})> points,
    required String title,
  }) {
    final keep = StimulusAlignment.keep(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
    );
    if (_isTrueFalse(options)) {
      return _applyVerdict(
        text: text,
        options: options,
        correctIndex: correctIndex,
        verdict: _figureClaim(text, points),
        explanation: explanation,
      );
    }

    final cloze = type == 'fill_blank' || text.contains('_____');
    final asking = _isQuestion(text) || cloze;
    final wantsHigh = _hasAny(text, _high);
    final wantsLow = _hasAny(text, _low);
    if (asking && wantsHigh != wantsLow && (wantsHigh || wantsLow)) {
      final target = _extreme(points, high: wantsHigh);
      if (target == null) return _drop();
      final idx = _optionForPoint(options, target);
      if (idx == null) return _drop();
      if (idx == correctIndex) return keep;
      return _changed(
        text: text,
        correctIndex: idx,
        explanation:
            '${target.label} is the ${wantsHigh ? 'highest' : 'lowest'} value shown (${_fmt(target.value)}).',
      );
    }

    if (asking) {
      final named = _namedInOrder(text, points);
      if (named.length == 1) {
        final valueIdx = _optionForValue(options, named.first.value);
        if (valueIdx != null) {
          if (valueIdx == correctIndex) return keep;
          return _changed(
            text: text,
            correctIndex: valueIdx,
            explanation:
                'The figure shows ${_fmt(named.first.value)} for ${named.first.label}.',
          );
        }
        final labelIdx = _labelOption(options, named.first.label);
        if (labelIdx != null) {
          if (labelIdx == correctIndex) return keep;
          return _changed(
            text: text,
            correctIndex: labelIdx,
            explanation: 'The figure names ${named.first.label}.',
          );
        }
      }
      final stated = _firstNumber(text);
      if (stated != null) {
        final matched = points.where((p) => (p.value - stated).abs() < 0.011).toList();
        if (matched.length == 1) {
          final idx = _labelOption(options, matched.first.label);
          if (idx != null) {
            if (idx == correctIndex) return keep;
            return _changed(
              text: text,
              correctIndex: idx,
              explanation: '${matched.first.label} is the label for ${_fmt(stated)}.',
            );
          }
        }
      }
      return _drop();
    }

    final high = _extreme(points, high: true);
    if (high == null) {
      return const StimulusAlignment(
        text: '',
        correctIndex: 0,
        explanation: null,
        changed: false,
        drop: true,
      );
    }
    final idx = _optionForPoint(options, high);
    if (idx == null) {
      return const StimulusAlignment(
        text: '',
        correctIndex: 0,
        explanation: null,
        changed: false,
        drop: true,
      );
    }
    final subject = title.trim().isEmpty ? 'value' : title.trim().toLowerCase();
    final usesLabels = options.any(
      (o) => points.any((p) => _sameLabel(o, p.label)),
    );
    final stem = usesLabels
        ? 'Which has the highest $subject?'
        : 'What is the highest $subject?';
    return _changed(
      text: stem,
      correctIndex: idx,
      explanation:
          '${high.label} is the highest value shown (${_fmt(high.value)}).',
    );
  }

  static StimulusAlignment _prose({
    required String text,
    required List<String> options,
    required int correctIndex,
    required String? explanation,
    required String type,
    required String body,
  }) {
    final keep = StimulusAlignment.keep(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
    );
    if (_isTrueFalse(options)) {
      final verdict = _proseClaim(text, body);
      if (verdict == _Verdict.unknown && !_hasNotGiven(options)) return _drop();
      return _applyVerdict(
        text: text,
        options: options,
        correctIndex: correctIndex,
        verdict: verdict,
        explanation: explanation,
      );
    }
    final scores = [for (final option in options) _overlap(option, body)];
    if (_asksForAbsence(text)) {
      final absent = <int>[];
      for (var i = 0; i < scores.length; i++) {
        if (scores[i] == 0) absent.add(i);
      }
      if (absent.length != 1) return _drop();
      if (absent.first == correctIndex) return keep;
      return _changed(
        text: text,
        correctIndex: absent.first,
        explanation: 'This is the option the text does not support.',
      );
    }
    if (scores[correctIndex] > 0) return keep;
    final supported = <int>[];
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] > 0) supported.add(i);
    }
    if (supported.length != 1) return _drop();
    if (type == 'fill_blank' && !text.contains('_____') && !_isQuestion(text)) {
      return _drop();
    }
    return _changed(
      text: text,
      correctIndex: supported.first,
      explanation: 'This is the option supported by the text above.',
    );
  }

  static StimulusAlignment _applyVerdict({
    required String text,
    required List<String> options,
    required int correctIndex,
    required _Verdict? verdict,
    required String? explanation,
  }) {
    final keep = StimulusAlignment.keep(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
    );
    if (verdict == null || verdict == _Verdict.unknown) {
      final notGiven = _optionMatching(options, const ['not given', 'not stated']);
      if (notGiven == null) return _drop();
      if (notGiven == correctIndex) return keep;
      return _changed(
        text: text,
        correctIndex: notGiven,
        explanation: 'The material does not state this.',
      );
    }
    final idx = verdict == _Verdict.truth
        ? _optionMatching(options, const ['true', 'yes'])
        : _optionMatching(options, const ['false', 'no']);
    if (idx == null) return _drop();
    if (idx == correctIndex) return keep;
    return _changed(
      text: text,
      correctIndex: idx,
      explanation: verdict == _Verdict.truth
          ? 'The material supports this statement.'
          : 'The material contradicts this statement.',
    );
  }

  static StimulusAlignment _drop() {
    return const StimulusAlignment(
      text: '',
      correctIndex: 0,
      explanation: null,
      changed: false,
      drop: true,
    );
  }

  static StimulusAlignment _changed({
    required String text,
    required int correctIndex,
    required String? explanation,
  }) {
    return StimulusAlignment(
      text: text,
      correctIndex: correctIndex,
      explanation: explanation,
      changed: true,
      drop: false,
    );
  }

  static List<({String label, double value})> _pointsFromTable(
    QuestionStimulus stimulus,
  ) {
    final out = <({String label, double value})>[];
    for (final row in stimulus.rows) {
      if (row.isEmpty) continue;
      final label = row.first.trim();
      double? value;
      for (final cell in row.skip(1)) {
        value = _firstNumber(cell);
        if (value != null) break;
      }
      if (label.isEmpty || value == null) continue;
      out.add((label: label, value: value));
      if (out.length >= 8) break;
    }
    return out;
  }

  static ({String label, double value})? _extreme(
    List<({String label, double value})> points, {
    required bool high,
  }) {
    if (points.isEmpty) return null;
    var best = points.first;
    var tie = false;
    for (final point in points.skip(1)) {
      final better = high ? point.value > best.value : point.value < best.value;
      final same = (point.value - best.value).abs() < 0.011;
      if (better) {
        best = point;
        tie = false;
      } else if (same) {
        tie = true;
      }
    }
    if (tie) return null;
    return best;
  }

  static int? _optionForPoint(
    List<String> options,
    ({String label, double value}) point,
  ) {
    final labelHits = <int>[];
    final valueHits = <int>[];
    for (var i = 0; i < options.length; i++) {
      if (_sameLabel(options[i], point.label)) labelHits.add(i);
      final number = _firstNumber(options[i]);
      if (number != null && (number - point.value).abs() < 0.011) {
        valueHits.add(i);
      }
    }
    if (labelHits.length == 1 && valueHits.isEmpty) return labelHits.first;
    if (valueHits.length == 1 && labelHits.isEmpty) return valueHits.first;
    if (labelHits.length == 1) return labelHits.first;
    if (valueHits.length == 1) return valueHits.first;
    return null;
  }

  static int? _optionForValue(List<String> options, double value) {
    final hits = <int>[];
    for (var i = 0; i < options.length; i++) {
      final number = _firstNumber(options[i]);
      if (number != null && (number - value).abs() < 0.011) hits.add(i);
    }
    if (hits.length == 1) return hits.first;
    return null;
  }

  static bool _isQuestion(String text) {
    final trimmed = text.trim();
    if (trimmed.contains('?')) return true;
    final first = trimmed.split(RegExp(r'\s+')).first.toLowerCase();
    return const {'which', 'what', 'who', 'whose', 'where', 'when', 'why', 'how'}
        .contains(first.replaceAll(RegExp(r'[^\w]'), ''));
  }

  static bool _isTrueFalse(List<String> options) {
    final set = options.map((o) => o.trim().toLowerCase()).toSet();
    final yesNo = (set.contains('true') && set.contains('false')) ||
        (set.contains('yes') && set.contains('no'));
    return yesNo && set.length <= 3;
  }

  static bool _hasNotGiven(List<String> options) {
    final set = options.map((o) => o.trim().toLowerCase()).toSet();
    return set.contains('not given') || set.contains('not stated');
  }

  static bool _asksForAbsence(String text) {
    final lower = text.toLowerCase();
    return lower.contains('not mentioned') ||
        lower.contains('not stated') ||
        lower.contains('except') ||
        lower.contains('which is not') ||
        lower.contains('which of the following is not');
  }

  static _Verdict? _figureClaim(
    String text,
    List<({String label, double value})> points,
  ) {
    final ordered = _namedInOrder(text, points);
    if (ordered.length >= 2) {
      final high = _hasAny(text, _high);
      final low = _hasAny(text, _low);
      if (high && !low) {
        return ordered[0].value > ordered[1].value ? _Verdict.truth : _Verdict.falsehood;
      }
      if (low && !high) {
        return ordered[0].value < ordered[1].value ? _Verdict.truth : _Verdict.falsehood;
      }
    }
    if (ordered.length == 1) {
      final stated = _firstNumber(text);
      if (stated != null) {
        return (stated - ordered.first.value).abs() < 0.011
            ? _Verdict.truth
            : _Verdict.falsehood;
      }
      if (_hasAny(text, _high) && !_hasAny(text, _low)) {
        final top = _extreme(points, high: true);
        if (top == null) return null;
        return top.label.toLowerCase() == ordered.first.label.toLowerCase()
            ? _Verdict.truth
            : _Verdict.falsehood;
      }
      if (_hasAny(text, _low) && !_hasAny(text, _high)) {
        final bottom = _extreme(points, high: false);
        if (bottom == null) return null;
        return bottom.label.toLowerCase() == ordered.first.label.toLowerCase()
            ? _Verdict.truth
            : _Verdict.falsehood;
      }
    }
    return null;
  }

  static _Verdict? _proseClaim(String text, String body) {
    final words = _contentWords(text);
    if (words.isEmpty) return null;
    final missing = words.where((word) {
      return !RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(body.toLowerCase());
    }).isNotEmpty;
    if (!missing) return _Verdict.truth;
    return _Verdict.unknown;
  }

  static List<({String label, double value})> _namedInOrder(
    String text,
    List<({String label, double value})> points,
  ) {
    final lower = text.toLowerCase();
    final found = <(int, ({String label, double value}))>[];
    for (final point in points) {
      final needle = point.label.trim().toLowerCase();
      if (needle.isEmpty) continue;
      final match = RegExp('\\b${RegExp.escape(needle)}\\b').firstMatch(lower);
      if (match != null) found.add((match.start, point));
    }
    found.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final item in found) item.$2];
  }

  static int? _labelOption(List<String> options, String label) {
    final hits = <int>[];
    for (var i = 0; i < options.length; i++) {
      if (_sameLabel(options[i], label)) hits.add(i);
    }
    if (hits.length == 1) return hits.first;
    return null;
  }

  static int? _optionMatching(List<String> options, List<String> names) {
    for (var i = 0; i < options.length; i++) {
      if (names.contains(options[i].trim().toLowerCase())) return i;
    }
    return null;
  }

  static bool _hasAny(String text, Set<String> words) {
    final lower = text.toLowerCase();
    for (final word in words) {
      if (RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(lower)) return true;
    }
    return false;
  }

  static bool _sameLabel(String option, String label) {
    return option.trim().toLowerCase() == label.trim().toLowerCase();
  }

  static int _overlap(String option, String body) {
    final lower = body.toLowerCase();
    var count = 0;
    for (final word in _contentWords(option)) {
      if (RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(lower)) count++;
    }
    return count;
  }

  static List<String> _contentWords(String text) {
    final words = text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty && !_stop.contains(w))
        .where((w) => w.length >= 4 || RegExp(r'^\d').hasMatch(w))
        .toList();
    return words;
  }

  static double? _firstNumber(String text) {
    final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  static String _fmt(double value) {
    if ((value - value.round()).abs() < 0.011) return value.round().toString();
    return value.toString();
  }
}

enum _Verdict { truth, falsehood, unknown }

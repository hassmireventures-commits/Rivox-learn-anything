import 'dart:convert';

/// Material a question depends on. Absent when the stem stands alone.
class QuestionStimulus {
  const QuestionStimulus({
    required this.kind,
    this.title = '',
    this.body = '',
    this.unit = '',
    this.points = const [],
    this.columns = const [],
    this.rows = const [],
  });

  final String kind;
  final String title;
  final String body;
  final String unit;
  final List<({String label, double value})> points;
  final List<String> columns;
  final List<List<String>> rows;

  bool get isPassage => kind == 'passage';
  bool get isTranscript => kind == 'transcript';
  bool get isCue => kind == 'cue';
  bool get isChart => kind == 'chart';
  bool get isTable => kind == 'table';

  static QuestionStimulus? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return fromMap(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static QuestionStimulus? fromMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    final kind = (json['kind']?.toString() ?? '').trim().toLowerCase();
    final title = json['title']?.toString().trim() ?? '';
    final body = json['body']?.toString().trim() ?? '';
    final unit = json['unit']?.toString().trim() ?? '';

    switch (kind) {
      case 'passage':
      case 'transcript':
      case 'cue':
        if (body.isEmpty) return null;
        return QuestionStimulus(kind: kind, title: title, body: body);
      case 'chart':
        final points = _points(json['points']);
        if (points.length < 2) return null;
        return QuestionStimulus(
          kind: kind,
          title: title,
          unit: unit,
          points: points,
        );
      case 'table':
        final columns = _strings(json['columns']);
        final rows = _rows(json['rows'], columns.length);
        if (columns.isEmpty || rows.isEmpty) return null;
        return QuestionStimulus(
          kind: kind,
          title: title,
          columns: columns,
          rows: rows,
        );
      default:
        return null;
    }
  }

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'kind': kind,
      if (title.isNotEmpty) 'title': title,
      if (body.isNotEmpty) 'body': body,
      if (unit.isNotEmpty) 'unit': unit,
      if (points.isNotEmpty)
        'points': [
          for (final p in points) {'label': p.label, 'value': p.value},
        ],
      if (columns.isNotEmpty) 'columns': columns,
      if (rows.isNotEmpty) 'rows': rows,
    };
  }

  static List<({String label, double value})> _points(Object? raw) {
    if (raw is! List) return const [];
    final out = <({String label, double value})>[];
    for (final item in raw) {
      if (out.length >= 8) break;
      if (item is! Map) continue;
      final label = item['label']?.toString().trim() ?? '';
      final value = _number(item['value']);
      if (label.isEmpty || value == null) continue;
      out.add((label: label, value: value));
    }
    return out;
  }

  static List<String> _strings(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .take(6)
        .toList();
  }

  static List<List<String>> _rows(Object? raw, int width) {
    if (raw is! List || width < 1) return const [];
    final out = <List<String>>[];
    for (final item in raw) {
      if (out.length >= 8) break;
      if (item is! List) continue;
      final cells = [
        for (var i = 0; i < width; i++)
          i < item.length ? item[i].toString().trim() : '',
      ];
      if (cells.every((c) => c.isEmpty)) continue;
      out.add(cells);
    }
    return out;
  }

  static double? _number(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }
}

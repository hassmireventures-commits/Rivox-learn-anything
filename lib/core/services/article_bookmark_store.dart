import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A user-saved article (daily pack, learning path, or in-app reader).
class ArticleBookmark {
  const ArticleBookmark({
    required this.url,
    required this.title,
    this.topic = '',
    required this.savedAtMs,
  });

  final String url;
  final String title;
  final String topic;
  final int savedAtMs;

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'topic': topic,
        'savedAtMs': savedAtMs,
      };

  factory ArticleBookmark.fromJson(Map<String, dynamic> json) {
    return ArticleBookmark(
      url: json['url']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Article',
      topic: json['topic']?.toString() ?? '',
      savedAtMs: (json['savedAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// Local JSON store for saved articles (device-only).
class ArticleBookmarkStore extends ChangeNotifier {
  ArticleBookmarkStore._();
  static final instance = ArticleBookmarkStore._();

  static const _fileName = 'article_bookmarks_v1.json';
  List<ArticleBookmark> _items = [];

  List<ArticleBookmark> get items => List.unmodifiable(_items);

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return;
      _items = decoded
          .whereType<Map<String, dynamic>>()
          .map(ArticleBookmark.fromJson)
          .where((b) => b.url.isNotEmpty)
          .toList()
        ..sort((a, b) => b.savedAtMs.compareTo(a.savedAtMs));
    } catch (_) {}
  }

  Future<void> _persist() async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  bool isBookmarked(String url) =>
      _items.any((b) => b.url == url);

  Future<void> toggle({
    required String url,
    required String title,
    String topic = '',
  }) async {
    if (url.isEmpty) return;
    if (isBookmarked(url)) {
      _items.removeWhere((b) => b.url == url);
    } else {
      _items.insert(
        0,
        ArticleBookmark(
          url: url,
          title: title,
          topic: topic,
          savedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    await _persist();
  }

  Future<void> remove(String url) async {
    _items.removeWhere((b) => b.url == url);
    await _persist();
  }

  /// Clears all bookmarks and deletes the on-disk store (Settings reset).
  Future<void> clear() async {
    _items = [];
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (_) {}
    notifyListeners();
  }
}

/// In-memory TTL cache for public API responses (avoids hammering free endpoints).
class OpenKnowledgeCache {
  OpenKnowledgeCache._();

  static const ttl = Duration(minutes: 10);
  static final Map<String, ({DateTime at, Object? value})> _store = {};

  static T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.at) > ttl) {
      _store.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  static void set(String key, Object? value) {
    _store[key] = (at: DateTime.now(), value: value);
  }

  static void clear() => _store.clear();
}

import 'package:isar_community/isar.dart';

import '../isar_service.dart';
import '../models/chat_message.dart';

/// Persistence for the single continuous RAG chat thread (B1 — no
/// multiple/named threads in v1).
class ChatRepository {
  ChatRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  /// Chat history in chronological order (oldest first), capped to the most
  /// recent [limit] messages.
  Future<List<ChatMessage>> getHistory({int limit = 100}) async {
    final mostRecentFirst = await _db.chatMessages
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
    return mostRecentFirst.reversed.toList();
  }

  Future<void> appendMessage(ChatMessage message) async {
    await _db.writeTxn(() async {
      await _db.chatMessages.put(message);
    });
  }
}

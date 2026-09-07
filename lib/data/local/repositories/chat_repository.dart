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

  /// All chat messages (not just the windowed [getHistory] result), for B13
  /// cloud backup (Phase 2).
  Future<List<Map<String, dynamic>>> exportMessages() async {
    final messages = await _db.chatMessages.where().findAll();
    return messages
        .map((m) => {
              'uuid': m.uuid,
              'role': m.role,
              'text': m.text,
              'createdAt': m.createdAt.toIso8601String(),
              'contextRef': m.contextRef,
            })
        .toList();
  }

  /// Replaces all chat messages from a B13 cloud-backup manifest (Phase 3
  /// restore). Caller is responsible for clearing existing rows first (see
  /// `IsarService.clearBackupInScopeData`) — this only writes.
  Future<void> importMessages(List<dynamic> data) async {
    final messages = data.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return ChatMessage()
        ..uuid = m['uuid'] as String
        ..role = m['role'] as String
        ..text = m['text'] as String
        ..createdAt = DateTime.parse(m['createdAt'] as String)
        ..contextRef = m['contextRef'] as String?;
    }).toList();

    await _db.writeTxn(() async {
      await _db.chatMessages.putAll(messages);
    });
  }
}

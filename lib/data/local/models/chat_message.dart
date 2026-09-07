import 'package:isar_community/isar.dart';

part 'chat_message.g.dart';

/// One turn in the single continuous RAG chat thread (B1).
@collection
class ChatMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  /// 'user' | 'assistant'
  late String role;

  late String text;

  @Index()
  late DateTime createdAt;

  /// Optional module/quiz id this message was asked about — informational only.
  String? contextRef;
}

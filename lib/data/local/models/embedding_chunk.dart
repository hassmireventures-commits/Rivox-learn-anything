import 'package:isar_community/isar.dart';

part 'embedding_chunk.g.dart';

@collection
class EmbeddingChunk {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String chunkId;

  late String topic;

  /// JSON list of doubles
  late String vectorJson;
  late DateTime updatedAt;
}

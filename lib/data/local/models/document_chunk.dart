import 'package:isar_community/isar.dart';

part 'document_chunk.g.dart';

@collection
class DocumentChunk {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String chunkId;

  @Index()
  late String sourceUuid;

  late String text;
  int? page;
  String? section;
  late String vectorJson;
  late int tokenEstimate;

  /// Human label for citations e.g. "Resume - Experience"
  String? citationLabel;

  @Index()
  late DateTime updatedAt;
}

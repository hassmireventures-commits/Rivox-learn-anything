import 'package:isar_community/isar.dart';

part 'knowledge_source.g.dart';

@collection
class KnowledgeSource {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String goalMode;

  /// resume | jd | book | notes | syllabus_pdf | website
  @Index()
  late String type;

  late String title;
  String? localPath;
  String? url;
  String? domain;

  /// pending | indexing | indexed | failed
  late String status;

  String? statusMessage;
  DateTime? consentAt;
  late bool enabled;
  DateTime? lastIndexedAt;
  late DateTime createdAt;
}

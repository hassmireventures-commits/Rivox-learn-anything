import 'package:isar_community/isar.dart';

part 'user_website.g.dart';

@collection
class UserWebsite {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String domain;

  late String label;

  @Index()
  late String goalMode;

  String? startUrl;
  DateTime? lastCrawledAt;

  /// single_page | manual_refresh
  late String crawlMode;

  late bool enabled;
  late DateTime createdAt;
}

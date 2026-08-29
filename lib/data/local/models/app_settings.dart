import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  /// system | light | dark
  late String themeMode;

  String? defaultProviderId;
  late String language;
  late int roomExpiryHours;
}

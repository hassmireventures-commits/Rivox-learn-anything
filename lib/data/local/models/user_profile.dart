import 'package:isar_community/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime createdAt;

  /// Firebase uid, set only if the learner signed in during onboarding (or
  /// later). Null means fully local/guest — the default, unchanged behavior.
  String? authUid;

  /// Email of the linked account, for display only (e.g. "Signed in as
  /// x@y.com" in Settings). Never used as an identifier.
  String? authEmail;
}

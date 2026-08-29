import 'package:isar_community/isar.dart';

part 'daily_stat.g.dart';

@collection
class DailyStat {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String dateKey;

  late DateTime date;
  late int quizzesCount;
  late int questionsSolved;
  late int correctCount;
  late double accuracySum;
  late int totalTimeSeconds;
}

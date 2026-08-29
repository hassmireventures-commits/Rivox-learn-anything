import 'package:isar_community/isar.dart';

part 'model_weights.g.dart';

@collection
class ModelWeights {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String modelId;

  /// JSON map of feature -> weight
  late String weightsJson;
  late DateTime updatedAt;
}

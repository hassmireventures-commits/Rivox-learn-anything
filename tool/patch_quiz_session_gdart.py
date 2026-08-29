"""Patch quiz_session.g.dart schema sections for new QuizSession fields."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GDART = ROOT / "lib/data/local/models/quiz_session.g.dart"

PROPERTIES = """
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completionTokens': PropertySchema(
      id: 2,
      name: r'completionTokens',
      type: IsarType.long,
    ),
    r'correctCount': PropertySchema(
      id: 3,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'difficulty': PropertySchema(
      id: 4,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'generateExplanations': PropertySchema(
      id: 5,
      name: r'generateExplanations',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 6,
      name: r'language',
      type: IsarType.string,
    ),
    r'moduleIndex': PropertySchema(
      id: 7,
      name: r'moduleIndex',
      type: IsarType.long,
    ),
    r'pathId': PropertySchema(
      id: 8,
      name: r'pathId',
      type: IsarType.string,
    ),
    r'promptTokens': PropertySchema(
      id: 9,
      name: r'promptTokens',
      type: IsarType.long,
    ),
    r'questionCount': PropertySchema(
      id: 10,
      name: r'questionCount',
      type: IsarType.long,
    ),
    r'questionType': PropertySchema(
      id: 11,
      name: r'questionType',
      type: IsarType.string,
    ),
    r'quizKind': PropertySchema(
      id: 12,
      name: r'quizKind',
      type: IsarType.string,
    ),
    r'randomizeOptions': PropertySchema(
      id: 13,
      name: r'randomizeOptions',
      type: IsarType.bool,
    ),
    r'randomizeQuestions': PropertySchema(
      id: 14,
      name: r'randomizeQuestions',
      type: IsarType.bool,
    ),
    r'roomId': PropertySchema(id: 15, name: r'roomId', type: IsarType.string),
    r'score': PropertySchema(id: 16, name: r'score', type: IsarType.long),
    r'source': PropertySchema(id: 17, name: r'source', type: IsarType.string),
    r'startedAt': PropertySchema(
      id: 18,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'timeTakenSeconds': PropertySchema(
      id: 19,
      name: r'timeTakenSeconds',
      type: IsarType.long,
    ),
    r'timerSeconds': PropertySchema(
      id: 20,
      name: r'timerSeconds',
      type: IsarType.long,
    ),
    r'topic': PropertySchema(id: 21, name: r'topic', type: IsarType.string),
    r'uuid': PropertySchema(id: 22, name: r'uuid', type: IsarType.string),
    r'wrongCount': PropertySchema(
      id: 23,
      name: r'wrongCount',
      type: IsarType.long,
    ),
"""

INDEXES_EXTRA = """
    r'quizKind': IndexSchema(
      id: 5829471038264519021,
      name: r'quizKind',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'quizKind',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
"""

ESTIMATE_SIZE = """
int _quizSessionEstimateSize(
  QuizSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.difficulty.length * 3;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.questionType.length * 3;
  bytesCount += 3 + object.quizKind.length * 3;
  {
    final value = object.pathId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.roomId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.topic.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}
"""

SERIALIZE = """
void _quizSessionSerialize(
  QuizSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeLong(offsets[2], object.completionTokens);
  writer.writeLong(offsets[3], object.correctCount);
  writer.writeString(offsets[4], object.difficulty);
  writer.writeBool(offsets[5], object.generateExplanations);
  writer.writeString(offsets[6], object.language);
  writer.writeLong(offsets[7], object.moduleIndex);
  writer.writeString(offsets[8], object.pathId);
  writer.writeLong(offsets[9], object.promptTokens);
  writer.writeLong(offsets[10], object.questionCount);
  writer.writeString(offsets[11], object.questionType);
  writer.writeString(offsets[12], object.quizKind);
  writer.writeBool(offsets[13], object.randomizeOptions);
  writer.writeBool(offsets[14], object.randomizeQuestions);
  writer.writeString(offsets[15], object.roomId);
  writer.writeLong(offsets[16], object.score);
  writer.writeString(offsets[17], object.source);
  writer.writeDateTime(offsets[18], object.startedAt);
  writer.writeLong(offsets[19], object.timeTakenSeconds);
  writer.writeLong(offsets[20], object.timerSeconds);
  writer.writeString(offsets[21], object.topic);
  writer.writeString(offsets[22], object.uuid);
  writer.writeLong(offsets[23], object.wrongCount);
}
"""

DESERIALIZE = """
QuizSession _quizSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuizSession();
  object.accuracy = reader.readDoubleOrNull(offsets[0]);
  object.completedAt = reader.readDateTimeOrNull(offsets[1]);
  object.completionTokens = reader.readLongOrNull(offsets[2]);
  object.correctCount = reader.readLongOrNull(offsets[3]);
  object.difficulty = reader.readString(offsets[4]);
  object.generateExplanations = reader.readBool(offsets[5]);
  object.id = id;
  object.language = reader.readString(offsets[6]);
  object.moduleIndex = reader.readLongOrNull(offsets[7]);
  object.pathId = reader.readStringOrNull(offsets[8]);
  object.promptTokens = reader.readLongOrNull(offsets[9]);
  object.questionCount = reader.readLong(offsets[10]);
  object.questionType = reader.readString(offsets[11]);
  object.quizKind = reader.readStringOrNull(offsets[12]) ?? 'quick';
  object.randomizeOptions = reader.readBool(offsets[13]);
  object.randomizeQuestions = reader.readBool(offsets[14]);
  object.roomId = reader.readStringOrNull(offsets[15]);
  object.score = reader.readLongOrNull(offsets[16]);
  object.source = reader.readString(offsets[17]);
  object.startedAt = reader.readDateTime(offsets[18]);
  object.timeTakenSeconds = reader.readLongOrNull(offsets[19]);
  object.timerSeconds = reader.readLongOrNull(offsets[20]);
  object.topic = reader.readString(offsets[21]);
  object.uuid = reader.readString(offsets[22]);
  object.wrongCount = reader.readLongOrNull(offsets[23]);
  return object;
}
"""

DESERIALIZE_PROP = """
P _quizSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}
"""


def replace_block(text: str, start_marker: str, end_marker: str, new_body: str) -> str:
    start = text.index(start_marker)
    end = text.index(end_marker, start)
    return text[:start] + new_body + text[end:]


def main() -> None:
    text = GDART.read_text(encoding="utf-8")

    # properties block inside CollectionSchema
    text = replace_block(
        text,
        "  properties: {\n",
        "\n  },\n\n  estimateSize:",
        "  properties: {" + PROPERTIES + "\n  },\n\n  estimateSize:",
    )

    # insert quizKind index before closing indexes
    text = text.replace(
        "    r'completedAt': IndexSchema(",
        INDEXES_EXTRA + "    r'completedAt': IndexSchema(",
    )

    text = replace_block(
        text,
        "int _quizSessionEstimateSize(",
        "\n\nvoid _quizSessionSerialize(",
        ESTIMATE_SIZE + "\n",
    )
    text = replace_block(
        text,
        "void _quizSessionSerialize(",
        "\n\nQuizSession _quizSessionDeserialize(",
        SERIALIZE + "\n",
    )
    text = replace_block(
        text,
        "QuizSession _quizSessionDeserialize(",
        "\n\nP _quizSessionDeserializeProp<P>(",
        DESERIALIZE + "\n",
    )
    text = replace_block(
        text,
        "P _quizSessionDeserializeProp<P>(",
        "\n\nId _quizSessionGetId(",
        DESERIALIZE_PROP + "\n",
    )

    GDART.write_text(text, encoding="utf-8")
    print(f"Patched {GDART}")


if __name__ == "__main__":
    main()

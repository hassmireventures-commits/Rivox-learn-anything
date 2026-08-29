// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuizSessionCollection on Isar {
  IsarCollection<QuizSession> get quizSessions => this.collection();
}

const QuizSessionSchema = CollectionSchema(
  name: r'QuizSession',
  id: 1455044083199775799,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'attemptNumber': PropertySchema(
      id: 1,
      name: r'attemptNumber',
      type: IsarType.long,
    ),
    r'citationChunkIdsJson': PropertySchema(
      id: 2,
      name: r'citationChunkIdsJson',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 3,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completionTokens': PropertySchema(
      id: 4,
      name: r'completionTokens',
      type: IsarType.long,
    ),
    r'correctCount': PropertySchema(
      id: 5,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'difficulty': PropertySchema(
      id: 6,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'examDurationSeconds': PropertySchema(
      id: 7,
      name: r'examDurationSeconds',
      type: IsarType.long,
    ),
    r'generateExplanations': PropertySchema(
      id: 8,
      name: r'generateExplanations',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 9,
      name: r'language',
      type: IsarType.string,
    ),
    r'moduleIndex': PropertySchema(
      id: 10,
      name: r'moduleIndex',
      type: IsarType.long,
    ),
    r'passPercent': PropertySchema(
      id: 11,
      name: r'passPercent',
      type: IsarType.long,
    ),
    r'pathId': PropertySchema(id: 12, name: r'pathId', type: IsarType.string),
    r'promptTokens': PropertySchema(
      id: 13,
      name: r'promptTokens',
      type: IsarType.long,
    ),
    r'questionCount': PropertySchema(
      id: 14,
      name: r'questionCount',
      type: IsarType.long,
    ),
    r'questionType': PropertySchema(
      id: 15,
      name: r'questionType',
      type: IsarType.string,
    ),
    r'quizKind': PropertySchema(
      id: 16,
      name: r'quizKind',
      type: IsarType.string,
    ),
    r'randomizeOptions': PropertySchema(
      id: 17,
      name: r'randomizeOptions',
      type: IsarType.bool,
    ),
    r'randomizeQuestions': PropertySchema(
      id: 18,
      name: r'randomizeQuestions',
      type: IsarType.bool,
    ),
    r'roomId': PropertySchema(id: 19, name: r'roomId', type: IsarType.string),
    r'score': PropertySchema(id: 20, name: r'score', type: IsarType.long),
    r'scorePercent': PropertySchema(
      id: 21,
      name: r'scorePercent',
      type: IsarType.double,
    ),
    r'source': PropertySchema(id: 22, name: r'source', type: IsarType.string),
    r'startedAt': PropertySchema(
      id: 23,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'syllabusUuid': PropertySchema(
      id: 24,
      name: r'syllabusUuid',
      type: IsarType.string,
    ),
    r'timeTakenSeconds': PropertySchema(
      id: 25,
      name: r'timeTakenSeconds',
      type: IsarType.long,
    ),
    r'timerSeconds': PropertySchema(
      id: 26,
      name: r'timerSeconds',
      type: IsarType.long,
    ),
    r'topic': PropertySchema(id: 27, name: r'topic', type: IsarType.string),
    r'unitFilterJson': PropertySchema(
      id: 28,
      name: r'unitFilterJson',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(id: 29, name: r'uuid', type: IsarType.string),
    r'wrongCount': PropertySchema(
      id: 30,
      name: r'wrongCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _quizSessionEstimateSize,
  serialize: _quizSessionSerialize,
  deserialize: _quizSessionDeserialize,
  deserializeProp: _quizSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'topic': IndexSchema(
      id: 1007953096175763270,
      name: r'topic',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topic',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'difficulty': IndexSchema(
      id: 3042583923453520767,
      name: r'difficulty',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'difficulty',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'completedAt': IndexSchema(
      id: -3156591011457686752,
      name: r'completedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'completedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'quizKind': IndexSchema(
      id: -5376800160978825311,
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
  },
  links: {},
  embeddedSchemas: {},

  getId: _quizSessionGetId,
  getLinks: _quizSessionGetLinks,
  attach: _quizSessionAttach,
  version: '3.3.2',
);

int _quizSessionEstimateSize(
  QuizSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.citationChunkIdsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.difficulty.length * 3;
  bytesCount += 3 + object.language.length * 3;
  {
    final value = object.pathId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.questionType.length * 3;
  bytesCount += 3 + object.quizKind.length * 3;
  {
    final value = object.roomId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  {
    final value = object.syllabusUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.topic.length * 3;
  {
    final value = object.unitFilterJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _quizSessionSerialize(
  QuizSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeLong(offsets[1], object.attemptNumber);
  writer.writeString(offsets[2], object.citationChunkIdsJson);
  writer.writeDateTime(offsets[3], object.completedAt);
  writer.writeLong(offsets[4], object.completionTokens);
  writer.writeLong(offsets[5], object.correctCount);
  writer.writeString(offsets[6], object.difficulty);
  writer.writeLong(offsets[7], object.examDurationSeconds);
  writer.writeBool(offsets[8], object.generateExplanations);
  writer.writeString(offsets[9], object.language);
  writer.writeLong(offsets[10], object.moduleIndex);
  writer.writeLong(offsets[11], object.passPercent);
  writer.writeString(offsets[12], object.pathId);
  writer.writeLong(offsets[13], object.promptTokens);
  writer.writeLong(offsets[14], object.questionCount);
  writer.writeString(offsets[15], object.questionType);
  writer.writeString(offsets[16], object.quizKind);
  writer.writeBool(offsets[17], object.randomizeOptions);
  writer.writeBool(offsets[18], object.randomizeQuestions);
  writer.writeString(offsets[19], object.roomId);
  writer.writeLong(offsets[20], object.score);
  writer.writeDouble(offsets[21], object.scorePercent);
  writer.writeString(offsets[22], object.source);
  writer.writeDateTime(offsets[23], object.startedAt);
  writer.writeString(offsets[24], object.syllabusUuid);
  writer.writeLong(offsets[25], object.timeTakenSeconds);
  writer.writeLong(offsets[26], object.timerSeconds);
  writer.writeString(offsets[27], object.topic);
  writer.writeString(offsets[28], object.unitFilterJson);
  writer.writeString(offsets[29], object.uuid);
  writer.writeLong(offsets[30], object.wrongCount);
}

QuizSession _quizSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuizSession();
  object.accuracy = reader.readDoubleOrNull(offsets[0]);
  object.attemptNumber = reader.readLongOrNull(offsets[1]);
  object.citationChunkIdsJson = reader.readStringOrNull(offsets[2]);
  object.completedAt = reader.readDateTimeOrNull(offsets[3]);
  object.completionTokens = reader.readLongOrNull(offsets[4]);
  object.correctCount = reader.readLongOrNull(offsets[5]);
  object.difficulty = reader.readString(offsets[6]);
  object.examDurationSeconds = reader.readLongOrNull(offsets[7]);
  object.generateExplanations = reader.readBool(offsets[8]);
  object.id = id;
  object.language = reader.readString(offsets[9]);
  object.moduleIndex = reader.readLongOrNull(offsets[10]);
  object.passPercent = reader.readLongOrNull(offsets[11]);
  object.pathId = reader.readStringOrNull(offsets[12]);
  object.promptTokens = reader.readLongOrNull(offsets[13]);
  object.questionCount = reader.readLong(offsets[14]);
  object.questionType = reader.readString(offsets[15]);
  object.quizKind = reader.readString(offsets[16]);
  object.randomizeOptions = reader.readBool(offsets[17]);
  object.randomizeQuestions = reader.readBool(offsets[18]);
  object.roomId = reader.readStringOrNull(offsets[19]);
  object.score = reader.readLongOrNull(offsets[20]);
  object.scorePercent = reader.readDoubleOrNull(offsets[21]);
  object.source = reader.readString(offsets[22]);
  object.startedAt = reader.readDateTime(offsets[23]);
  object.syllabusUuid = reader.readStringOrNull(offsets[24]);
  object.timeTakenSeconds = reader.readLongOrNull(offsets[25]);
  object.timerSeconds = reader.readLongOrNull(offsets[26]);
  object.topic = reader.readString(offsets[27]);
  object.unitFilterJson = reader.readStringOrNull(offsets[28]);
  object.uuid = reader.readString(offsets[29]);
  object.wrongCount = reader.readLongOrNull(offsets[30]);
  return object;
}

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
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readDoubleOrNull(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    case 26:
      return (reader.readLongOrNull(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _quizSessionGetId(QuizSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quizSessionGetLinks(QuizSession object) {
  return [];
}

void _quizSessionAttach(
  IsarCollection<dynamic> col,
  Id id,
  QuizSession object,
) {
  object.id = id;
}

extension QuizSessionByIndex on IsarCollection<QuizSession> {
  Future<QuizSession?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  QuizSession? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<QuizSession?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<QuizSession?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(QuizSession object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(QuizSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<QuizSession> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<QuizSession> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension QuizSessionQueryWhereSort
    on QueryBuilder<QuizSession, QuizSession, QWhere> {
  QueryBuilder<QuizSession, QuizSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhere> anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhere> anyCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'completedAt'),
      );
    });
  }
}

extension QuizSessionQueryWhere
    on QueryBuilder<QuizSession, QuizSession, QWhereClause> {
  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> uuidNotEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> topicEqualTo(
    String topic,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'topic', value: [topic]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> topicNotEqualTo(
    String topic,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topic',
                lower: [],
                upper: [topic],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topic',
                lower: [topic],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topic',
                lower: [topic],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topic',
                lower: [],
                upper: [topic],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> difficultyEqualTo(
    String difficulty,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'difficulty', value: [difficulty]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  difficultyNotEqualTo(String difficulty) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'difficulty',
                lower: [],
                upper: [difficulty],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'difficulty',
                lower: [difficulty],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'difficulty',
                lower: [difficulty],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'difficulty',
                lower: [],
                upper: [difficulty],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> startedAtEqualTo(
    DateTime startedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startedAt', value: [startedAt]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> startedAtNotEqualTo(
    DateTime startedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  startedAtGreaterThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [startedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> startedAtLessThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [],
          upper: [startedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [lowerStartedAt],
          includeLower: includeLower,
          upper: [upperStartedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'completedAt', value: [null]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> completedAtEqualTo(
    DateTime? completedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'completedAt',
          value: [completedAt],
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  completedAtNotEqualTo(DateTime? completedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [],
                upper: [completedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [completedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [completedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [],
                upper: [completedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause>
  completedAtGreaterThan(DateTime? completedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [completedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> completedAtLessThan(
    DateTime? completedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [],
          upper: [completedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> completedAtBetween(
    DateTime? lowerCompletedAt,
    DateTime? upperCompletedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [lowerCompletedAt],
          includeLower: includeLower,
          upper: [upperCompletedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> quizKindEqualTo(
    String quizKind,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'quizKind', value: [quizKind]),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> quizKindNotEqualTo(
    String quizKind,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'quizKind',
                lower: [],
                upper: [quizKind],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'quizKind',
                lower: [quizKind],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'quizKind',
                lower: [quizKind],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'quizKind',
                lower: [],
                upper: [quizKind],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension QuizSessionQueryFilter
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {
  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  accuracyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accuracy'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  accuracyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accuracy'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> accuracyEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accuracy',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  accuracyGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accuracy',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  accuracyLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accuracy',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> accuracyBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accuracy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attemptNumber'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attemptNumber'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attemptNumber', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attemptNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attemptNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  attemptNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attemptNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'citationChunkIdsJson'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'citationChunkIdsJson'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'citationChunkIdsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'citationChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'citationChunkIdsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'citationChunkIdsJson', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  citationChunkIdsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'citationChunkIdsJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completionTokens'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completionTokens'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completionTokens', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completionTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completionTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  completionTokensBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completionTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'correctCount'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'correctCount'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'correctCount', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'correctCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'correctCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  correctCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'correctCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'difficulty',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'difficulty',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'difficulty',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'difficulty', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'difficulty', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'examDurationSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'examDurationSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'examDurationSeconds', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'examDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'examDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  examDurationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'examDurationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  generateExplanationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'generateExplanations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> languageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'moduleIndex'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'moduleIndex'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'moduleIndex', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'moduleIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'moduleIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  moduleIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'moduleIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'passPercent'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'passPercent'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'passPercent', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'passPercent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'passPercent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  passPercentBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'passPercent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pathId'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  pathIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pathId'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  pathIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pathId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  pathIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pathId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pathIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pathId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  pathIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pathId', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  pathIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pathId', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'promptTokens'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'promptTokens'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'promptTokens', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'promptTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'promptTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  promptTokensBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'promptTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'questionCount', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'questionCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'questionCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'questionCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'questionType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'questionType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'questionType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'questionType', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  questionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'questionType', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> quizKindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> quizKindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quizKind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quizKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> quizKindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quizKind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quizKind', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  quizKindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quizKind', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  randomizeOptionsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'randomizeOptions', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  randomizeQuestionsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'randomizeQuestions', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'roomId'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  roomIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'roomId'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  roomIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'roomId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  roomIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'roomId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> roomIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'roomId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  roomIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'roomId', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  roomIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'roomId', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> scoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'score'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'score'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> scoreEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'score', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scoreGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'score',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> scoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'score',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> scoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'score',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'scorePercent'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'scorePercent'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scorePercent',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scorePercent',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scorePercent',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  scorePercentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scorePercent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  sourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> sourceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'source',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syllabusUuid'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syllabusUuid'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syllabusUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syllabusUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syllabusUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  syllabusUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'timeTakenSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'timeTakenSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeTakenSeconds', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeTakenSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeTakenSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timeTakenSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeTakenSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'timerSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'timerSeconds'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timerSeconds', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timerSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timerSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  timerSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timerSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'topic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'topic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'topic', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'topic', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'unitFilterJson'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'unitFilterJson'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unitFilterJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unitFilterJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unitFilterJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unitFilterJson', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  unitFilterJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unitFilterJson', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'wrongCount'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'wrongCount'),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wrongCount', value: value),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
  wrongCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wrongCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension QuizSessionQueryObject
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {}

extension QuizSessionQueryLinks
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {}

extension QuizSessionQuerySortBy
    on QueryBuilder<QuizSession, QuizSession, QSortBy> {
  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByAttemptNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptNumber', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByAttemptNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptNumber', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByCitationChunkIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationChunkIdsJson', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByCitationChunkIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationChunkIdsJson', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByExamDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByExamDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByGenerateExplanations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateExplanations', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByGenerateExplanationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateExplanations', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByModuleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleIndex', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByModuleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleIndex', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPassPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passPercent', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPassPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passPercent', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPathId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPathIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByQuestionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByQuestionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByQuizKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizKind', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByQuizKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizKind', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByRandomizeOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeOptions', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByRandomizeOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeOptions', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByRandomizeQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeQuestions', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByRandomizeQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeQuestions', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByScorePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercent', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByScorePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercent', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByTimeTakenSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTakenSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByTimeTakenSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTakenSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByTimerSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByUnitFilterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitFilterJson', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  sortByUnitFilterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitFilterJson', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension QuizSessionQuerySortThenBy
    on QueryBuilder<QuizSession, QuizSession, QSortThenBy> {
  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByAttemptNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptNumber', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByAttemptNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptNumber', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByCitationChunkIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationChunkIdsJson', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByCitationChunkIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationChunkIdsJson', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByExamDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByExamDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByGenerateExplanations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateExplanations', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByGenerateExplanationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateExplanations', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByModuleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleIndex', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByModuleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleIndex', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPassPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passPercent', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPassPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passPercent', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPathId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPathIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByQuestionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByQuestionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByQuizKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizKind', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByQuizKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizKind', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByRandomizeOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeOptions', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByRandomizeOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeOptions', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByRandomizeQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeQuestions', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByRandomizeQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'randomizeQuestions', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByScorePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercent', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByScorePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scorePercent', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByTimeTakenSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTakenSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByTimeTakenSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTakenSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByTimerSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByUnitFilterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitFilterJson', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
  thenByUnitFilterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitFilterJson', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension QuizSessionQueryWhereDistinct
    on QueryBuilder<QuizSession, QuizSession, QDistinct> {
  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByAttemptNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptNumber');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByCitationChunkIdsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'citationChunkIdsJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionTokens');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByDifficulty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByExamDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examDurationSeconds');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByGenerateExplanations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generateExplanations');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByLanguage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByModuleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moduleIndex');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByPassPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passPercent');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByPathId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pathId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'promptTokens');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionCount');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByQuestionType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByQuizKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quizKind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByRandomizeOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'randomizeOptions');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByRandomizeQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'randomizeQuestions');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByRoomId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByScorePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scorePercent');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySyllabusUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syllabusUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
  distinctByTimeTakenSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeTakenSeconds');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timerSeconds');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByTopic({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByUnitFilterJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'unitFilterJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrongCount');
    });
  }
}

extension QuizSessionQueryProperty
    on QueryBuilder<QuizSession, QuizSession, QQueryProperty> {
  QueryBuilder<QuizSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuizSession, double?, QQueryOperations> accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> attemptNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptNumber');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations>
  citationChunkIdsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'citationChunkIdsJson');
    });
  }

  QueryBuilder<QuizSession, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> completionTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionTokens');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations>
  examDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examDurationSeconds');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations>
  generateExplanationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generateExplanations');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> moduleIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moduleIndex');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> passPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passPercent');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> pathIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pathId');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> promptTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptTokens');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> questionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionCount');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> questionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionType');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> quizKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quizKind');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations> randomizeOptionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'randomizeOptions');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations>
  randomizeQuestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'randomizeQuestions');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> roomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomId');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<QuizSession, double?, QQueryOperations> scorePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scorePercent');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<QuizSession, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> syllabusUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syllabusUuid');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> timeTakenSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeTakenSeconds');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> timerSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timerSeconds');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations>
  unitFilterJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitFilterJson');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<QuizSession, int?, QQueryOperations> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrongCount');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFlashcardCollection on Isar {
  IsarCollection<Flashcard> get flashcards => this.collection();
}

const FlashcardSchema = CollectionSchema(
  name: r'Flashcard',
  id: -5712857134961670327,
  properties: {
    r'back': PropertySchema(id: 0, name: r'back', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'easeFactor': PropertySchema(
      id: 2,
      name: r'easeFactor',
      type: IsarType.double,
    ),
    r'front': PropertySchema(id: 3, name: r'front', type: IsarType.string),
    r'goalMode': PropertySchema(
      id: 4,
      name: r'goalMode',
      type: IsarType.string,
    ),
    r'intervalDays': PropertySchema(
      id: 5,
      name: r'intervalDays',
      type: IsarType.long,
    ),
    r'lastReviewedAt': PropertySchema(
      id: 6,
      name: r'lastReviewedAt',
      type: IsarType.dateTime,
    ),
    r'nextReviewAt': PropertySchema(
      id: 7,
      name: r'nextReviewAt',
      type: IsarType.dateTime,
    ),
    r'repetitions': PropertySchema(
      id: 8,
      name: r'repetitions',
      type: IsarType.long,
    ),
    r'sourceRef': PropertySchema(
      id: 9,
      name: r'sourceRef',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 10,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(id: 11, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _flashcardEstimateSize,
  serialize: _flashcardSerialize,
  deserialize: _flashcardDeserialize,
  deserializeProp: _flashcardDeserializeProp,
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
    r'sourceType': IndexSchema(
      id: 5365578901051110922,
      name: r'sourceType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'goalMode': IndexSchema(
      id: 8458058537980181431,
      name: r'goalMode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'goalMode',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'nextReviewAt': IndexSchema(
      id: -3214419740154650383,
      name: r'nextReviewAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nextReviewAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _flashcardGetId,
  getLinks: _flashcardGetLinks,
  attach: _flashcardAttach,
  version: '3.3.2',
);

int _flashcardEstimateSize(
  Flashcard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.back.length * 3;
  bytesCount += 3 + object.front.length * 3;
  bytesCount += 3 + object.goalMode.length * 3;
  {
    final value = object.sourceRef;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceType.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _flashcardSerialize(
  Flashcard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.back);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.easeFactor);
  writer.writeString(offsets[3], object.front);
  writer.writeString(offsets[4], object.goalMode);
  writer.writeLong(offsets[5], object.intervalDays);
  writer.writeDateTime(offsets[6], object.lastReviewedAt);
  writer.writeDateTime(offsets[7], object.nextReviewAt);
  writer.writeLong(offsets[8], object.repetitions);
  writer.writeString(offsets[9], object.sourceRef);
  writer.writeString(offsets[10], object.sourceType);
  writer.writeString(offsets[11], object.uuid);
}

Flashcard _flashcardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Flashcard();
  object.back = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.easeFactor = reader.readDouble(offsets[2]);
  object.front = reader.readString(offsets[3]);
  object.goalMode = reader.readString(offsets[4]);
  object.id = id;
  object.intervalDays = reader.readLong(offsets[5]);
  object.lastReviewedAt = reader.readDateTimeOrNull(offsets[6]);
  object.nextReviewAt = reader.readDateTime(offsets[7]);
  object.repetitions = reader.readLong(offsets[8]);
  object.sourceRef = reader.readStringOrNull(offsets[9]);
  object.sourceType = reader.readString(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  return object;
}

P _flashcardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _flashcardGetId(Flashcard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _flashcardGetLinks(Flashcard object) {
  return [];
}

void _flashcardAttach(IsarCollection<dynamic> col, Id id, Flashcard object) {
  object.id = id;
}

extension FlashcardByIndex on IsarCollection<Flashcard> {
  Future<Flashcard?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  Flashcard? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<Flashcard?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<Flashcard?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(Flashcard object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(Flashcard object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<Flashcard> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<Flashcard> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension FlashcardQueryWhereSort
    on QueryBuilder<Flashcard, Flashcard, QWhere> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyNextReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nextReviewAt'),
      );
    });
  }
}

extension FlashcardQueryWhere
    on QueryBuilder<Flashcard, Flashcard, QWhereClause> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> sourceTypeEqualTo(
    String sourceType,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sourceType', value: [sourceType]),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> sourceTypeNotEqualTo(
    String sourceType,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType',
                lower: [],
                upper: [sourceType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType',
                lower: [sourceType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType',
                lower: [sourceType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceType',
                lower: [],
                upper: [sourceType],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> goalModeEqualTo(
    String goalMode,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'goalMode', value: [goalMode]),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> goalModeNotEqualTo(
    String goalMode,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [],
                upper: [goalMode],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [goalMode],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [goalMode],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [],
                upper: [goalMode],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> createdAtEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> createdAtNotEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewAtEqualTo(
    DateTime nextReviewAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'nextReviewAt',
          value: [nextReviewAt],
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewAtNotEqualTo(
    DateTime nextReviewAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextReviewAt',
                lower: [],
                upper: [nextReviewAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextReviewAt',
                lower: [nextReviewAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextReviewAt',
                lower: [nextReviewAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextReviewAt',
                lower: [],
                upper: [nextReviewAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewAtGreaterThan(
    DateTime nextReviewAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextReviewAt',
          lower: [nextReviewAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewAtLessThan(
    DateTime nextReviewAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextReviewAt',
          lower: [],
          upper: [nextReviewAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewAtBetween(
    DateTime lowerNextReviewAt,
    DateTime upperNextReviewAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextReviewAt',
          lower: [lowerNextReviewAt],
          includeLower: includeLower,
          upper: [upperNextReviewAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FlashcardQueryFilter
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {
  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'back',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'back',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'back',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'back', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> backIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'back', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> easeFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'easeFactor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  easeFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'easeFactor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> easeFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'easeFactor',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> easeFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'easeFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'front',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'front',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'front',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'front', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> frontIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'front', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'goalMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'goalMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> goalModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  goalModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> intervalDaysEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intervalDays', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  intervalDaysGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intervalDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  intervalDaysLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intervalDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> intervalDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intervalDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastReviewedAt'),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastReviewedAt'),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastReviewedAt', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastReviewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastReviewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  lastReviewedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastReviewedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> nextReviewAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextReviewAt', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  nextReviewAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextReviewAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  nextReviewAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextReviewAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> nextReviewAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextReviewAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> repetitionsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repetitions', value: value),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  repetitionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> repetitionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> repetitionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repetitions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceRef'),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceRefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceRef'),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceRefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceRef',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceRef',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceRef',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceRef', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceRef', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sourceTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceType', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
  sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceType', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidGreaterThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidStartsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidContains(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension FlashcardQueryObject
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQueryLinks
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQuerySortBy on QueryBuilder<Flashcard, Flashcard, QSortBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByBack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'back', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByBackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'back', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByFront() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'front', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByFrontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'front', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLastReviewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReviewAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitions', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitions', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySourceRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySourceRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension FlashcardQuerySortThenBy
    on QueryBuilder<Flashcard, Flashcard, QSortThenBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByBack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'back', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByBackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'back', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByFront() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'front', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByFrontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'front', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalDays', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLastReviewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewAt', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReviewAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewAt', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitions', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitions', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySourceRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySourceRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension FlashcardQueryWhereDistinct
    on QueryBuilder<Flashcard, Flashcard, QDistinct> {
  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByBack({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'back', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easeFactor');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByFront({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'front', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByGoalMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalDays');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReviewedAt');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByNextReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReviewAt');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repetitions');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctBySourceRef({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceRef', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctBySourceType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension FlashcardQueryProperty
    on QueryBuilder<Flashcard, Flashcard, QQueryProperty> {
  QueryBuilder<Flashcard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> backProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'back');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Flashcard, double, QQueryOperations> easeFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easeFactor');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> frontProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'front');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> goalModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalMode');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalDays');
    });
  }

  QueryBuilder<Flashcard, DateTime?, QQueryOperations>
  lastReviewedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReviewedAt');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations> nextReviewAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReviewAt');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> repetitionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repetitions');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> sourceRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceRef');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}

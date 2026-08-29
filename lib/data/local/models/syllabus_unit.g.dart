// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syllabus_unit.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyllabusUnitCollection on Isar {
  IsarCollection<SyllabusUnit> get syllabusUnits => this.collection();
}

const SyllabusUnitSchema = CollectionSchema(
  name: r'SyllabusUnit',
  id: -3247916599646638627,
  properties: {
    r'lastPracticedAt': PropertySchema(
      id: 0,
      name: r'lastPracticedAt',
      type: IsarType.dateTime,
    ),
    r'mastery': PropertySchema(id: 1, name: r'mastery', type: IsarType.double),
    r'orderIndex': PropertySchema(
      id: 2,
      name: r'orderIndex',
      type: IsarType.long,
    ),
    r'pathId': PropertySchema(id: 3, name: r'pathId', type: IsarType.string),
    r'syllabusUuid': PropertySchema(
      id: 4,
      name: r'syllabusUuid',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
    r'topicKeysJson': PropertySchema(
      id: 6,
      name: r'topicKeysJson',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 8, name: r'uuid', type: IsarType.string),
    r'weight': PropertySchema(id: 9, name: r'weight', type: IsarType.double),
  },

  estimateSize: _syllabusUnitEstimateSize,
  serialize: _syllabusUnitSerialize,
  deserialize: _syllabusUnitDeserialize,
  deserializeProp: _syllabusUnitDeserializeProp,
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
    r'syllabusUuid': IndexSchema(
      id: 4928751998285393511,
      name: r'syllabusUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syllabusUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _syllabusUnitGetId,
  getLinks: _syllabusUnitGetLinks,
  attach: _syllabusUnitAttach,
  version: '3.3.2',
);

int _syllabusUnitEstimateSize(
  SyllabusUnit object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.pathId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syllabusUuid.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.topicKeysJson.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _syllabusUnitSerialize(
  SyllabusUnit object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastPracticedAt);
  writer.writeDouble(offsets[1], object.mastery);
  writer.writeLong(offsets[2], object.orderIndex);
  writer.writeString(offsets[3], object.pathId);
  writer.writeString(offsets[4], object.syllabusUuid);
  writer.writeString(offsets[5], object.title);
  writer.writeString(offsets[6], object.topicKeysJson);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.uuid);
  writer.writeDouble(offsets[9], object.weight);
}

SyllabusUnit _syllabusUnitDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyllabusUnit();
  object.id = id;
  object.lastPracticedAt = reader.readDateTimeOrNull(offsets[0]);
  object.mastery = reader.readDouble(offsets[1]);
  object.orderIndex = reader.readLong(offsets[2]);
  object.pathId = reader.readStringOrNull(offsets[3]);
  object.syllabusUuid = reader.readString(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.topicKeysJson = reader.readString(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  object.weight = reader.readDouble(offsets[9]);
  return object;
}

P _syllabusUnitDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syllabusUnitGetId(SyllabusUnit object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syllabusUnitGetLinks(SyllabusUnit object) {
  return [];
}

void _syllabusUnitAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyllabusUnit object,
) {
  object.id = id;
}

extension SyllabusUnitByIndex on IsarCollection<SyllabusUnit> {
  Future<SyllabusUnit?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  SyllabusUnit? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<SyllabusUnit?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<SyllabusUnit?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(SyllabusUnit object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(SyllabusUnit object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<SyllabusUnit> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<SyllabusUnit> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension SyllabusUnitQueryWhereSort
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QWhere> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyllabusUnitQueryWhere
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QWhereClause> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause>
  syllabusUuidEqualTo(String syllabusUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'syllabusUuid',
          value: [syllabusUuid],
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterWhereClause>
  syllabusUuidNotEqualTo(String syllabusUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syllabusUuid',
                lower: [],
                upper: [syllabusUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syllabusUuid',
                lower: [syllabusUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syllabusUuid',
                lower: [syllabusUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syllabusUuid',
                lower: [],
                upper: [syllabusUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SyllabusUnitQueryFilter
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QFilterCondition> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPracticedAt'),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPracticedAt'),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPracticedAt', value: value),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPracticedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPracticedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  lastPracticedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPracticedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  masteryEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mastery',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  masteryGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mastery',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  masteryLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mastery',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  masteryBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mastery',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  orderIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'orderIndex', value: value),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  orderIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'orderIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  orderIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'orderIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  orderIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'orderIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pathId'),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pathId'),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> pathIdEqualTo(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdLessThan(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> pathIdBetween(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> pathIdMatches(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pathId', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  pathIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pathId', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidGreaterThan(
    String value, {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidLessThan(
    String value, {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidBetween(
    String lower,
    String upper, {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  syllabusUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'topicKeysJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'topicKeysJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'topicKeysJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'topicKeysJson', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  topicKeysJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'topicKeysJson', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  uuidGreaterThan(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidContains(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition>
  weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterFilterCondition> weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension SyllabusUnitQueryObject
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QFilterCondition> {}

extension SyllabusUnitQueryLinks
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QFilterCondition> {}

extension SyllabusUnitQuerySortBy
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QSortBy> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  sortByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  sortByLastPracticedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByMastery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastery', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByMasteryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastery', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByPathId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByPathIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  sortBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByTopicKeysJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicKeysJson', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  sortByTopicKeysJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicKeysJson', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension SyllabusUnitQuerySortThenBy
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QSortThenBy> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  thenByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  thenByLastPracticedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByMastery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastery', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByMasteryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastery', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByPathId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByPathIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathId', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  thenBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByTopicKeysJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicKeysJson', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy>
  thenByTopicKeysJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicKeysJson', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension SyllabusUnitQueryWhereDistinct
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> {
  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct>
  distinctByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPracticedAt');
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByMastery() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mastery');
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderIndex');
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByPathId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pathId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctBySyllabusUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syllabusUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByTopicKeysJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'topicKeysJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyllabusUnit, SyllabusUnit, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension SyllabusUnitQueryProperty
    on QueryBuilder<SyllabusUnit, SyllabusUnit, QQueryProperty> {
  QueryBuilder<SyllabusUnit, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyllabusUnit, DateTime?, QQueryOperations>
  lastPracticedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPracticedAt');
    });
  }

  QueryBuilder<SyllabusUnit, double, QQueryOperations> masteryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mastery');
    });
  }

  QueryBuilder<SyllabusUnit, int, QQueryOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderIndex');
    });
  }

  QueryBuilder<SyllabusUnit, String?, QQueryOperations> pathIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pathId');
    });
  }

  QueryBuilder<SyllabusUnit, String, QQueryOperations> syllabusUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syllabusUuid');
    });
  }

  QueryBuilder<SyllabusUnit, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SyllabusUnit, String, QQueryOperations> topicKeysJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topicKeysJson');
    });
  }

  QueryBuilder<SyllabusUnit, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SyllabusUnit, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<SyllabusUnit, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

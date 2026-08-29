// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_usage_daily.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAiUsageDailyCollection on Isar {
  IsarCollection<AiUsageDaily> get aiUsageDailys => this.collection();
}

const AiUsageDailySchema = CollectionSchema(
  name: r'AiUsageDaily',
  id: -3624558965365285547,
  properties: {
    r'callCount': PropertySchema(
      id: 0,
      name: r'callCount',
      type: IsarType.long,
    ),
    r'completionTokens': PropertySchema(
      id: 1,
      name: r'completionTokens',
      type: IsarType.long,
    ),
    r'day': PropertySchema(id: 2, name: r'day', type: IsarType.dateTime),
    r'failureCount': PropertySchema(
      id: 3,
      name: r'failureCount',
      type: IsarType.long,
    ),
    r'lastLatencyMs': PropertySchema(
      id: 4,
      name: r'lastLatencyMs',
      type: IsarType.long,
    ),
    r'promptTokens': PropertySchema(
      id: 5,
      name: r'promptTokens',
      type: IsarType.long,
    ),
    r'providerKey': PropertySchema(
      id: 6,
      name: r'providerKey',
      type: IsarType.string,
    ),
    r'rateLimitCount': PropertySchema(
      id: 7,
      name: r'rateLimitCount',
      type: IsarType.long,
    ),
    r'successCount': PropertySchema(
      id: 8,
      name: r'successCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _aiUsageDailyEstimateSize,
  serialize: _aiUsageDailySerialize,
  deserialize: _aiUsageDailyDeserialize,
  deserializeProp: _aiUsageDailyDeserializeProp,
  idName: r'id',
  indexes: {
    r'providerKey': IndexSchema(
      id: 4830899061330615695,
      name: r'providerKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'day': IndexSchema(
      id: 3809350088207220763,
      name: r'day',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'day',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _aiUsageDailyGetId,
  getLinks: _aiUsageDailyGetLinks,
  attach: _aiUsageDailyAttach,
  version: '3.3.2',
);

int _aiUsageDailyEstimateSize(
  AiUsageDaily object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.providerKey.length * 3;
  return bytesCount;
}

void _aiUsageDailySerialize(
  AiUsageDaily object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.callCount);
  writer.writeLong(offsets[1], object.completionTokens);
  writer.writeDateTime(offsets[2], object.day);
  writer.writeLong(offsets[3], object.failureCount);
  writer.writeLong(offsets[4], object.lastLatencyMs);
  writer.writeLong(offsets[5], object.promptTokens);
  writer.writeString(offsets[6], object.providerKey);
  writer.writeLong(offsets[7], object.rateLimitCount);
  writer.writeLong(offsets[8], object.successCount);
}

AiUsageDaily _aiUsageDailyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AiUsageDaily();
  object.callCount = reader.readLong(offsets[0]);
  object.completionTokens = reader.readLong(offsets[1]);
  object.day = reader.readDateTime(offsets[2]);
  object.failureCount = reader.readLong(offsets[3]);
  object.id = id;
  object.lastLatencyMs = reader.readLong(offsets[4]);
  object.promptTokens = reader.readLong(offsets[5]);
  object.providerKey = reader.readString(offsets[6]);
  object.rateLimitCount = reader.readLong(offsets[7]);
  object.successCount = reader.readLong(offsets[8]);
  return object;
}

P _aiUsageDailyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _aiUsageDailyGetId(AiUsageDaily object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aiUsageDailyGetLinks(AiUsageDaily object) {
  return [];
}

void _aiUsageDailyAttach(
  IsarCollection<dynamic> col,
  Id id,
  AiUsageDaily object,
) {
  object.id = id;
}

extension AiUsageDailyQueryWhereSort
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QWhere> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhere> anyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'day'),
      );
    });
  }
}

extension AiUsageDailyQueryWhere
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QWhereClause> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> idBetween(
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause>
  providerKeyEqualTo(String providerKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'providerKey',
          value: [providerKey],
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause>
  providerKeyNotEqualTo(String providerKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'providerKey',
                lower: [],
                upper: [providerKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'providerKey',
                lower: [providerKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'providerKey',
                lower: [providerKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'providerKey',
                lower: [],
                upper: [providerKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> dayEqualTo(
    DateTime day,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'day', value: [day]),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> dayNotEqualTo(
    DateTime day,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'day',
                lower: [],
                upper: [day],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'day',
                lower: [day],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'day',
                lower: [day],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'day',
                lower: [],
                upper: [day],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> dayGreaterThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'day',
          lower: [day],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> dayLessThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'day',
          lower: [],
          upper: [day],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterWhereClause> dayBetween(
    DateTime lowerDay,
    DateTime upperDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'day',
          lower: [lowerDay],
          includeLower: includeLower,
          upper: [upperDay],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AiUsageDailyQueryFilter
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QFilterCondition> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  callCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'callCount', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  callCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'callCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  callCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'callCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  callCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'callCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  completionTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completionTokens', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  completionTokensGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  completionTokensLessThan(int value, {bool include = false}) {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  completionTokensBetween(
    int lower,
    int upper, {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> dayEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'day', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  dayGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'day',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> dayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'day',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> dayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'day',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  failureCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failureCount', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  failureCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failureCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  failureCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failureCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  failureCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failureCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  lastLatencyMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastLatencyMs', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  lastLatencyMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastLatencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  lastLatencyMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastLatencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  lastLatencyMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastLatencyMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  promptTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'promptTokens', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  promptTokensGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  promptTokensLessThan(int value, {bool include = false}) {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  promptTokensBetween(
    int lower,
    int upper, {
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

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'providerKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'providerKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'providerKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'providerKey', value: ''),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  providerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'providerKey', value: ''),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  rateLimitCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rateLimitCount', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  rateLimitCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rateLimitCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  rateLimitCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rateLimitCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  rateLimitCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rateLimitCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  successCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'successCount', value: value),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  successCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'successCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  successCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'successCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterFilterCondition>
  successCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'successCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AiUsageDailyQueryObject
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QFilterCondition> {}

extension AiUsageDailyQueryLinks
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QFilterCondition> {}

extension AiUsageDailyQuerySortBy
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QSortBy> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByCallCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByCallCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByLastLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByLastLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByRateLimitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateLimitCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortByRateLimitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateLimitCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> sortBySuccessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  sortBySuccessCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successCount', Sort.desc);
    });
  }
}

extension AiUsageDailyQuerySortThenBy
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QSortThenBy> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByCallCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByCallCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByFailureCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByLastLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByLastLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLatencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByRateLimitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateLimitCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenByRateLimitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rateLimitCount', Sort.desc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy> thenBySuccessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successCount', Sort.asc);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QAfterSortBy>
  thenBySuccessCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successCount', Sort.desc);
    });
  }
}

extension AiUsageDailyQueryWhereDistinct
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> {
  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctByCallCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'callCount');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct>
  distinctByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionTokens');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'day');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctByFailureCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failureCount');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct>
  distinctByLastLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLatencyMs');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'promptTokens');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctByProviderKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct>
  distinctByRateLimitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rateLimitCount');
    });
  }

  QueryBuilder<AiUsageDaily, AiUsageDaily, QDistinct> distinctBySuccessCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successCount');
    });
  }
}

extension AiUsageDailyQueryProperty
    on QueryBuilder<AiUsageDaily, AiUsageDaily, QQueryProperty> {
  QueryBuilder<AiUsageDaily, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> callCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'callCount');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> completionTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionTokens');
    });
  }

  QueryBuilder<AiUsageDaily, DateTime, QQueryOperations> dayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'day');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> failureCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failureCount');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> lastLatencyMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLatencyMs');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> promptTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptTokens');
    });
  }

  QueryBuilder<AiUsageDaily, String, QQueryOperations> providerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerKey');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> rateLimitCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rateLimitCount');
    });
  }

  QueryBuilder<AiUsageDaily, int, QQueryOperations> successCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successCount');
    });
  }
}

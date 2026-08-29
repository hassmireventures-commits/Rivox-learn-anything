// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_strategy.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPromptStrategyCollection on Isar {
  IsarCollection<PromptStrategy> get promptStrategys => this.collection();
}

const PromptStrategySchema = CollectionSchema(
  name: r'PromptStrategy',
  id: 6684847892104337139,
  properties: {
    r'attempts': PropertySchema(id: 0, name: r'attempts', type: IsarType.long),
    r'label': PropertySchema(id: 1, name: r'label', type: IsarType.string),
    r'strategyId': PropertySchema(
      id: 2,
      name: r'strategyId',
      type: IsarType.string,
    ),
    r'successRate': PropertySchema(
      id: 3,
      name: r'successRate',
      type: IsarType.double,
    ),
    r'successes': PropertySchema(
      id: 4,
      name: r'successes',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weight': PropertySchema(id: 6, name: r'weight', type: IsarType.double),
  },

  estimateSize: _promptStrategyEstimateSize,
  serialize: _promptStrategySerialize,
  deserialize: _promptStrategyDeserialize,
  deserializeProp: _promptStrategyDeserializeProp,
  idName: r'id',
  indexes: {
    r'strategyId': IndexSchema(
      id: 3128489696359807082,
      name: r'strategyId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'strategyId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _promptStrategyGetId,
  getLinks: _promptStrategyGetLinks,
  attach: _promptStrategyAttach,
  version: '3.3.2',
);

int _promptStrategyEstimateSize(
  PromptStrategy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.strategyId.length * 3;
  return bytesCount;
}

void _promptStrategySerialize(
  PromptStrategy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attempts);
  writer.writeString(offsets[1], object.label);
  writer.writeString(offsets[2], object.strategyId);
  writer.writeDouble(offsets[3], object.successRate);
  writer.writeLong(offsets[4], object.successes);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeDouble(offsets[6], object.weight);
}

PromptStrategy _promptStrategyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PromptStrategy();
  object.attempts = reader.readLong(offsets[0]);
  object.id = id;
  object.label = reader.readString(offsets[1]);
  object.strategyId = reader.readString(offsets[2]);
  object.successRate = reader.readDouble(offsets[3]);
  object.successes = reader.readLong(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  object.weight = reader.readDouble(offsets[6]);
  return object;
}

P _promptStrategyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _promptStrategyGetId(PromptStrategy object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _promptStrategyGetLinks(PromptStrategy object) {
  return [];
}

void _promptStrategyAttach(
  IsarCollection<dynamic> col,
  Id id,
  PromptStrategy object,
) {
  object.id = id;
}

extension PromptStrategyByIndex on IsarCollection<PromptStrategy> {
  Future<PromptStrategy?> getByStrategyId(String strategyId) {
    return getByIndex(r'strategyId', [strategyId]);
  }

  PromptStrategy? getByStrategyIdSync(String strategyId) {
    return getByIndexSync(r'strategyId', [strategyId]);
  }

  Future<bool> deleteByStrategyId(String strategyId) {
    return deleteByIndex(r'strategyId', [strategyId]);
  }

  bool deleteByStrategyIdSync(String strategyId) {
    return deleteByIndexSync(r'strategyId', [strategyId]);
  }

  Future<List<PromptStrategy?>> getAllByStrategyId(
    List<String> strategyIdValues,
  ) {
    final values = strategyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'strategyId', values);
  }

  List<PromptStrategy?> getAllByStrategyIdSync(List<String> strategyIdValues) {
    final values = strategyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'strategyId', values);
  }

  Future<int> deleteAllByStrategyId(List<String> strategyIdValues) {
    final values = strategyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'strategyId', values);
  }

  int deleteAllByStrategyIdSync(List<String> strategyIdValues) {
    final values = strategyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'strategyId', values);
  }

  Future<Id> putByStrategyId(PromptStrategy object) {
    return putByIndex(r'strategyId', object);
  }

  Id putByStrategyIdSync(PromptStrategy object, {bool saveLinks = true}) {
    return putByIndexSync(r'strategyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStrategyId(List<PromptStrategy> objects) {
    return putAllByIndex(r'strategyId', objects);
  }

  List<Id> putAllByStrategyIdSync(
    List<PromptStrategy> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'strategyId', objects, saveLinks: saveLinks);
  }
}

extension PromptStrategyQueryWhereSort
    on QueryBuilder<PromptStrategy, PromptStrategy, QWhere> {
  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PromptStrategyQueryWhere
    on QueryBuilder<PromptStrategy, PromptStrategy, QWhereClause> {
  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause> idBetween(
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause>
  strategyIdEqualTo(String strategyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'strategyId', value: [strategyId]),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterWhereClause>
  strategyIdNotEqualTo(String strategyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'strategyId',
                lower: [],
                upper: [strategyId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'strategyId',
                lower: [strategyId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'strategyId',
                lower: [strategyId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'strategyId',
                lower: [],
                upper: [strategyId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PromptStrategyQueryFilter
    on QueryBuilder<PromptStrategy, PromptStrategy, QFilterCondition> {
  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  attemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attempts', value: value),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  attemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  attemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'strategyId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'strategyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'strategyId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'strategyId', value: ''),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  strategyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'strategyId', value: ''),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successRateEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'successRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'successRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'successRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'successRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'successes', value: value),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'successes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'successes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  successesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'successes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  weightEqualTo(double value, {double epsilon = Query.epsilon}) {
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
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

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterFilterCondition>
  weightBetween(
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

extension PromptStrategyQueryObject
    on QueryBuilder<PromptStrategy, PromptStrategy, QFilterCondition> {}

extension PromptStrategyQueryLinks
    on QueryBuilder<PromptStrategy, PromptStrategy, QFilterCondition> {}

extension PromptStrategyQuerySortBy
    on QueryBuilder<PromptStrategy, PromptStrategy, QSortBy> {
  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortByStrategyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortByStrategyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortBySuccesses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successes', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortBySuccessesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successes', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension PromptStrategyQuerySortThenBy
    on QueryBuilder<PromptStrategy, PromptStrategy, QSortThenBy> {
  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenByStrategyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenByStrategyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenBySuccesses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successes', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenBySuccessesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successes', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QAfterSortBy>
  thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension PromptStrategyQueryWhereDistinct
    on QueryBuilder<PromptStrategy, PromptStrategy, QDistinct> {
  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct> distinctByLabel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct> distinctByStrategyId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strategyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct>
  distinctBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successRate');
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct>
  distinctBySuccesses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successes');
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PromptStrategy, PromptStrategy, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension PromptStrategyQueryProperty
    on QueryBuilder<PromptStrategy, PromptStrategy, QQueryProperty> {
  QueryBuilder<PromptStrategy, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PromptStrategy, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<PromptStrategy, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<PromptStrategy, String, QQueryOperations> strategyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strategyId');
    });
  }

  QueryBuilder<PromptStrategy, double, QQueryOperations> successRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successRate');
    });
  }

  QueryBuilder<PromptStrategy, int, QQueryOperations> successesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successes');
    });
  }

  QueryBuilder<PromptStrategy, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PromptStrategy, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

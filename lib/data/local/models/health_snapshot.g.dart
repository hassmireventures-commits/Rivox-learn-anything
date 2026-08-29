// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHealthSnapshotCollection on Isar {
  IsarCollection<HealthSnapshot> get healthSnapshots => this.collection();
}

const HealthSnapshotSchema = CollectionSchema(
  name: r'HealthSnapshot',
  id: 6696792979165729457,
  properties: {
    r'avgLatencyMs': PropertySchema(
      id: 0,
      name: r'avgLatencyMs',
      type: IsarType.double,
    ),
    r'circuitStatesJson': PropertySchema(
      id: 1,
      name: r'circuitStatesJson',
      type: IsarType.string,
    ),
    r'degradeNonCriticalUi': PropertySchema(
      id: 2,
      name: r'degradeNonCriticalUi',
      type: IsarType.bool,
    ),
    r'errorRate': PropertySchema(
      id: 3,
      name: r'errorRate',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 4,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _healthSnapshotEstimateSize,
  serialize: _healthSnapshotSerialize,
  deserialize: _healthSnapshotDeserialize,
  deserializeProp: _healthSnapshotDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _healthSnapshotGetId,
  getLinks: _healthSnapshotGetLinks,
  attach: _healthSnapshotAttach,
  version: '3.3.2',
);

int _healthSnapshotEstimateSize(
  HealthSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.circuitStatesJson.length * 3;
  return bytesCount;
}

void _healthSnapshotSerialize(
  HealthSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgLatencyMs);
  writer.writeString(offsets[1], object.circuitStatesJson);
  writer.writeBool(offsets[2], object.degradeNonCriticalUi);
  writer.writeDouble(offsets[3], object.errorRate);
  writer.writeDateTime(offsets[4], object.timestamp);
}

HealthSnapshot _healthSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HealthSnapshot();
  object.avgLatencyMs = reader.readDouble(offsets[0]);
  object.circuitStatesJson = reader.readString(offsets[1]);
  object.degradeNonCriticalUi = reader.readBool(offsets[2]);
  object.errorRate = reader.readDouble(offsets[3]);
  object.id = id;
  object.timestamp = reader.readDateTime(offsets[4]);
  return object;
}

P _healthSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _healthSnapshotGetId(HealthSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _healthSnapshotGetLinks(HealthSnapshot object) {
  return [];
}

void _healthSnapshotAttach(
  IsarCollection<dynamic> col,
  Id id,
  HealthSnapshot object,
) {
  object.id = id;
}

extension HealthSnapshotQueryWhereSort
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QWhere> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HealthSnapshotQueryWhere
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QWhereClause> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idBetween(
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
}

extension HealthSnapshotQueryFilter
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  avgLatencyMsEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'avgLatencyMs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  avgLatencyMsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'avgLatencyMs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  avgLatencyMsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'avgLatencyMs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  avgLatencyMsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'avgLatencyMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'circuitStatesJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'circuitStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'circuitStatesJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'circuitStatesJson', value: ''),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  circuitStatesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'circuitStatesJson', value: ''),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  degradeNonCriticalUiEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'degradeNonCriticalUi',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  errorRateEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'errorRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  errorRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'errorRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  errorRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'errorRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  errorRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'errorRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension HealthSnapshotQueryObject
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {}

extension HealthSnapshotQueryLinks
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {}

extension HealthSnapshotQuerySortBy
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QSortBy> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByAvgLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgLatencyMs', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByAvgLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgLatencyMs', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByCircuitStatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circuitStatesJson', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByCircuitStatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circuitStatesJson', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByDegradeNonCriticalUi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degradeNonCriticalUi', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByDegradeNonCriticalUiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degradeNonCriticalUi', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension HealthSnapshotQuerySortThenBy
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QSortThenBy> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByAvgLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgLatencyMs', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByAvgLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgLatencyMs', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByCircuitStatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circuitStatesJson', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByCircuitStatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'circuitStatesJson', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByDegradeNonCriticalUi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degradeNonCriticalUi', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByDegradeNonCriticalUiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degradeNonCriticalUi', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension HealthSnapshotQueryWhereDistinct
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
  distinctByAvgLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgLatencyMs');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
  distinctByCircuitStatesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'circuitStatesJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
  distinctByDegradeNonCriticalUi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'degradeNonCriticalUi');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
  distinctByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorRate');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension HealthSnapshotQueryProperty
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QQueryProperty> {
  QueryBuilder<HealthSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HealthSnapshot, double, QQueryOperations>
  avgLatencyMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgLatencyMs');
    });
  }

  QueryBuilder<HealthSnapshot, String, QQueryOperations>
  circuitStatesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'circuitStatesJson');
    });
  }

  QueryBuilder<HealthSnapshot, bool, QQueryOperations>
  degradeNonCriticalUiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'degradeNonCriticalUi');
    });
  }

  QueryBuilder<HealthSnapshot, double, QQueryOperations> errorRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorRate');
    });
  }

  QueryBuilder<HealthSnapshot, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stat.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyStatCollection on Isar {
  IsarCollection<DailyStat> get dailyStats => this.collection();
}

const DailyStatSchema = CollectionSchema(
  name: r'DailyStat',
  id: -8394353298243927381,
  properties: {
    r'accuracySum': PropertySchema(
      id: 0,
      name: r'accuracySum',
      type: IsarType.double,
    ),
    r'correctCount': PropertySchema(
      id: 1,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'date': PropertySchema(id: 2, name: r'date', type: IsarType.dateTime),
    r'dateKey': PropertySchema(id: 3, name: r'dateKey', type: IsarType.string),
    r'questionsSolved': PropertySchema(
      id: 4,
      name: r'questionsSolved',
      type: IsarType.long,
    ),
    r'quizzesCount': PropertySchema(
      id: 5,
      name: r'quizzesCount',
      type: IsarType.long,
    ),
    r'totalTimeSeconds': PropertySchema(
      id: 6,
      name: r'totalTimeSeconds',
      type: IsarType.long,
    ),
  },

  estimateSize: _dailyStatEstimateSize,
  serialize: _dailyStatSerialize,
  deserialize: _dailyStatDeserialize,
  deserializeProp: _dailyStatDeserializeProp,
  idName: r'id',
  indexes: {
    r'dateKey': IndexSchema(
      id: 7975223786082927131,
      name: r'dateKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dailyStatGetId,
  getLinks: _dailyStatGetLinks,
  attach: _dailyStatAttach,
  version: '3.3.2',
);

int _dailyStatEstimateSize(
  DailyStat object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateKey.length * 3;
  return bytesCount;
}

void _dailyStatSerialize(
  DailyStat object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracySum);
  writer.writeLong(offsets[1], object.correctCount);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeString(offsets[3], object.dateKey);
  writer.writeLong(offsets[4], object.questionsSolved);
  writer.writeLong(offsets[5], object.quizzesCount);
  writer.writeLong(offsets[6], object.totalTimeSeconds);
}

DailyStat _dailyStatDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyStat();
  object.accuracySum = reader.readDouble(offsets[0]);
  object.correctCount = reader.readLong(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.dateKey = reader.readString(offsets[3]);
  object.id = id;
  object.questionsSolved = reader.readLong(offsets[4]);
  object.quizzesCount = reader.readLong(offsets[5]);
  object.totalTimeSeconds = reader.readLong(offsets[6]);
  return object;
}

P _dailyStatDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyStatGetId(DailyStat object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyStatGetLinks(DailyStat object) {
  return [];
}

void _dailyStatAttach(IsarCollection<dynamic> col, Id id, DailyStat object) {
  object.id = id;
}

extension DailyStatByIndex on IsarCollection<DailyStat> {
  Future<DailyStat?> getByDateKey(String dateKey) {
    return getByIndex(r'dateKey', [dateKey]);
  }

  DailyStat? getByDateKeySync(String dateKey) {
    return getByIndexSync(r'dateKey', [dateKey]);
  }

  Future<bool> deleteByDateKey(String dateKey) {
    return deleteByIndex(r'dateKey', [dateKey]);
  }

  bool deleteByDateKeySync(String dateKey) {
    return deleteByIndexSync(r'dateKey', [dateKey]);
  }

  Future<List<DailyStat?>> getAllByDateKey(List<String> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'dateKey', values);
  }

  List<DailyStat?> getAllByDateKeySync(List<String> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dateKey', values);
  }

  Future<int> deleteAllByDateKey(List<String> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dateKey', values);
  }

  int deleteAllByDateKeySync(List<String> dateKeyValues) {
    final values = dateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dateKey', values);
  }

  Future<Id> putByDateKey(DailyStat object) {
    return putByIndex(r'dateKey', object);
  }

  Id putByDateKeySync(DailyStat object, {bool saveLinks = true}) {
    return putByIndexSync(r'dateKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDateKey(List<DailyStat> objects) {
    return putAllByIndex(r'dateKey', objects);
  }

  List<Id> putAllByDateKeySync(
    List<DailyStat> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'dateKey', objects, saveLinks: saveLinks);
  }
}

extension DailyStatQueryWhereSort
    on QueryBuilder<DailyStat, DailyStat, QWhere> {
  QueryBuilder<DailyStat, DailyStat, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyStatQueryWhere
    on QueryBuilder<DailyStat, DailyStat, QWhereClause> {
  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> dateKeyEqualTo(
    String dateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dateKey', value: [dateKey]),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterWhereClause> dateKeyNotEqualTo(
    String dateKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [],
                upper: [dateKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [dateKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [dateKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateKey',
                lower: [],
                upper: [dateKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension DailyStatQueryFilter
    on QueryBuilder<DailyStat, DailyStat, QFilterCondition> {
  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> accuracySumEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accuracySum',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  accuracySumGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accuracySum',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> accuracySumLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accuracySum',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> accuracySumBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accuracySum',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> correctCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'correctCount', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  correctCountGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  correctCountLessThan(int value, {bool include = false}) {
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> correctCountBetween(
    int lower,
    int upper, {
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dateKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> dateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dateKey', value: ''),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  dateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dateKey', value: ''),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  questionsSolvedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'questionsSolved', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  questionsSolvedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'questionsSolved',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  questionsSolvedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'questionsSolved',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  questionsSolvedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'questionsSolved',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> quizzesCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quizzesCount', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  quizzesCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quizzesCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  quizzesCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quizzesCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition> quizzesCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quizzesCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  totalTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalTimeSeconds', value: value),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  totalTimeSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  totalTimeSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterFilterCondition>
  totalTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalTimeSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyStatQueryObject
    on QueryBuilder<DailyStat, DailyStat, QFilterCondition> {}

extension DailyStatQueryLinks
    on QueryBuilder<DailyStat, DailyStat, QFilterCondition> {}

extension DailyStatQuerySortBy on QueryBuilder<DailyStat, DailyStat, QSortBy> {
  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByAccuracySum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracySum', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByAccuracySumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracySum', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByQuestionsSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionsSolved', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByQuestionsSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionsSolved', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByQuizzesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizzesCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByQuizzesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizzesCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> sortByTotalTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy>
  sortByTotalTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSeconds', Sort.desc);
    });
  }
}

extension DailyStatQuerySortThenBy
    on QueryBuilder<DailyStat, DailyStat, QSortThenBy> {
  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByAccuracySum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracySum', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByAccuracySumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracySum', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByQuestionsSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionsSolved', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByQuestionsSolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionsSolved', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByQuizzesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizzesCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByQuizzesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizzesCount', Sort.desc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy> thenByTotalTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QAfterSortBy>
  thenByTotalTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeSeconds', Sort.desc);
    });
  }
}

extension DailyStatQueryWhereDistinct
    on QueryBuilder<DailyStat, DailyStat, QDistinct> {
  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByAccuracySum() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracySum');
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByDateKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByQuestionsSolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionsSolved');
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByQuizzesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quizzesCount');
    });
  }

  QueryBuilder<DailyStat, DailyStat, QDistinct> distinctByTotalTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTimeSeconds');
    });
  }
}

extension DailyStatQueryProperty
    on QueryBuilder<DailyStat, DailyStat, QQueryProperty> {
  QueryBuilder<DailyStat, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyStat, double, QQueryOperations> accuracySumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracySum');
    });
  }

  QueryBuilder<DailyStat, int, QQueryOperations> correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<DailyStat, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyStat, String, QQueryOperations> dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<DailyStat, int, QQueryOperations> questionsSolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionsSolved');
    });
  }

  QueryBuilder<DailyStat, int, QQueryOperations> quizzesCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quizzesCount');
    });
  }

  QueryBuilder<DailyStat, int, QQueryOperations> totalTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTimeSeconds');
    });
  }
}

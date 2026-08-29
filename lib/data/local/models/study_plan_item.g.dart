// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudyPlanItemCollection on Isar {
  IsarCollection<StudyPlanItem> get studyPlanItems => this.collection();
}

const StudyPlanItemSchema = CollectionSchema(
  name: r'StudyPlanItem',
  id: 2762305581201298155,
  properties: {
    r'calendarDay': PropertySchema(
      id: 0,
      name: r'calendarDay',
      type: IsarType.dateTime,
    ),
    r'completedMinutes': PropertySchema(
      id: 1,
      name: r'completedMinutes',
      type: IsarType.long,
    ),
    r'kind': PropertySchema(id: 2, name: r'kind', type: IsarType.string),
    r'plannedMinutes': PropertySchema(
      id: 3,
      name: r'plannedMinutes',
      type: IsarType.long,
    ),
    r'syllabusUuid': PropertySchema(
      id: 4,
      name: r'syllabusUuid',
      type: IsarType.string,
    ),
    r'unitUuid': PropertySchema(
      id: 5,
      name: r'unitUuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 7, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _studyPlanItemEstimateSize,
  serialize: _studyPlanItemSerialize,
  deserialize: _studyPlanItemDeserialize,
  deserializeProp: _studyPlanItemDeserializeProp,
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
    r'calendarDay': IndexSchema(
      id: 3331687902944968284,
      name: r'calendarDay',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'calendarDay',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _studyPlanItemGetId,
  getLinks: _studyPlanItemGetLinks,
  attach: _studyPlanItemAttach,
  version: '3.3.2',
);

int _studyPlanItemEstimateSize(
  StudyPlanItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.syllabusUuid.length * 3;
  {
    final value = object.unitUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _studyPlanItemSerialize(
  StudyPlanItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.calendarDay);
  writer.writeLong(offsets[1], object.completedMinutes);
  writer.writeString(offsets[2], object.kind);
  writer.writeLong(offsets[3], object.plannedMinutes);
  writer.writeString(offsets[4], object.syllabusUuid);
  writer.writeString(offsets[5], object.unitUuid);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeString(offsets[7], object.uuid);
}

StudyPlanItem _studyPlanItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudyPlanItem();
  object.calendarDay = reader.readDateTime(offsets[0]);
  object.completedMinutes = reader.readLong(offsets[1]);
  object.id = id;
  object.kind = reader.readString(offsets[2]);
  object.plannedMinutes = reader.readLong(offsets[3]);
  object.syllabusUuid = reader.readString(offsets[4]);
  object.unitUuid = reader.readStringOrNull(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.uuid = reader.readString(offsets[7]);
  return object;
}

P _studyPlanItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studyPlanItemGetId(StudyPlanItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studyPlanItemGetLinks(StudyPlanItem object) {
  return [];
}

void _studyPlanItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  StudyPlanItem object,
) {
  object.id = id;
}

extension StudyPlanItemByIndex on IsarCollection<StudyPlanItem> {
  Future<StudyPlanItem?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  StudyPlanItem? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<StudyPlanItem?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<StudyPlanItem?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(StudyPlanItem object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(StudyPlanItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<StudyPlanItem> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<StudyPlanItem> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension StudyPlanItemQueryWhereSort
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QWhere> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhere> anyCalendarDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'calendarDay'),
      );
    });
  }
}

extension StudyPlanItemQueryWhere
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QWhereClause> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
  calendarDayEqualTo(DateTime calendarDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'calendarDay',
          value: [calendarDay],
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
  calendarDayNotEqualTo(DateTime calendarDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calendarDay',
                lower: [],
                upper: [calendarDay],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calendarDay',
                lower: [calendarDay],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calendarDay',
                lower: [calendarDay],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'calendarDay',
                lower: [],
                upper: [calendarDay],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
  calendarDayGreaterThan(DateTime calendarDay, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'calendarDay',
          lower: [calendarDay],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
  calendarDayLessThan(DateTime calendarDay, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'calendarDay',
          lower: [],
          upper: [calendarDay],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterWhereClause>
  calendarDayBetween(
    DateTime lowerCalendarDay,
    DateTime upperCalendarDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'calendarDay',
          lower: [lowerCalendarDay],
          includeLower: includeLower,
          upper: [upperCalendarDay],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StudyPlanItemQueryFilter
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QFilterCondition> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  calendarDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calendarDay', value: value),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  calendarDayGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calendarDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  calendarDayLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calendarDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  calendarDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calendarDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  completedMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedMinutes', value: value),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  completedMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  completedMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  completedMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  plannedMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plannedMinutes', value: value),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  plannedMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plannedMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  plannedMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plannedMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  plannedMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plannedMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  syllabusUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  syllabusUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syllabusUuid', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'unitUuid'),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'unitUuid'),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unitUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unitUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unitUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unitUuid', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  unitUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unitUuid', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  uuidLessThan(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension StudyPlanItemQueryObject
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QFilterCondition> {}

extension StudyPlanItemQueryLinks
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QFilterCondition> {}

extension StudyPlanItemQuerySortBy
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QSortBy> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByCalendarDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarDay', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByCalendarDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarDay', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedMinutes', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByCompletedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedMinutes', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByPlannedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedMinutes', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByPlannedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedMinutes', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByUnitUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitUuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByUnitUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitUuid', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension StudyPlanItemQuerySortThenBy
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QSortThenBy> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByCalendarDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarDay', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByCalendarDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarDay', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedMinutes', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByCompletedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedMinutes', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByPlannedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedMinutes', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByPlannedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedMinutes', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenBySyllabusUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenBySyllabusUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusUuid', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByUnitUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitUuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByUnitUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitUuid', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension StudyPlanItemQueryWhereDistinct
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> {
  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct>
  distinctByCalendarDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calendarDay');
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct>
  distinctByCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedMinutes');
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> distinctByKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct>
  distinctByPlannedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedMinutes');
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> distinctBySyllabusUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syllabusUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> distinctByUnitUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<StudyPlanItem, StudyPlanItem, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension StudyPlanItemQueryProperty
    on QueryBuilder<StudyPlanItem, StudyPlanItem, QQueryProperty> {
  QueryBuilder<StudyPlanItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudyPlanItem, DateTime, QQueryOperations>
  calendarDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calendarDay');
    });
  }

  QueryBuilder<StudyPlanItem, int, QQueryOperations>
  completedMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedMinutes');
    });
  }

  QueryBuilder<StudyPlanItem, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<StudyPlanItem, int, QQueryOperations> plannedMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedMinutes');
    });
  }

  QueryBuilder<StudyPlanItem, String, QQueryOperations> syllabusUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syllabusUuid');
    });
  }

  QueryBuilder<StudyPlanItem, String?, QQueryOperations> unitUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitUuid');
    });
  }

  QueryBuilder<StudyPlanItem, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<StudyPlanItem, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}

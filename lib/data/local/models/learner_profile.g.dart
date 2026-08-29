// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learner_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLearnerProfileCollection on Isar {
  IsarCollection<LearnerProfile> get learnerProfiles => this.collection();
}

const LearnerProfileSchema = CollectionSchema(
  name: r'LearnerProfile',
  id: -2197453568607155748,
  properties: {
    r'dailyMinutesGoal': PropertySchema(
      id: 0,
      name: r'dailyMinutesGoal',
      type: IsarType.long,
    ),
    r'density': PropertySchema(id: 1, name: r'density', type: IsarType.string),
    r'examDate': PropertySchema(
      id: 2,
      name: r'examDate',
      type: IsarType.dateTime,
    ),
    r'examType': PropertySchema(
      id: 3,
      name: r'examType',
      type: IsarType.string,
    ),
    r'goalContext': PropertySchema(
      id: 4,
      name: r'goalContext',
      type: IsarType.string,
    ),
    r'goalMode': PropertySchema(
      id: 5,
      name: r'goalMode',
      type: IsarType.string,
    ),
    r'goalsJson': PropertySchema(
      id: 6,
      name: r'goalsJson',
      type: IsarType.string,
    ),
    r'helpImproveOptIn': PropertySchema(
      id: 7,
      name: r'helpImproveOptIn',
      type: IsarType.bool,
    ),
    r'lastLayoutChangeAt': PropertySchema(
      id: 8,
      name: r'lastLayoutChangeAt',
      type: IsarType.dateTime,
    ),
    r'layoutMode': PropertySchema(
      id: 9,
      name: r'layoutMode',
      type: IsarType.string,
    ),
    r'layoutModeOverride': PropertySchema(
      id: 10,
      name: r'layoutModeOverride',
      type: IsarType.string,
    ),
    r'navAffinityJson': PropertySchema(
      id: 11,
      name: r'navAffinityJson',
      type: IsarType.string,
    ),
    r'navOrderJson': PropertySchema(
      id: 12,
      name: r'navOrderJson',
      type: IsarType.string,
    ),
    r'preferredFormatsJson': PropertySchema(
      id: 13,
      name: r'preferredFormatsJson',
      type: IsarType.string,
    ),
    r'roleSeniority': PropertySchema(
      id: 14,
      name: r'roleSeniority',
      type: IsarType.string,
    ),
    r'skillLevel': PropertySchema(
      id: 15,
      name: r'skillLevel',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _learnerProfileEstimateSize,
  serialize: _learnerProfileSerialize,
  deserialize: _learnerProfileDeserialize,
  deserializeProp: _learnerProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _learnerProfileGetId,
  getLinks: _learnerProfileGetLinks,
  attach: _learnerProfileAttach,
  version: '3.3.2',
);

int _learnerProfileEstimateSize(
  LearnerProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.density.length * 3;
  {
    final value = object.examType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.goalContext.length * 3;
  bytesCount += 3 + object.goalMode.length * 3;
  bytesCount += 3 + object.goalsJson.length * 3;
  bytesCount += 3 + object.layoutMode.length * 3;
  bytesCount += 3 + object.layoutModeOverride.length * 3;
  bytesCount += 3 + object.navAffinityJson.length * 3;
  bytesCount += 3 + object.navOrderJson.length * 3;
  bytesCount += 3 + object.preferredFormatsJson.length * 3;
  {
    final value = object.roleSeniority;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _learnerProfileSerialize(
  LearnerProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dailyMinutesGoal);
  writer.writeString(offsets[1], object.density);
  writer.writeDateTime(offsets[2], object.examDate);
  writer.writeString(offsets[3], object.examType);
  writer.writeString(offsets[4], object.goalContext);
  writer.writeString(offsets[5], object.goalMode);
  writer.writeString(offsets[6], object.goalsJson);
  writer.writeBool(offsets[7], object.helpImproveOptIn);
  writer.writeDateTime(offsets[8], object.lastLayoutChangeAt);
  writer.writeString(offsets[9], object.layoutMode);
  writer.writeString(offsets[10], object.layoutModeOverride);
  writer.writeString(offsets[11], object.navAffinityJson);
  writer.writeString(offsets[12], object.navOrderJson);
  writer.writeString(offsets[13], object.preferredFormatsJson);
  writer.writeString(offsets[14], object.roleSeniority);
  writer.writeDouble(offsets[15], object.skillLevel);
  writer.writeDateTime(offsets[16], object.updatedAt);
}

LearnerProfile _learnerProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LearnerProfile();
  object.dailyMinutesGoal = reader.readLongOrNull(offsets[0]);
  object.density = reader.readString(offsets[1]);
  object.examDate = reader.readDateTimeOrNull(offsets[2]);
  object.examType = reader.readStringOrNull(offsets[3]);
  object.goalContext = reader.readString(offsets[4]);
  object.goalMode = reader.readString(offsets[5]);
  object.goalsJson = reader.readString(offsets[6]);
  object.helpImproveOptIn = reader.readBool(offsets[7]);
  object.id = id;
  object.lastLayoutChangeAt = reader.readDateTimeOrNull(offsets[8]);
  object.layoutMode = reader.readString(offsets[9]);
  object.layoutModeOverride = reader.readString(offsets[10]);
  object.navAffinityJson = reader.readString(offsets[11]);
  object.navOrderJson = reader.readString(offsets[12]);
  object.preferredFormatsJson = reader.readString(offsets[13]);
  object.roleSeniority = reader.readStringOrNull(offsets[14]);
  object.skillLevel = reader.readDouble(offsets[15]);
  object.updatedAt = reader.readDateTime(offsets[16]);
  return object;
}

P _learnerProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _learnerProfileGetId(LearnerProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _learnerProfileGetLinks(LearnerProfile object) {
  return [];
}

void _learnerProfileAttach(
  IsarCollection<dynamic> col,
  Id id,
  LearnerProfile object,
) {
  object.id = id;
}

extension LearnerProfileQueryWhereSort
    on QueryBuilder<LearnerProfile, LearnerProfile, QWhere> {
  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LearnerProfileQueryWhere
    on QueryBuilder<LearnerProfile, LearnerProfile, QWhereClause> {
  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterWhereClause> idBetween(
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

extension LearnerProfileQueryFilter
    on QueryBuilder<LearnerProfile, LearnerProfile, QFilterCondition> {
  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dailyMinutesGoal'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dailyMinutesGoal'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dailyMinutesGoal', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyMinutesGoal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyMinutesGoal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  dailyMinutesGoalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyMinutesGoal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'density',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'density',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'density',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'density', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  densityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'density', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'examDate'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'examDate'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'examDate', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'examDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'examDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'examDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'examType'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'examType'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'examType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'examType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'examType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'examType', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  examTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'examType', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalContext',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'goalContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'goalContext',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalContext', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalContext', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeGreaterThan(
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeLessThan(
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeBetween(
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'goalsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'goalsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalsJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  goalsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalsJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  helpImproveOptInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'helpImproveOptIn', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastLayoutChangeAt'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastLayoutChangeAt'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastLayoutChangeAt', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastLayoutChangeAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastLayoutChangeAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  lastLayoutChangeAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastLayoutChangeAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'layoutMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'layoutMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'layoutMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'layoutMode', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'layoutMode', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'layoutModeOverride',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'layoutModeOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'layoutModeOverride',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'layoutModeOverride', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  layoutModeOverrideIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'layoutModeOverride', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'navAffinityJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'navAffinityJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'navAffinityJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'navAffinityJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navAffinityJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'navAffinityJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'navOrderJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'navOrderJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'navOrderJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'navOrderJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  navOrderJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'navOrderJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preferredFormatsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'preferredFormatsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'preferredFormatsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preferredFormatsJson', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  preferredFormatsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'preferredFormatsJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'roleSeniority'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'roleSeniority'),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'roleSeniority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'roleSeniority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'roleSeniority',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'roleSeniority', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  roleSeniorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'roleSeniority', value: ''),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  skillLevelEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'skillLevel',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  skillLevelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'skillLevel',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  skillLevelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'skillLevel',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  skillLevelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'skillLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
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

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterFilterCondition>
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
}

extension LearnerProfileQueryObject
    on QueryBuilder<LearnerProfile, LearnerProfile, QFilterCondition> {}

extension LearnerProfileQueryLinks
    on QueryBuilder<LearnerProfile, LearnerProfile, QFilterCondition> {}

extension LearnerProfileQuerySortBy
    on QueryBuilder<LearnerProfile, LearnerProfile, QSortBy> {
  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByDailyMinutesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyMinutesGoal', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByDailyMinutesGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyMinutesGoal', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'density', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'density', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByGoalContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalContext', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByGoalContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalContext', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByGoalsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByGoalsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByHelpImproveOptIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'helpImproveOptIn', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByHelpImproveOptInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'helpImproveOptIn', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLastLayoutChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLayoutChangeAt', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLastLayoutChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLayoutChangeAt', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLayoutMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutMode', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLayoutModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutMode', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLayoutModeOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutModeOverride', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByLayoutModeOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutModeOverride', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByNavAffinityJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navAffinityJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByNavAffinityJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navAffinityJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByNavOrderJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navOrderJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByNavOrderJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navOrderJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByPreferredFormatsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredFormatsJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByPreferredFormatsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredFormatsJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByRoleSeniority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleSeniority', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByRoleSeniorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleSeniority', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortBySkillLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skillLevel', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortBySkillLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skillLevel', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LearnerProfileQuerySortThenBy
    on QueryBuilder<LearnerProfile, LearnerProfile, QSortThenBy> {
  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByDailyMinutesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyMinutesGoal', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByDailyMinutesGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyMinutesGoal', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'density', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'density', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByGoalContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalContext', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByGoalContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalContext', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByGoalsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByGoalsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByHelpImproveOptIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'helpImproveOptIn', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByHelpImproveOptInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'helpImproveOptIn', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLastLayoutChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLayoutChangeAt', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLastLayoutChangeAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLayoutChangeAt', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLayoutMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutMode', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLayoutModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutMode', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLayoutModeOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutModeOverride', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByLayoutModeOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutModeOverride', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByNavAffinityJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navAffinityJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByNavAffinityJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navAffinityJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByNavOrderJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navOrderJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByNavOrderJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'navOrderJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByPreferredFormatsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredFormatsJson', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByPreferredFormatsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredFormatsJson', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByRoleSeniority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleSeniority', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByRoleSeniorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleSeniority', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenBySkillLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skillLevel', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenBySkillLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skillLevel', Sort.desc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LearnerProfileQueryWhereDistinct
    on QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> {
  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByDailyMinutesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyMinutesGoal');
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByDensity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'density', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examDate');
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByExamType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByGoalContext({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalContext', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByGoalMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByGoalsJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByHelpImproveOptIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'helpImproveOptIn');
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByLastLayoutChangeAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLayoutChangeAt');
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct> distinctByLayoutMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'layoutMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByLayoutModeOverride({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'layoutModeOverride',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByNavAffinityJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'navAffinityJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByNavOrderJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'navOrderJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByPreferredFormatsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'preferredFormatsJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByRoleSeniority({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'roleSeniority',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctBySkillLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skillLevel');
    });
  }

  QueryBuilder<LearnerProfile, LearnerProfile, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LearnerProfileQueryProperty
    on QueryBuilder<LearnerProfile, LearnerProfile, QQueryProperty> {
  QueryBuilder<LearnerProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LearnerProfile, int?, QQueryOperations>
  dailyMinutesGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyMinutesGoal');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations> densityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'density');
    });
  }

  QueryBuilder<LearnerProfile, DateTime?, QQueryOperations> examDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examDate');
    });
  }

  QueryBuilder<LearnerProfile, String?, QQueryOperations> examTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examType');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations> goalContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalContext');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations> goalModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalMode');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations> goalsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalsJson');
    });
  }

  QueryBuilder<LearnerProfile, bool, QQueryOperations>
  helpImproveOptInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'helpImproveOptIn');
    });
  }

  QueryBuilder<LearnerProfile, DateTime?, QQueryOperations>
  lastLayoutChangeAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLayoutChangeAt');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations> layoutModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layoutMode');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations>
  layoutModeOverrideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layoutModeOverride');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations>
  navAffinityJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'navAffinityJson');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations>
  navOrderJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'navOrderJson');
    });
  }

  QueryBuilder<LearnerProfile, String, QQueryOperations>
  preferredFormatsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredFormatsJson');
    });
  }

  QueryBuilder<LearnerProfile, String?, QQueryOperations>
  roleSeniorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleSeniority');
    });
  }

  QueryBuilder<LearnerProfile, double, QQueryOperations> skillLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skillLevel');
    });
  }

  QueryBuilder<LearnerProfile, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

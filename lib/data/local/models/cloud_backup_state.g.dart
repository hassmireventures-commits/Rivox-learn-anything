// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_backup_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCloudBackupStateCollection on Isar {
  IsarCollection<CloudBackupState> get cloudBackupStates => this.collection();
}

const CloudBackupStateSchema = CollectionSchema(
  name: r'CloudBackupState',
  id: 1488992957838892964,
  properties: {
    r'enabled': PropertySchema(id: 0, name: r'enabled', type: IsarType.bool),
    r'kdfIterations': PropertySchema(
      id: 1,
      name: r'kdfIterations',
      type: IsarType.long,
    ),
    r'kdfSaltBase64': PropertySchema(
      id: 2,
      name: r'kdfSaltBase64',
      type: IsarType.string,
    ),
    r'lastBackupAt': PropertySchema(
      id: 3,
      name: r'lastBackupAt',
      type: IsarType.dateTime,
    ),
    r'lastBackupSizeBytes': PropertySchema(
      id: 4,
      name: r'lastBackupSizeBytes',
      type: IsarType.long,
    ),
    r'lastRestoreAt': PropertySchema(
      id: 5,
      name: r'lastRestoreAt',
      type: IsarType.dateTime,
    ),
    r'linkedUid': PropertySchema(
      id: 6,
      name: r'linkedUid',
      type: IsarType.string,
    ),
  },

  estimateSize: _cloudBackupStateEstimateSize,
  serialize: _cloudBackupStateSerialize,
  deserialize: _cloudBackupStateDeserialize,
  deserializeProp: _cloudBackupStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _cloudBackupStateGetId,
  getLinks: _cloudBackupStateGetLinks,
  attach: _cloudBackupStateAttach,
  version: '3.3.2',
);

int _cloudBackupStateEstimateSize(
  CloudBackupState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.kdfSaltBase64;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cloudBackupStateSerialize(
  CloudBackupState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeLong(offsets[1], object.kdfIterations);
  writer.writeString(offsets[2], object.kdfSaltBase64);
  writer.writeDateTime(offsets[3], object.lastBackupAt);
  writer.writeLong(offsets[4], object.lastBackupSizeBytes);
  writer.writeDateTime(offsets[5], object.lastRestoreAt);
  writer.writeString(offsets[6], object.linkedUid);
}

CloudBackupState _cloudBackupStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CloudBackupState();
  object.enabled = reader.readBool(offsets[0]);
  object.id = id;
  object.kdfIterations = reader.readLongOrNull(offsets[1]);
  object.kdfSaltBase64 = reader.readStringOrNull(offsets[2]);
  object.lastBackupAt = reader.readDateTimeOrNull(offsets[3]);
  object.lastBackupSizeBytes = reader.readLongOrNull(offsets[4]);
  object.lastRestoreAt = reader.readDateTimeOrNull(offsets[5]);
  object.linkedUid = reader.readStringOrNull(offsets[6]);
  return object;
}

P _cloudBackupStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cloudBackupStateGetId(CloudBackupState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cloudBackupStateGetLinks(CloudBackupState object) {
  return [];
}

void _cloudBackupStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  CloudBackupState object,
) {
  object.id = id;
}

extension CloudBackupStateQueryWhereSort
    on QueryBuilder<CloudBackupState, CloudBackupState, QWhere> {
  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CloudBackupStateQueryWhere
    on QueryBuilder<CloudBackupState, CloudBackupState, QWhereClause> {
  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterWhereClause> idBetween(
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

extension CloudBackupStateQueryFilter
    on QueryBuilder<CloudBackupState, CloudBackupState, QFilterCondition> {
  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
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

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
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

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'kdfIterations'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'kdfIterations'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdfIterations', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdfIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdfIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfIterationsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdfIterations',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'kdfSaltBase64'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'kdfSaltBase64'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64EqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kdfSaltBase64',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kdfSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kdfSaltBase64',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kdfSaltBase64', value: ''),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  kdfSaltBase64IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kdfSaltBase64', value: ''),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastBackupAt'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastBackupAt'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastBackupAt', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastBackupAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastBackupAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastBackupAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastBackupSizeBytes'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastBackupSizeBytes'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastBackupSizeBytes', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastBackupSizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastBackupSizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastBackupSizeBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastBackupSizeBytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastRestoreAt'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastRestoreAt'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRestoreAt', value: value),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRestoreAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRestoreAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  lastRestoreAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRestoreAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedUid'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedUid'),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedUid', value: ''),
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterFilterCondition>
  linkedUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedUid', value: ''),
      );
    });
  }
}

extension CloudBackupStateQueryObject
    on QueryBuilder<CloudBackupState, CloudBackupState, QFilterCondition> {}

extension CloudBackupStateQueryLinks
    on QueryBuilder<CloudBackupState, CloudBackupState, QFilterCondition> {}

extension CloudBackupStateQuerySortBy
    on QueryBuilder<CloudBackupState, CloudBackupState, QSortBy> {
  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByKdfIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByKdfSaltBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfSaltBase64', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByKdfSaltBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfSaltBase64', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastBackupSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastBackupSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastRestoreAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRestoreAt', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLastRestoreAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRestoreAt', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLinkedUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUid', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  sortByLinkedUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUid', Sort.desc);
    });
  }
}

extension CloudBackupStateQuerySortThenBy
    on QueryBuilder<CloudBackupState, CloudBackupState, QSortThenBy> {
  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByKdfIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfIterations', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByKdfSaltBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfSaltBase64', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByKdfSaltBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kdfSaltBase64', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastBackupSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastBackupSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastRestoreAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRestoreAt', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLastRestoreAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRestoreAt', Sort.desc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLinkedUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUid', Sort.asc);
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QAfterSortBy>
  thenByLinkedUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUid', Sort.desc);
    });
  }
}

extension CloudBackupStateQueryWhereDistinct
    on QueryBuilder<CloudBackupState, CloudBackupState, QDistinct> {
  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByKdfIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kdfIterations');
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByKdfSaltBase64({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'kdfSaltBase64',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupAt');
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByLastBackupSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupSizeBytes');
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByLastRestoreAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRestoreAt');
    });
  }

  QueryBuilder<CloudBackupState, CloudBackupState, QDistinct>
  distinctByLinkedUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedUid', caseSensitive: caseSensitive);
    });
  }
}

extension CloudBackupStateQueryProperty
    on QueryBuilder<CloudBackupState, CloudBackupState, QQueryProperty> {
  QueryBuilder<CloudBackupState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CloudBackupState, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<CloudBackupState, int?, QQueryOperations>
  kdfIterationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdfIterations');
    });
  }

  QueryBuilder<CloudBackupState, String?, QQueryOperations>
  kdfSaltBase64Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kdfSaltBase64');
    });
  }

  QueryBuilder<CloudBackupState, DateTime?, QQueryOperations>
  lastBackupAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupAt');
    });
  }

  QueryBuilder<CloudBackupState, int?, QQueryOperations>
  lastBackupSizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupSizeBytes');
    });
  }

  QueryBuilder<CloudBackupState, DateTime?, QQueryOperations>
  lastRestoreAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRestoreAt');
    });
  }

  QueryBuilder<CloudBackupState, String?, QQueryOperations>
  linkedUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedUid');
    });
  }
}

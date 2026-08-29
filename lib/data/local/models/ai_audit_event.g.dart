// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_audit_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAiAuditEventCollection on Isar {
  IsarCollection<AiAuditEvent> get aiAuditEvents => this.collection();
}

const AiAuditEventSchema = CollectionSchema(
  name: r'AiAuditEvent',
  id: 1413299660973175676,
  properties: {
    r'completionTokens': PropertySchema(
      id: 0,
      name: r'completionTokens',
      type: IsarType.long,
    ),
    r'errorMessage': PropertySchema(
      id: 1,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'latencyMs': PropertySchema(
      id: 2,
      name: r'latencyMs',
      type: IsarType.long,
    ),
    r'policyVersion': PropertySchema(
      id: 3,
      name: r'policyVersion',
      type: IsarType.string,
    ),
    r'promptTokens': PropertySchema(
      id: 4,
      name: r'promptTokens',
      type: IsarType.long,
    ),
    r'providerKey': PropertySchema(
      id: 5,
      name: r'providerKey',
      type: IsarType.string,
    ),
    r'ragChunkIdsJson': PropertySchema(
      id: 6,
      name: r'ragChunkIdsJson',
      type: IsarType.string,
    ),
    r'strategyId': PropertySchema(
      id: 7,
      name: r'strategyId',
      type: IsarType.string,
    ),
    r'success': PropertySchema(id: 8, name: r'success', type: IsarType.bool),
    r'task': PropertySchema(id: 9, name: r'task', type: IsarType.string),
    r'timestamp': PropertySchema(
      id: 10,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _aiAuditEventEstimateSize,
  serialize: _aiAuditEventSerialize,
  deserialize: _aiAuditEventDeserialize,
  deserializeProp: _aiAuditEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'task': IndexSchema(
      id: 4607462848387024586,
      name: r'task',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'task',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _aiAuditEventGetId,
  getLinks: _aiAuditEventGetLinks,
  attach: _aiAuditEventAttach,
  version: '3.3.2',
);

int _aiAuditEventEstimateSize(
  AiAuditEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.policyVersion.length * 3;
  bytesCount += 3 + object.providerKey.length * 3;
  {
    final value = object.ragChunkIdsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.strategyId.length * 3;
  bytesCount += 3 + object.task.length * 3;
  return bytesCount;
}

void _aiAuditEventSerialize(
  AiAuditEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completionTokens);
  writer.writeString(offsets[1], object.errorMessage);
  writer.writeLong(offsets[2], object.latencyMs);
  writer.writeString(offsets[3], object.policyVersion);
  writer.writeLong(offsets[4], object.promptTokens);
  writer.writeString(offsets[5], object.providerKey);
  writer.writeString(offsets[6], object.ragChunkIdsJson);
  writer.writeString(offsets[7], object.strategyId);
  writer.writeBool(offsets[8], object.success);
  writer.writeString(offsets[9], object.task);
  writer.writeDateTime(offsets[10], object.timestamp);
}

AiAuditEvent _aiAuditEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AiAuditEvent();
  object.completionTokens = reader.readLong(offsets[0]);
  object.errorMessage = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.latencyMs = reader.readLong(offsets[2]);
  object.policyVersion = reader.readString(offsets[3]);
  object.promptTokens = reader.readLong(offsets[4]);
  object.providerKey = reader.readString(offsets[5]);
  object.ragChunkIdsJson = reader.readStringOrNull(offsets[6]);
  object.strategyId = reader.readString(offsets[7]);
  object.success = reader.readBool(offsets[8]);
  object.task = reader.readString(offsets[9]);
  object.timestamp = reader.readDateTime(offsets[10]);
  return object;
}

P _aiAuditEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _aiAuditEventGetId(AiAuditEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aiAuditEventGetLinks(AiAuditEvent object) {
  return [];
}

void _aiAuditEventAttach(
  IsarCollection<dynamic> col,
  Id id,
  AiAuditEvent object,
) {
  object.id = id;
}

extension AiAuditEventQueryWhereSort
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QWhere> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension AiAuditEventQueryWhere
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QWhereClause> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> idBetween(
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> taskEqualTo(
    String task,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'task', value: [task]),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> taskNotEqualTo(
    String task,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'task',
                lower: [],
                upper: [task],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'task',
                lower: [task],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'task',
                lower: [task],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'task',
                lower: [],
                upper: [task],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> timestampEqualTo(
    DateTime timestamp,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause>
  timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause>
  timestampGreaterThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AiAuditEventQueryFilter
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QFilterCondition> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  completionTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completionTokens', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'errorMessage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'errorMessage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  latencyMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'latencyMs', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  latencyMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  latencyMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latencyMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  latencyMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latencyMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'policyVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'policyVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'policyVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'policyVersion', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  policyVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'policyVersion', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  promptTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'promptTokens', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  providerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'providerKey', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  providerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'providerKey', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ragChunkIdsJson'),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ragChunkIdsJson'),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ragChunkIdsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ragChunkIdsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ragChunkIdsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ragChunkIdsJson', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  ragChunkIdsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ragChunkIdsJson', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  strategyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'strategyId', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  strategyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'strategyId', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  successEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'success', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  taskGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'task',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  taskStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'task',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition> taskMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'task',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  taskIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'task', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  taskIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'task', value: ''),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterFilterCondition>
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

extension AiAuditEventQueryObject
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QFilterCondition> {}

extension AiAuditEventQueryLinks
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QFilterCondition> {}

extension AiAuditEventQuerySortBy
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QSortBy> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByPolicyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByPolicyVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByRagChunkIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragChunkIdsJson', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByRagChunkIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragChunkIdsJson', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByStrategyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  sortByStrategyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortBySuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'success', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortBySuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'success', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AiAuditEventQuerySortThenBy
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QSortThenBy> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByCompletionTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionTokens', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByLatencyMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latencyMs', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByPolicyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByPolicyVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByPromptTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'promptTokens', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByRagChunkIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragChunkIdsJson', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByRagChunkIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragChunkIdsJson', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByStrategyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy>
  thenByStrategyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strategyId', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenBySuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'success', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenBySuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'success', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AiAuditEventQueryWhereDistinct
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> {
  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct>
  distinctByCompletionTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionTokens');
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByErrorMessage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByLatencyMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latencyMs');
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByPolicyVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'policyVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByPromptTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'promptTokens');
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByProviderKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct>
  distinctByRagChunkIdsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'ragChunkIdsJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByStrategyId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strategyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctBySuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'success');
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByTask({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'task', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiAuditEvent, AiAuditEvent, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension AiAuditEventQueryProperty
    on QueryBuilder<AiAuditEvent, AiAuditEvent, QQueryProperty> {
  QueryBuilder<AiAuditEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AiAuditEvent, int, QQueryOperations> completionTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionTokens');
    });
  }

  QueryBuilder<AiAuditEvent, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<AiAuditEvent, int, QQueryOperations> latencyMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latencyMs');
    });
  }

  QueryBuilder<AiAuditEvent, String, QQueryOperations> policyVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyVersion');
    });
  }

  QueryBuilder<AiAuditEvent, int, QQueryOperations> promptTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptTokens');
    });
  }

  QueryBuilder<AiAuditEvent, String, QQueryOperations> providerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerKey');
    });
  }

  QueryBuilder<AiAuditEvent, String?, QQueryOperations>
  ragChunkIdsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ragChunkIdsJson');
    });
  }

  QueryBuilder<AiAuditEvent, String, QQueryOperations> strategyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strategyId');
    });
  }

  QueryBuilder<AiAuditEvent, bool, QQueryOperations> successProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'success');
    });
  }

  QueryBuilder<AiAuditEvent, String, QQueryOperations> taskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'task');
    });
  }

  QueryBuilder<AiAuditEvent, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}

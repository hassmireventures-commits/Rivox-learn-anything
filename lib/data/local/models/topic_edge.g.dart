// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_edge.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTopicEdgeCollection on Isar {
  IsarCollection<TopicEdge> get topicEdges => this.collection();
}

const TopicEdgeSchema = CollectionSchema(
  name: r'TopicEdge',
  id: -181012847402151482,
  properties: {
    r'fromTopic': PropertySchema(
      id: 0,
      name: r'fromTopic',
      type: IsarType.string,
    ),
    r'relation': PropertySchema(
      id: 1,
      name: r'relation',
      type: IsarType.string,
    ),
    r'toTopic': PropertySchema(id: 2, name: r'toTopic', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weight': PropertySchema(id: 4, name: r'weight', type: IsarType.double),
  },

  estimateSize: _topicEdgeEstimateSize,
  serialize: _topicEdgeSerialize,
  deserialize: _topicEdgeDeserialize,
  deserializeProp: _topicEdgeDeserializeProp,
  idName: r'id',
  indexes: {
    r'fromTopic': IndexSchema(
      id: -1354997296702288498,
      name: r'fromTopic',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fromTopic',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'toTopic': IndexSchema(
      id: -7833117929020184172,
      name: r'toTopic',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'toTopic',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _topicEdgeGetId,
  getLinks: _topicEdgeGetLinks,
  attach: _topicEdgeAttach,
  version: '3.3.2',
);

int _topicEdgeEstimateSize(
  TopicEdge object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fromTopic.length * 3;
  bytesCount += 3 + object.relation.length * 3;
  bytesCount += 3 + object.toTopic.length * 3;
  return bytesCount;
}

void _topicEdgeSerialize(
  TopicEdge object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fromTopic);
  writer.writeString(offsets[1], object.relation);
  writer.writeString(offsets[2], object.toTopic);
  writer.writeDateTime(offsets[3], object.updatedAt);
  writer.writeDouble(offsets[4], object.weight);
}

TopicEdge _topicEdgeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TopicEdge();
  object.fromTopic = reader.readString(offsets[0]);
  object.id = id;
  object.relation = reader.readString(offsets[1]);
  object.toTopic = reader.readString(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  object.weight = reader.readDouble(offsets[4]);
  return object;
}

P _topicEdgeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _topicEdgeGetId(TopicEdge object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _topicEdgeGetLinks(TopicEdge object) {
  return [];
}

void _topicEdgeAttach(IsarCollection<dynamic> col, Id id, TopicEdge object) {
  object.id = id;
}

extension TopicEdgeQueryWhereSort
    on QueryBuilder<TopicEdge, TopicEdge, QWhere> {
  QueryBuilder<TopicEdge, TopicEdge, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TopicEdgeQueryWhere
    on QueryBuilder<TopicEdge, TopicEdge, QWhereClause> {
  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> idBetween(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> fromTopicEqualTo(
    String fromTopic,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fromTopic', value: [fromTopic]),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> fromTopicNotEqualTo(
    String fromTopic,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromTopic',
                lower: [],
                upper: [fromTopic],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromTopic',
                lower: [fromTopic],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromTopic',
                lower: [fromTopic],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fromTopic',
                lower: [],
                upper: [fromTopic],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> toTopicEqualTo(
    String toTopic,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'toTopic', value: [toTopic]),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterWhereClause> toTopicNotEqualTo(
    String toTopic,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toTopic',
                lower: [],
                upper: [toTopic],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toTopic',
                lower: [toTopic],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toTopic',
                lower: [toTopic],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'toTopic',
                lower: [],
                upper: [toTopic],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TopicEdgeQueryFilter
    on QueryBuilder<TopicEdge, TopicEdge, QFilterCondition> {
  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition>
  fromTopicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fromTopic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fromTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fromTopic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> fromTopicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fromTopic', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition>
  fromTopicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fromTopic', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'relation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'relation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'relation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> relationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'relation', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition>
  relationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'relation', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'toTopic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'toTopic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'toTopic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> toTopicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'toTopic', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition>
  toTopicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'toTopic', value: ''),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition>
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> weightEqualTo(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> weightGreaterThan(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> weightLessThan(
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

  QueryBuilder<TopicEdge, TopicEdge, QAfterFilterCondition> weightBetween(
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

extension TopicEdgeQueryObject
    on QueryBuilder<TopicEdge, TopicEdge, QFilterCondition> {}

extension TopicEdgeQueryLinks
    on QueryBuilder<TopicEdge, TopicEdge, QFilterCondition> {}

extension TopicEdgeQuerySortBy on QueryBuilder<TopicEdge, TopicEdge, QSortBy> {
  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByFromTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromTopic', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByFromTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromTopic', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByRelation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relation', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByRelationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relation', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByToTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toTopic', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByToTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toTopic', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension TopicEdgeQuerySortThenBy
    on QueryBuilder<TopicEdge, TopicEdge, QSortThenBy> {
  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByFromTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromTopic', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByFromTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromTopic', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByRelation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relation', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByRelationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relation', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByToTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toTopic', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByToTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toTopic', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension TopicEdgeQueryWhereDistinct
    on QueryBuilder<TopicEdge, TopicEdge, QDistinct> {
  QueryBuilder<TopicEdge, TopicEdge, QDistinct> distinctByFromTopic({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromTopic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QDistinct> distinctByRelation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QDistinct> distinctByToTopic({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toTopic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TopicEdge, TopicEdge, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension TopicEdgeQueryProperty
    on QueryBuilder<TopicEdge, TopicEdge, QQueryProperty> {
  QueryBuilder<TopicEdge, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TopicEdge, String, QQueryOperations> fromTopicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromTopic');
    });
  }

  QueryBuilder<TopicEdge, String, QQueryOperations> relationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relation');
    });
  }

  QueryBuilder<TopicEdge, String, QQueryOperations> toTopicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toTopic');
    });
  }

  QueryBuilder<TopicEdge, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TopicEdge, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

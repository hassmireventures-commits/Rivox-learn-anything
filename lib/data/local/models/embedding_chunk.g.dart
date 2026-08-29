// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_chunk.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmbeddingChunkCollection on Isar {
  IsarCollection<EmbeddingChunk> get embeddingChunks => this.collection();
}

const EmbeddingChunkSchema = CollectionSchema(
  name: r'EmbeddingChunk',
  id: -2642870005951303037,
  properties: {
    r'chunkId': PropertySchema(id: 0, name: r'chunkId', type: IsarType.string),
    r'topic': PropertySchema(id: 1, name: r'topic', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 2,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vectorJson': PropertySchema(
      id: 3,
      name: r'vectorJson',
      type: IsarType.string,
    ),
  },

  estimateSize: _embeddingChunkEstimateSize,
  serialize: _embeddingChunkSerialize,
  deserialize: _embeddingChunkDeserialize,
  deserializeProp: _embeddingChunkDeserializeProp,
  idName: r'id',
  indexes: {
    r'chunkId': IndexSchema(
      id: 7020861766424886656,
      name: r'chunkId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chunkId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _embeddingChunkGetId,
  getLinks: _embeddingChunkGetLinks,
  attach: _embeddingChunkAttach,
  version: '3.3.2',
);

int _embeddingChunkEstimateSize(
  EmbeddingChunk object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chunkId.length * 3;
  bytesCount += 3 + object.topic.length * 3;
  bytesCount += 3 + object.vectorJson.length * 3;
  return bytesCount;
}

void _embeddingChunkSerialize(
  EmbeddingChunk object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chunkId);
  writer.writeString(offsets[1], object.topic);
  writer.writeDateTime(offsets[2], object.updatedAt);
  writer.writeString(offsets[3], object.vectorJson);
}

EmbeddingChunk _embeddingChunkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmbeddingChunk();
  object.chunkId = reader.readString(offsets[0]);
  object.id = id;
  object.topic = reader.readString(offsets[1]);
  object.updatedAt = reader.readDateTime(offsets[2]);
  object.vectorJson = reader.readString(offsets[3]);
  return object;
}

P _embeddingChunkDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _embeddingChunkGetId(EmbeddingChunk object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _embeddingChunkGetLinks(EmbeddingChunk object) {
  return [];
}

void _embeddingChunkAttach(
  IsarCollection<dynamic> col,
  Id id,
  EmbeddingChunk object,
) {
  object.id = id;
}

extension EmbeddingChunkByIndex on IsarCollection<EmbeddingChunk> {
  Future<EmbeddingChunk?> getByChunkId(String chunkId) {
    return getByIndex(r'chunkId', [chunkId]);
  }

  EmbeddingChunk? getByChunkIdSync(String chunkId) {
    return getByIndexSync(r'chunkId', [chunkId]);
  }

  Future<bool> deleteByChunkId(String chunkId) {
    return deleteByIndex(r'chunkId', [chunkId]);
  }

  bool deleteByChunkIdSync(String chunkId) {
    return deleteByIndexSync(r'chunkId', [chunkId]);
  }

  Future<List<EmbeddingChunk?>> getAllByChunkId(List<String> chunkIdValues) {
    final values = chunkIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'chunkId', values);
  }

  List<EmbeddingChunk?> getAllByChunkIdSync(List<String> chunkIdValues) {
    final values = chunkIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'chunkId', values);
  }

  Future<int> deleteAllByChunkId(List<String> chunkIdValues) {
    final values = chunkIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'chunkId', values);
  }

  int deleteAllByChunkIdSync(List<String> chunkIdValues) {
    final values = chunkIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'chunkId', values);
  }

  Future<Id> putByChunkId(EmbeddingChunk object) {
    return putByIndex(r'chunkId', object);
  }

  Id putByChunkIdSync(EmbeddingChunk object, {bool saveLinks = true}) {
    return putByIndexSync(r'chunkId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChunkId(List<EmbeddingChunk> objects) {
    return putAllByIndex(r'chunkId', objects);
  }

  List<Id> putAllByChunkIdSync(
    List<EmbeddingChunk> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'chunkId', objects, saveLinks: saveLinks);
  }
}

extension EmbeddingChunkQueryWhereSort
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QWhere> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EmbeddingChunkQueryWhere
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QWhereClause> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause> idBetween(
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause>
  chunkIdEqualTo(String chunkId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'chunkId', value: [chunkId]),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterWhereClause>
  chunkIdNotEqualTo(String chunkId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'chunkId',
                lower: [],
                upper: [chunkId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'chunkId',
                lower: [chunkId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'chunkId',
                lower: [chunkId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'chunkId',
                lower: [],
                upper: [chunkId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EmbeddingChunkQueryFilter
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QFilterCondition> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chunkId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'chunkId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'chunkId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chunkId', value: ''),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  chunkIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'chunkId', value: ''),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'topic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'topic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'topic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'topic', value: ''),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'topic', value: ''),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
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

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vectorJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vectorJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vectorJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vectorJson', value: ''),
      );
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterFilterCondition>
  vectorJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vectorJson', value: ''),
      );
    });
  }
}

extension EmbeddingChunkQueryObject
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QFilterCondition> {}

extension EmbeddingChunkQueryLinks
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QFilterCondition> {}

extension EmbeddingChunkQuerySortBy
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QSortBy> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> sortByChunkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  sortByChunkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  sortByVectorJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  sortByVectorJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.desc);
    });
  }
}

extension EmbeddingChunkQuerySortThenBy
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QSortThenBy> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenByChunkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  thenByChunkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  thenByVectorJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.asc);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QAfterSortBy>
  thenByVectorJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.desc);
    });
  }
}

extension EmbeddingChunkQueryWhereDistinct
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QDistinct> {
  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QDistinct> distinctByChunkId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QDistinct> distinctByTopic({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EmbeddingChunk, EmbeddingChunk, QDistinct> distinctByVectorJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vectorJson', caseSensitive: caseSensitive);
    });
  }
}

extension EmbeddingChunkQueryProperty
    on QueryBuilder<EmbeddingChunk, EmbeddingChunk, QQueryProperty> {
  QueryBuilder<EmbeddingChunk, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmbeddingChunk, String, QQueryOperations> chunkIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkId');
    });
  }

  QueryBuilder<EmbeddingChunk, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<EmbeddingChunk, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EmbeddingChunk, String, QQueryOperations> vectorJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vectorJson');
    });
  }
}

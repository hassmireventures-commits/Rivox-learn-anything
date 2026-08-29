// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_chunk.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDocumentChunkCollection on Isar {
  IsarCollection<DocumentChunk> get documentChunks => this.collection();
}

const DocumentChunkSchema = CollectionSchema(
  name: r'DocumentChunk',
  id: 8015959461829471676,
  properties: {
    r'chunkId': PropertySchema(id: 0, name: r'chunkId', type: IsarType.string),
    r'citationLabel': PropertySchema(
      id: 1,
      name: r'citationLabel',
      type: IsarType.string,
    ),
    r'page': PropertySchema(id: 2, name: r'page', type: IsarType.long),
    r'section': PropertySchema(id: 3, name: r'section', type: IsarType.string),
    r'sourceUuid': PropertySchema(
      id: 4,
      name: r'sourceUuid',
      type: IsarType.string,
    ),
    r'text': PropertySchema(id: 5, name: r'text', type: IsarType.string),
    r'tokenEstimate': PropertySchema(
      id: 6,
      name: r'tokenEstimate',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vectorJson': PropertySchema(
      id: 8,
      name: r'vectorJson',
      type: IsarType.string,
    ),
  },

  estimateSize: _documentChunkEstimateSize,
  serialize: _documentChunkSerialize,
  deserialize: _documentChunkDeserialize,
  deserializeProp: _documentChunkDeserializeProp,
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
    r'sourceUuid': IndexSchema(
      id: -2107044383233405413,
      name: r'sourceUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _documentChunkGetId,
  getLinks: _documentChunkGetLinks,
  attach: _documentChunkAttach,
  version: '3.3.2',
);

int _documentChunkEstimateSize(
  DocumentChunk object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chunkId.length * 3;
  {
    final value = object.citationLabel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.section;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceUuid.length * 3;
  bytesCount += 3 + object.text.length * 3;
  bytesCount += 3 + object.vectorJson.length * 3;
  return bytesCount;
}

void _documentChunkSerialize(
  DocumentChunk object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chunkId);
  writer.writeString(offsets[1], object.citationLabel);
  writer.writeLong(offsets[2], object.page);
  writer.writeString(offsets[3], object.section);
  writer.writeString(offsets[4], object.sourceUuid);
  writer.writeString(offsets[5], object.text);
  writer.writeLong(offsets[6], object.tokenEstimate);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.vectorJson);
}

DocumentChunk _documentChunkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DocumentChunk();
  object.chunkId = reader.readString(offsets[0]);
  object.citationLabel = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.page = reader.readLongOrNull(offsets[2]);
  object.section = reader.readStringOrNull(offsets[3]);
  object.sourceUuid = reader.readString(offsets[4]);
  object.text = reader.readString(offsets[5]);
  object.tokenEstimate = reader.readLong(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  object.vectorJson = reader.readString(offsets[8]);
  return object;
}

P _documentChunkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _documentChunkGetId(DocumentChunk object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _documentChunkGetLinks(DocumentChunk object) {
  return [];
}

void _documentChunkAttach(
  IsarCollection<dynamic> col,
  Id id,
  DocumentChunk object,
) {
  object.id = id;
}

extension DocumentChunkByIndex on IsarCollection<DocumentChunk> {
  Future<DocumentChunk?> getByChunkId(String chunkId) {
    return getByIndex(r'chunkId', [chunkId]);
  }

  DocumentChunk? getByChunkIdSync(String chunkId) {
    return getByIndexSync(r'chunkId', [chunkId]);
  }

  Future<bool> deleteByChunkId(String chunkId) {
    return deleteByIndex(r'chunkId', [chunkId]);
  }

  bool deleteByChunkIdSync(String chunkId) {
    return deleteByIndexSync(r'chunkId', [chunkId]);
  }

  Future<List<DocumentChunk?>> getAllByChunkId(List<String> chunkIdValues) {
    final values = chunkIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'chunkId', values);
  }

  List<DocumentChunk?> getAllByChunkIdSync(List<String> chunkIdValues) {
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

  Future<Id> putByChunkId(DocumentChunk object) {
    return putByIndex(r'chunkId', object);
  }

  Id putByChunkIdSync(DocumentChunk object, {bool saveLinks = true}) {
    return putByIndexSync(r'chunkId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChunkId(List<DocumentChunk> objects) {
    return putAllByIndex(r'chunkId', objects);
  }

  List<Id> putAllByChunkIdSync(
    List<DocumentChunk> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'chunkId', objects, saveLinks: saveLinks);
  }
}

extension DocumentChunkQueryWhereSort
    on QueryBuilder<DocumentChunk, DocumentChunk, QWhere> {
  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension DocumentChunkQueryWhere
    on QueryBuilder<DocumentChunk, DocumentChunk, QWhereClause> {
  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> idBetween(
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause> chunkIdEqualTo(
    String chunkId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'chunkId', value: [chunkId]),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  sourceUuidEqualTo(String sourceUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sourceUuid', value: [sourceUuid]),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  sourceUuidNotEqualTo(String sourceUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceUuid',
                lower: [],
                upper: [sourceUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceUuid',
                lower: [sourceUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceUuid',
                lower: [sourceUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sourceUuid',
                lower: [],
                upper: [sourceUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterWhereClause>
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DocumentChunkQueryFilter
    on QueryBuilder<DocumentChunk, DocumentChunk, QFilterCondition> {
  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  chunkIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chunkId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  chunkIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'chunkId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'citationLabel'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'citationLabel'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'citationLabel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'citationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'citationLabel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'citationLabel', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  citationLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'citationLabel', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  pageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'page'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  pageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'page'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> pageEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'page', value: value),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  pageGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  pageLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'page',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> pageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'page',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'section'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'section'),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'section',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'section',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'section',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'section', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'section', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUuid', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  sourceUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUuid', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition> textMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  tokenEstimateEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tokenEstimate', value: value),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  tokenEstimateGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tokenEstimate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  tokenEstimateLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tokenEstimate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  tokenEstimateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tokenEstimate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
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

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  vectorJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vectorJson', value: ''),
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterFilterCondition>
  vectorJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vectorJson', value: ''),
      );
    });
  }
}

extension DocumentChunkQueryObject
    on QueryBuilder<DocumentChunk, DocumentChunk, QFilterCondition> {}

extension DocumentChunkQueryLinks
    on QueryBuilder<DocumentChunk, DocumentChunk, QFilterCondition> {}

extension DocumentChunkQuerySortBy
    on QueryBuilder<DocumentChunk, DocumentChunk, QSortBy> {
  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByChunkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByChunkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByCitationLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationLabel', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByCitationLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationLabel', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortBySection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortBySectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortBySourceUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUuid', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortBySourceUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUuid', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByTokenEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEstimate', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByTokenEstimateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEstimate', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> sortByVectorJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  sortByVectorJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.desc);
    });
  }
}

extension DocumentChunkQuerySortThenBy
    on QueryBuilder<DocumentChunk, DocumentChunk, QSortThenBy> {
  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByChunkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByChunkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkId', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByCitationLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationLabel', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByCitationLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citationLabel', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'page', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenBySection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenBySectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'section', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenBySourceUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUuid', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenBySourceUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUuid', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByTokenEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEstimate', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByTokenEstimateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEstimate', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy> thenByVectorJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.asc);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QAfterSortBy>
  thenByVectorJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vectorJson', Sort.desc);
    });
  }
}

extension DocumentChunkQueryWhereDistinct
    on QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> {
  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctByChunkId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct>
  distinctByCitationLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'citationLabel',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctByPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'page');
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctBySection({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'section', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctBySourceUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct>
  distinctByTokenEstimate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokenEstimate');
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DocumentChunk, DocumentChunk, QDistinct> distinctByVectorJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vectorJson', caseSensitive: caseSensitive);
    });
  }
}

extension DocumentChunkQueryProperty
    on QueryBuilder<DocumentChunk, DocumentChunk, QQueryProperty> {
  QueryBuilder<DocumentChunk, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DocumentChunk, String, QQueryOperations> chunkIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkId');
    });
  }

  QueryBuilder<DocumentChunk, String?, QQueryOperations>
  citationLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'citationLabel');
    });
  }

  QueryBuilder<DocumentChunk, int?, QQueryOperations> pageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'page');
    });
  }

  QueryBuilder<DocumentChunk, String?, QQueryOperations> sectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'section');
    });
  }

  QueryBuilder<DocumentChunk, String, QQueryOperations> sourceUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUuid');
    });
  }

  QueryBuilder<DocumentChunk, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<DocumentChunk, int, QQueryOperations> tokenEstimateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokenEstimate');
    });
  }

  QueryBuilder<DocumentChunk, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DocumentChunk, String, QQueryOperations> vectorJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vectorJson');
    });
  }
}

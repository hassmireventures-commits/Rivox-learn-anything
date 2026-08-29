// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_weights.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModelWeightsCollection on Isar {
  IsarCollection<ModelWeights> get modelWeights => this.collection();
}

const ModelWeightsSchema = CollectionSchema(
  name: r'ModelWeights',
  id: 1009214547753726063,
  properties: {
    r'modelId': PropertySchema(id: 0, name: r'modelId', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 1,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weightsJson': PropertySchema(
      id: 2,
      name: r'weightsJson',
      type: IsarType.string,
    ),
  },

  estimateSize: _modelWeightsEstimateSize,
  serialize: _modelWeightsSerialize,
  deserialize: _modelWeightsDeserialize,
  deserializeProp: _modelWeightsDeserializeProp,
  idName: r'id',
  indexes: {
    r'modelId': IndexSchema(
      id: -1910745378942518156,
      name: r'modelId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'modelId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _modelWeightsGetId,
  getLinks: _modelWeightsGetLinks,
  attach: _modelWeightsAttach,
  version: '3.3.2',
);

int _modelWeightsEstimateSize(
  ModelWeights object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.modelId.length * 3;
  bytesCount += 3 + object.weightsJson.length * 3;
  return bytesCount;
}

void _modelWeightsSerialize(
  ModelWeights object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.modelId);
  writer.writeDateTime(offsets[1], object.updatedAt);
  writer.writeString(offsets[2], object.weightsJson);
}

ModelWeights _modelWeightsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelWeights();
  object.id = id;
  object.modelId = reader.readString(offsets[0]);
  object.updatedAt = reader.readDateTime(offsets[1]);
  object.weightsJson = reader.readString(offsets[2]);
  return object;
}

P _modelWeightsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelWeightsGetId(ModelWeights object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelWeightsGetLinks(ModelWeights object) {
  return [];
}

void _modelWeightsAttach(
  IsarCollection<dynamic> col,
  Id id,
  ModelWeights object,
) {
  object.id = id;
}

extension ModelWeightsByIndex on IsarCollection<ModelWeights> {
  Future<ModelWeights?> getByModelId(String modelId) {
    return getByIndex(r'modelId', [modelId]);
  }

  ModelWeights? getByModelIdSync(String modelId) {
    return getByIndexSync(r'modelId', [modelId]);
  }

  Future<bool> deleteByModelId(String modelId) {
    return deleteByIndex(r'modelId', [modelId]);
  }

  bool deleteByModelIdSync(String modelId) {
    return deleteByIndexSync(r'modelId', [modelId]);
  }

  Future<List<ModelWeights?>> getAllByModelId(List<String> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'modelId', values);
  }

  List<ModelWeights?> getAllByModelIdSync(List<String> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'modelId', values);
  }

  Future<int> deleteAllByModelId(List<String> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'modelId', values);
  }

  int deleteAllByModelIdSync(List<String> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'modelId', values);
  }

  Future<Id> putByModelId(ModelWeights object) {
    return putByIndex(r'modelId', object);
  }

  Id putByModelIdSync(ModelWeights object, {bool saveLinks = true}) {
    return putByIndexSync(r'modelId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModelId(List<ModelWeights> objects) {
    return putAllByIndex(r'modelId', objects);
  }

  List<Id> putAllByModelIdSync(
    List<ModelWeights> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'modelId', objects, saveLinks: saveLinks);
  }
}

extension ModelWeightsQueryWhereSort
    on QueryBuilder<ModelWeights, ModelWeights, QWhere> {
  QueryBuilder<ModelWeights, ModelWeights, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ModelWeightsQueryWhere
    on QueryBuilder<ModelWeights, ModelWeights, QWhereClause> {
  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> idBetween(
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> modelIdEqualTo(
    String modelId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'modelId', value: [modelId]),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterWhereClause> modelIdNotEqualTo(
    String modelId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'modelId',
                lower: [],
                upper: [modelId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'modelId',
                lower: [modelId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'modelId',
                lower: [modelId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'modelId',
                lower: [],
                upper: [modelId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ModelWeightsQueryFilter
    on QueryBuilder<ModelWeights, ModelWeights, QFilterCondition> {
  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'modelId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'modelId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'modelId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'modelId', value: ''),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  modelIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'modelId', value: ''),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
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

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'weightsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'weightsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weightsJson', value: ''),
      );
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterFilterCondition>
  weightsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'weightsJson', value: ''),
      );
    });
  }
}

extension ModelWeightsQueryObject
    on QueryBuilder<ModelWeights, ModelWeights, QFilterCondition> {}

extension ModelWeightsQueryLinks
    on QueryBuilder<ModelWeights, ModelWeights, QFilterCondition> {}

extension ModelWeightsQuerySortBy
    on QueryBuilder<ModelWeights, ModelWeights, QSortBy> {
  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> sortByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> sortByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> sortByWeightsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsJson', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy>
  sortByWeightsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsJson', Sort.desc);
    });
  }
}

extension ModelWeightsQuerySortThenBy
    on QueryBuilder<ModelWeights, ModelWeights, QSortThenBy> {
  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy> thenByWeightsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsJson', Sort.asc);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QAfterSortBy>
  thenByWeightsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsJson', Sort.desc);
    });
  }
}

extension ModelWeightsQueryWhereDistinct
    on QueryBuilder<ModelWeights, ModelWeights, QDistinct> {
  QueryBuilder<ModelWeights, ModelWeights, QDistinct> distinctByModelId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ModelWeights, ModelWeights, QDistinct> distinctByWeightsJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightsJson', caseSensitive: caseSensitive);
    });
  }
}

extension ModelWeightsQueryProperty
    on QueryBuilder<ModelWeights, ModelWeights, QQueryProperty> {
  QueryBuilder<ModelWeights, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelWeights, String, QQueryOperations> modelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelId');
    });
  }

  QueryBuilder<ModelWeights, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ModelWeights, String, QQueryOperations> weightsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightsJson');
    });
  }
}

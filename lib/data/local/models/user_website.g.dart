// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_website.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserWebsiteCollection on Isar {
  IsarCollection<UserWebsite> get userWebsites => this.collection();
}

const UserWebsiteSchema = CollectionSchema(
  name: r'UserWebsite',
  id: -3465709225105700678,
  properties: {
    r'crawlMode': PropertySchema(
      id: 0,
      name: r'crawlMode',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'domain': PropertySchema(id: 2, name: r'domain', type: IsarType.string),
    r'enabled': PropertySchema(id: 3, name: r'enabled', type: IsarType.bool),
    r'goalMode': PropertySchema(
      id: 4,
      name: r'goalMode',
      type: IsarType.string,
    ),
    r'label': PropertySchema(id: 5, name: r'label', type: IsarType.string),
    r'lastCrawledAt': PropertySchema(
      id: 6,
      name: r'lastCrawledAt',
      type: IsarType.dateTime,
    ),
    r'startUrl': PropertySchema(
      id: 7,
      name: r'startUrl',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(id: 8, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _userWebsiteEstimateSize,
  serialize: _userWebsiteSerialize,
  deserialize: _userWebsiteDeserialize,
  deserializeProp: _userWebsiteDeserializeProp,
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
    r'domain': IndexSchema(
      id: 1163864941618423784,
      name: r'domain',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'domain',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'goalMode': IndexSchema(
      id: 8458058537980181431,
      name: r'goalMode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'goalMode',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _userWebsiteGetId,
  getLinks: _userWebsiteGetLinks,
  attach: _userWebsiteAttach,
  version: '3.3.2',
);

int _userWebsiteEstimateSize(
  UserWebsite object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.crawlMode.length * 3;
  bytesCount += 3 + object.domain.length * 3;
  bytesCount += 3 + object.goalMode.length * 3;
  bytesCount += 3 + object.label.length * 3;
  {
    final value = object.startUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _userWebsiteSerialize(
  UserWebsite object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.crawlMode);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.domain);
  writer.writeBool(offsets[3], object.enabled);
  writer.writeString(offsets[4], object.goalMode);
  writer.writeString(offsets[5], object.label);
  writer.writeDateTime(offsets[6], object.lastCrawledAt);
  writer.writeString(offsets[7], object.startUrl);
  writer.writeString(offsets[8], object.uuid);
}

UserWebsite _userWebsiteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserWebsite();
  object.crawlMode = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.domain = reader.readString(offsets[2]);
  object.enabled = reader.readBool(offsets[3]);
  object.goalMode = reader.readString(offsets[4]);
  object.id = id;
  object.label = reader.readString(offsets[5]);
  object.lastCrawledAt = reader.readDateTimeOrNull(offsets[6]);
  object.startUrl = reader.readStringOrNull(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  return object;
}

P _userWebsiteDeserializeProp<P>(
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
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userWebsiteGetId(UserWebsite object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userWebsiteGetLinks(UserWebsite object) {
  return [];
}

void _userWebsiteAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserWebsite object,
) {
  object.id = id;
}

extension UserWebsiteByIndex on IsarCollection<UserWebsite> {
  Future<UserWebsite?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  UserWebsite? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<UserWebsite?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<UserWebsite?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(UserWebsite object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(UserWebsite object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<UserWebsite> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<UserWebsite> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension UserWebsiteQueryWhereSort
    on QueryBuilder<UserWebsite, UserWebsite, QWhere> {
  QueryBuilder<UserWebsite, UserWebsite, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserWebsiteQueryWhere
    on QueryBuilder<UserWebsite, UserWebsite, QWhereClause> {
  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> domainEqualTo(
    String domain,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'domain', value: [domain]),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> domainNotEqualTo(
    String domain,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domain',
                lower: [],
                upper: [domain],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domain',
                lower: [domain],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domain',
                lower: [domain],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domain',
                lower: [],
                upper: [domain],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> goalModeEqualTo(
    String goalMode,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'goalMode', value: [goalMode]),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterWhereClause> goalModeNotEqualTo(
    String goalMode,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [],
                upper: [goalMode],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [goalMode],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [goalMode],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'goalMode',
                lower: [],
                upper: [goalMode],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension UserWebsiteQueryFilter
    on QueryBuilder<UserWebsite, UserWebsite, QFilterCondition> {
  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'crawlMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'crawlMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'crawlMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'crawlMode', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  crawlModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'crawlMode', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  domainGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'domain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  domainStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'domain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> domainMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'domain',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  domainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domain', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  domainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domain', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> enabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> goalModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> goalModeBetween(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> goalModeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  goalModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  goalModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalMode', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastCrawledAt'),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastCrawledAt'),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastCrawledAt', value: value),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastCrawledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastCrawledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  lastCrawledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastCrawledAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startUrl'),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startUrl'),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> startUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> startUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> startUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startUrl', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  startUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startUrl', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidGreaterThan(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension UserWebsiteQueryObject
    on QueryBuilder<UserWebsite, UserWebsite, QFilterCondition> {}

extension UserWebsiteQueryLinks
    on QueryBuilder<UserWebsite, UserWebsite, QFilterCondition> {}

extension UserWebsiteQuerySortBy
    on QueryBuilder<UserWebsite, UserWebsite, QSortBy> {
  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByCrawlMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crawlMode', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByCrawlModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crawlMode', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByLastCrawledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrawledAt', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy>
  sortByLastCrawledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrawledAt', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByStartUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startUrl', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByStartUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startUrl', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension UserWebsiteQuerySortThenBy
    on QueryBuilder<UserWebsite, UserWebsite, QSortThenBy> {
  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByCrawlMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crawlMode', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByCrawlModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crawlMode', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByGoalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByGoalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMode', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByLastCrawledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrawledAt', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy>
  thenByLastCrawledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCrawledAt', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByStartUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startUrl', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByStartUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startUrl', Sort.desc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension UserWebsiteQueryWhereDistinct
    on QueryBuilder<UserWebsite, UserWebsite, QDistinct> {
  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByCrawlMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crawlMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByDomain({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByGoalMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByLabel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByLastCrawledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCrawledAt');
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByStartUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserWebsite, UserWebsite, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension UserWebsiteQueryProperty
    on QueryBuilder<UserWebsite, UserWebsite, QQueryProperty> {
  QueryBuilder<UserWebsite, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserWebsite, String, QQueryOperations> crawlModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crawlMode');
    });
  }

  QueryBuilder<UserWebsite, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserWebsite, String, QQueryOperations> domainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domain');
    });
  }

  QueryBuilder<UserWebsite, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<UserWebsite, String, QQueryOperations> goalModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalMode');
    });
  }

  QueryBuilder<UserWebsite, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<UserWebsite, DateTime?, QQueryOperations>
  lastCrawledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCrawledAt');
    });
  }

  QueryBuilder<UserWebsite, String?, QQueryOperations> startUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startUrl');
    });
  }

  QueryBuilder<UserWebsite, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinanceModelCollection on Isar {
  IsarCollection<FinanceModel> get financeModels => this.collection();
}

const FinanceModelSchema = CollectionSchema(
  name: r'FinanceModel',
  id: -2659374298457402775,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'application': PropertySchema(
      id: 1,
      name: r'application',
      type: IsarType.string,
    ),
    r'body': PropertySchema(
      id: 2,
      name: r'body',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 4,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'smsId': PropertySchema(
      id: 5,
      name: r'smsId',
      type: IsarType.long,
    ),
    r'triggerKeyword': PropertySchema(
      id: 6,
      name: r'triggerKeyword',
      type: IsarType.string,
    )
  },
  estimateSize: _financeModelEstimateSize,
  serialize: _financeModelSerialize,
  deserialize: _financeModelDeserialize,
  deserializeProp: _financeModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'smsId': IndexSchema(
      id: -2965135931201390284,
      name: r'smsId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'smsId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _financeModelGetId,
  getLinks: _financeModelGetLinks,
  attach: _financeModelAttach,
  version: '3.1.0+1',
);

int _financeModelEstimateSize(
  FinanceModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.application.length * 3;
  bytesCount += 3 + object.body.length * 3;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.triggerKeyword;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _financeModelSerialize(
  FinanceModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.application);
  writer.writeString(offsets[2], object.body);
  writer.writeString(offsets[3], object.category);
  writer.writeDateTime(offsets[4], object.date);
  writer.writeLong(offsets[5], object.smsId);
  writer.writeString(offsets[6], object.triggerKeyword);
}

FinanceModel _financeModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinanceModel(
    amount: reader.readDouble(offsets[0]),
    application: reader.readString(offsets[1]),
    body: reader.readString(offsets[2]),
    category: reader.readString(offsets[3]),
    date: reader.readDateTime(offsets[4]),
    smsId: reader.readLong(offsets[5]),
    triggerKeyword: reader.readStringOrNull(offsets[6]),
  );
  object.id = id;
  return object;
}

P _financeModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financeModelGetId(FinanceModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financeModelGetLinks(FinanceModel object) {
  return [];
}

void _financeModelAttach(
    IsarCollection<dynamic> col, Id id, FinanceModel object) {
  object.id = id;
}

extension FinanceModelByIndex on IsarCollection<FinanceModel> {
  Future<FinanceModel?> getBySmsId(int smsId) {
    return getByIndex(r'smsId', [smsId]);
  }

  FinanceModel? getBySmsIdSync(int smsId) {
    return getByIndexSync(r'smsId', [smsId]);
  }

  Future<bool> deleteBySmsId(int smsId) {
    return deleteByIndex(r'smsId', [smsId]);
  }

  bool deleteBySmsIdSync(int smsId) {
    return deleteByIndexSync(r'smsId', [smsId]);
  }

  Future<List<FinanceModel?>> getAllBySmsId(List<int> smsIdValues) {
    final values = smsIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'smsId', values);
  }

  List<FinanceModel?> getAllBySmsIdSync(List<int> smsIdValues) {
    final values = smsIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'smsId', values);
  }

  Future<int> deleteAllBySmsId(List<int> smsIdValues) {
    final values = smsIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'smsId', values);
  }

  int deleteAllBySmsIdSync(List<int> smsIdValues) {
    final values = smsIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'smsId', values);
  }

  Future<Id> putBySmsId(FinanceModel object) {
    return putByIndex(r'smsId', object);
  }

  Id putBySmsIdSync(FinanceModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'smsId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySmsId(List<FinanceModel> objects) {
    return putAllByIndex(r'smsId', objects);
  }

  List<Id> putAllBySmsIdSync(List<FinanceModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'smsId', objects, saveLinks: saveLinks);
  }
}

extension FinanceModelQueryWhereSort
    on QueryBuilder<FinanceModel, FinanceModel, QWhere> {
  QueryBuilder<FinanceModel, FinanceModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhere> anySmsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'smsId'),
      );
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension FinanceModelQueryWhere
    on QueryBuilder<FinanceModel, FinanceModel, QWhereClause> {
  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> smsIdEqualTo(
      int smsId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'smsId',
        value: [smsId],
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> smsIdNotEqualTo(
      int smsId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'smsId',
              lower: [],
              upper: [smsId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'smsId',
              lower: [smsId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'smsId',
              lower: [smsId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'smsId',
              lower: [],
              upper: [smsId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> smsIdGreaterThan(
    int smsId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'smsId',
        lower: [smsId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> smsIdLessThan(
    int smsId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'smsId',
        lower: [],
        upper: [smsId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> smsIdBetween(
    int lowerSmsId,
    int upperSmsId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'smsId',
        lower: [lowerSmsId],
        includeLower: includeLower,
        upper: [upperSmsId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinanceModelQueryFilter
    on QueryBuilder<FinanceModel, FinanceModel, QFilterCondition> {
  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'application',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'application',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'application',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'application',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      applicationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'application',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> bodyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> smsIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smsId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      smsIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'smsId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> smsIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'smsId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition> smsIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'smsId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'triggerKeyword',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'triggerKeyword',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerKeyword',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerKeyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerKeyword',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerKeyword',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterFilterCondition>
      triggerKeywordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerKeyword',
        value: '',
      ));
    });
  }
}

extension FinanceModelQueryObject
    on QueryBuilder<FinanceModel, FinanceModel, QFilterCondition> {}

extension FinanceModelQueryLinks
    on QueryBuilder<FinanceModel, FinanceModel, QFilterCondition> {}

extension FinanceModelQuerySortBy
    on QueryBuilder<FinanceModel, FinanceModel, QSortBy> {
  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByApplication() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'application', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      sortByApplicationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'application', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortBySmsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsId', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> sortBySmsIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsId', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      sortByTriggerKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerKeyword', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      sortByTriggerKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerKeyword', Sort.desc);
    });
  }
}

extension FinanceModelQuerySortThenBy
    on QueryBuilder<FinanceModel, FinanceModel, QSortThenBy> {
  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByApplication() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'application', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      thenByApplicationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'application', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenBySmsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsId', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy> thenBySmsIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsId', Sort.desc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      thenByTriggerKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerKeyword', Sort.asc);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QAfterSortBy>
      thenByTriggerKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerKeyword', Sort.desc);
    });
  }
}

extension FinanceModelQueryWhereDistinct
    on QueryBuilder<FinanceModel, FinanceModel, QDistinct> {
  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByApplication(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'application', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctBySmsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smsId');
    });
  }

  QueryBuilder<FinanceModel, FinanceModel, QDistinct> distinctByTriggerKeyword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerKeyword',
          caseSensitive: caseSensitive);
    });
  }
}

extension FinanceModelQueryProperty
    on QueryBuilder<FinanceModel, FinanceModel, QQueryProperty> {
  QueryBuilder<FinanceModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinanceModel, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<FinanceModel, String, QQueryOperations> applicationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'application');
    });
  }

  QueryBuilder<FinanceModel, String, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<FinanceModel, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<FinanceModel, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<FinanceModel, int, QQueryOperations> smsIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smsId');
    });
  }

  QueryBuilder<FinanceModel, String?, QQueryOperations>
      triggerKeywordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerKeyword');
    });
  }
}

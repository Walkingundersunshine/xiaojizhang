// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    name,
    sortOrder,
    isSystem,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String? parentId;
  final String name;
  final int sortOrder;
  final bool isSystem;
  final bool isActive;
  const Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.sortOrder,
    required this.isSystem,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Category copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? name,
    int? sortOrder,
    bool? isSystem,
    bool? isActive,
  }) => Category(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, name, sortOrder, isSystem, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    required int sortOrder,
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _occurredAtUtcMillisecondsMeta =
      const VerificationMeta('occurredAtUtcMilliseconds');
  @override
  late final GeneratedColumn<int> occurredAtUtcMilliseconds =
      GeneratedColumn<int>(
        'occurred_at_utc_milliseconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _occurredTimezoneOffsetMinutesMeta =
      const VerificationMeta('occurredTimezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> occurredTimezoneOffsetMinutes =
      GeneratedColumn<int>(
        'occurred_timezone_offset_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMillisecondsMeta =
      const VerificationMeta('createdAtUtcMilliseconds');
  @override
  late final GeneratedColumn<int> createdAtUtcMilliseconds =
      GeneratedColumn<int>(
        'created_at_utc_milliseconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtUtcMillisecondsMeta =
      const VerificationMeta('updatedAtUtcMilliseconds');
  @override
  late final GeneratedColumn<int> updatedAtUtcMilliseconds =
      GeneratedColumn<int>(
        'updated_at_utc_milliseconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    currencyCode,
    categoryId,
    occurredAtUtcMilliseconds,
    occurredTimezoneOffsetMinutes,
    note,
    createdAtUtcMilliseconds,
    updatedAtUtcMilliseconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('occurred_at_utc_milliseconds')) {
      context.handle(
        _occurredAtUtcMillisecondsMeta,
        occurredAtUtcMilliseconds.isAcceptableOrUnknown(
          data['occurred_at_utc_milliseconds']!,
          _occurredAtUtcMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMillisecondsMeta);
    }
    if (data.containsKey('occurred_timezone_offset_minutes')) {
      context.handle(
        _occurredTimezoneOffsetMinutesMeta,
        occurredTimezoneOffsetMinutes.isAcceptableOrUnknown(
          data['occurred_timezone_offset_minutes']!,
          _occurredTimezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredTimezoneOffsetMinutesMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_utc_milliseconds')) {
      context.handle(
        _createdAtUtcMillisecondsMeta,
        createdAtUtcMilliseconds.isAcceptableOrUnknown(
          data['created_at_utc_milliseconds']!,
          _createdAtUtcMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMillisecondsMeta);
    }
    if (data.containsKey('updated_at_utc_milliseconds')) {
      context.handle(
        _updatedAtUtcMillisecondsMeta,
        updatedAtUtcMilliseconds.isAcceptableOrUnknown(
          data['updated_at_utc_milliseconds']!,
          _updatedAtUtcMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      occurredAtUtcMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_milliseconds'],
      )!,
      occurredTimezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_timezone_offset_minutes'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtUtcMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_milliseconds'],
      )!,
      updatedAtUtcMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_milliseconds'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final int amountMinor;
  final String currencyCode;
  final String categoryId;
  final int occurredAtUtcMilliseconds;
  final int occurredTimezoneOffsetMinutes;
  final String? note;
  final int createdAtUtcMilliseconds;
  final int updatedAtUtcMilliseconds;
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.occurredAtUtcMilliseconds,
    required this.occurredTimezoneOffsetMinutes,
    this.note,
    required this.createdAtUtcMilliseconds,
    required this.updatedAtUtcMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_id'] = Variable<String>(categoryId);
    map['occurred_at_utc_milliseconds'] = Variable<int>(
      occurredAtUtcMilliseconds,
    );
    map['occurred_timezone_offset_minutes'] = Variable<int>(
      occurredTimezoneOffsetMinutes,
    );
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_utc_milliseconds'] = Variable<int>(
      createdAtUtcMilliseconds,
    );
    map['updated_at_utc_milliseconds'] = Variable<int>(
      updatedAtUtcMilliseconds,
    );
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      categoryId: Value(categoryId),
      occurredAtUtcMilliseconds: Value(occurredAtUtcMilliseconds),
      occurredTimezoneOffsetMinutes: Value(occurredTimezoneOffsetMinutes),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtUtcMilliseconds: Value(createdAtUtcMilliseconds),
      updatedAtUtcMilliseconds: Value(updatedAtUtcMilliseconds),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      occurredAtUtcMilliseconds: serializer.fromJson<int>(
        json['occurredAtUtcMilliseconds'],
      ),
      occurredTimezoneOffsetMinutes: serializer.fromJson<int>(
        json['occurredTimezoneOffsetMinutes'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAtUtcMilliseconds: serializer.fromJson<int>(
        json['createdAtUtcMilliseconds'],
      ),
      updatedAtUtcMilliseconds: serializer.fromJson<int>(
        json['updatedAtUtcMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryId': serializer.toJson<String>(categoryId),
      'occurredAtUtcMilliseconds': serializer.toJson<int>(
        occurredAtUtcMilliseconds,
      ),
      'occurredTimezoneOffsetMinutes': serializer.toJson<int>(
        occurredTimezoneOffsetMinutes,
      ),
      'note': serializer.toJson<String?>(note),
      'createdAtUtcMilliseconds': serializer.toJson<int>(
        createdAtUtcMilliseconds,
      ),
      'updatedAtUtcMilliseconds': serializer.toJson<int>(
        updatedAtUtcMilliseconds,
      ),
    };
  }

  Expense copyWith({
    int? id,
    int? amountMinor,
    String? currencyCode,
    String? categoryId,
    int? occurredAtUtcMilliseconds,
    int? occurredTimezoneOffsetMinutes,
    Value<String?> note = const Value.absent(),
    int? createdAtUtcMilliseconds,
    int? updatedAtUtcMilliseconds,
  }) => Expense(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryId: categoryId ?? this.categoryId,
    occurredAtUtcMilliseconds:
        occurredAtUtcMilliseconds ?? this.occurredAtUtcMilliseconds,
    occurredTimezoneOffsetMinutes:
        occurredTimezoneOffsetMinutes ?? this.occurredTimezoneOffsetMinutes,
    note: note.present ? note.value : this.note,
    createdAtUtcMilliseconds:
        createdAtUtcMilliseconds ?? this.createdAtUtcMilliseconds,
    updatedAtUtcMilliseconds:
        updatedAtUtcMilliseconds ?? this.updatedAtUtcMilliseconds,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      occurredAtUtcMilliseconds: data.occurredAtUtcMilliseconds.present
          ? data.occurredAtUtcMilliseconds.value
          : this.occurredAtUtcMilliseconds,
      occurredTimezoneOffsetMinutes: data.occurredTimezoneOffsetMinutes.present
          ? data.occurredTimezoneOffsetMinutes.value
          : this.occurredTimezoneOffsetMinutes,
      note: data.note.present ? data.note.value : this.note,
      createdAtUtcMilliseconds: data.createdAtUtcMilliseconds.present
          ? data.createdAtUtcMilliseconds.value
          : this.createdAtUtcMilliseconds,
      updatedAtUtcMilliseconds: data.updatedAtUtcMilliseconds.present
          ? data.updatedAtUtcMilliseconds.value
          : this.updatedAtUtcMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAtUtcMilliseconds: $occurredAtUtcMilliseconds, ')
          ..write(
            'occurredTimezoneOffsetMinutes: $occurredTimezoneOffsetMinutes, ',
          )
          ..write('note: $note, ')
          ..write('createdAtUtcMilliseconds: $createdAtUtcMilliseconds, ')
          ..write('updatedAtUtcMilliseconds: $updatedAtUtcMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    currencyCode,
    categoryId,
    occurredAtUtcMilliseconds,
    occurredTimezoneOffsetMinutes,
    note,
    createdAtUtcMilliseconds,
    updatedAtUtcMilliseconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.categoryId == this.categoryId &&
          other.occurredAtUtcMilliseconds == this.occurredAtUtcMilliseconds &&
          other.occurredTimezoneOffsetMinutes ==
              this.occurredTimezoneOffsetMinutes &&
          other.note == this.note &&
          other.createdAtUtcMilliseconds == this.createdAtUtcMilliseconds &&
          other.updatedAtUtcMilliseconds == this.updatedAtUtcMilliseconds);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> categoryId;
  final Value<int> occurredAtUtcMilliseconds;
  final Value<int> occurredTimezoneOffsetMinutes;
  final Value<String?> note;
  final Value<int> createdAtUtcMilliseconds;
  final Value<int> updatedAtUtcMilliseconds;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.occurredAtUtcMilliseconds = const Value.absent(),
    this.occurredTimezoneOffsetMinutes = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtUtcMilliseconds = const Value.absent(),
    this.updatedAtUtcMilliseconds = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int amountMinor,
    required String currencyCode,
    required String categoryId,
    required int occurredAtUtcMilliseconds,
    required int occurredTimezoneOffsetMinutes,
    this.note = const Value.absent(),
    required int createdAtUtcMilliseconds,
    required int updatedAtUtcMilliseconds,
  }) : amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       categoryId = Value(categoryId),
       occurredAtUtcMilliseconds = Value(occurredAtUtcMilliseconds),
       occurredTimezoneOffsetMinutes = Value(occurredTimezoneOffsetMinutes),
       createdAtUtcMilliseconds = Value(createdAtUtcMilliseconds),
       updatedAtUtcMilliseconds = Value(updatedAtUtcMilliseconds);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? categoryId,
    Expression<int>? occurredAtUtcMilliseconds,
    Expression<int>? occurredTimezoneOffsetMinutes,
    Expression<String>? note,
    Expression<int>? createdAtUtcMilliseconds,
    Expression<int>? updatedAtUtcMilliseconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryId != null) 'category_id': categoryId,
      if (occurredAtUtcMilliseconds != null)
        'occurred_at_utc_milliseconds': occurredAtUtcMilliseconds,
      if (occurredTimezoneOffsetMinutes != null)
        'occurred_timezone_offset_minutes': occurredTimezoneOffsetMinutes,
      if (note != null) 'note': note,
      if (createdAtUtcMilliseconds != null)
        'created_at_utc_milliseconds': createdAtUtcMilliseconds,
      if (updatedAtUtcMilliseconds != null)
        'updated_at_utc_milliseconds': updatedAtUtcMilliseconds,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? categoryId,
    Value<int>? occurredAtUtcMilliseconds,
    Value<int>? occurredTimezoneOffsetMinutes,
    Value<String?>? note,
    Value<int>? createdAtUtcMilliseconds,
    Value<int>? updatedAtUtcMilliseconds,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      occurredAtUtcMilliseconds:
          occurredAtUtcMilliseconds ?? this.occurredAtUtcMilliseconds,
      occurredTimezoneOffsetMinutes:
          occurredTimezoneOffsetMinutes ?? this.occurredTimezoneOffsetMinutes,
      note: note ?? this.note,
      createdAtUtcMilliseconds:
          createdAtUtcMilliseconds ?? this.createdAtUtcMilliseconds,
      updatedAtUtcMilliseconds:
          updatedAtUtcMilliseconds ?? this.updatedAtUtcMilliseconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (occurredAtUtcMilliseconds.present) {
      map['occurred_at_utc_milliseconds'] = Variable<int>(
        occurredAtUtcMilliseconds.value,
      );
    }
    if (occurredTimezoneOffsetMinutes.present) {
      map['occurred_timezone_offset_minutes'] = Variable<int>(
        occurredTimezoneOffsetMinutes.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtUtcMilliseconds.present) {
      map['created_at_utc_milliseconds'] = Variable<int>(
        createdAtUtcMilliseconds.value,
      );
    }
    if (updatedAtUtcMilliseconds.present) {
      map['updated_at_utc_milliseconds'] = Variable<int>(
        updatedAtUtcMilliseconds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAtUtcMilliseconds: $occurredAtUtcMilliseconds, ')
          ..write(
            'occurredTimezoneOffsetMinutes: $occurredTimezoneOffsetMinutes, ',
          )
          ..write('note: $note, ')
          ..write('createdAtUtcMilliseconds: $createdAtUtcMilliseconds, ')
          ..write('updatedAtUtcMilliseconds: $updatedAtUtcMilliseconds')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestedDateMeta = const VerificationMeta(
    'requestedDate',
  );
  @override
  late final GeneratedColumn<String> requestedDate = GeneratedColumn<String>(
    'requested_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDateMeta = const VerificationMeta(
    'sourceDate',
  );
  @override
  late final GeneratedColumn<String> sourceDate = GeneratedColumn<String>(
    'source_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyCodeMeta = const VerificationMeta(
    'baseCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> baseCurrencyCode = GeneratedColumn<String>(
    'base_currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyCodeMeta = const VerificationMeta(
    'quoteCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> quoteCurrencyCode =
      GeneratedColumn<String>(
        'quote_currency_code',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 3,
          maxTextLength: 3,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _scaledRateMeta = const VerificationMeta(
    'scaledRate',
  );
  @override
  late final GeneratedColumn<int> scaledRate = GeneratedColumn<int>(
    'scaled_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtUtcMillisecondsMeta =
      const VerificationMeta('fetchedAtUtcMilliseconds');
  @override
  late final GeneratedColumn<int> fetchedAtUtcMilliseconds =
      GeneratedColumn<int>(
        'fetched_at_utc_milliseconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    requestedDate,
    sourceDate,
    baseCurrencyCode,
    quoteCurrencyCode,
    scaledRate,
    fetchedAtUtcMilliseconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('requested_date')) {
      context.handle(
        _requestedDateMeta,
        requestedDate.isAcceptableOrUnknown(
          data['requested_date']!,
          _requestedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedDateMeta);
    }
    if (data.containsKey('source_date')) {
      context.handle(
        _sourceDateMeta,
        sourceDate.isAcceptableOrUnknown(data['source_date']!, _sourceDateMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceDateMeta);
    }
    if (data.containsKey('base_currency_code')) {
      context.handle(
        _baseCurrencyCodeMeta,
        baseCurrencyCode.isAcceptableOrUnknown(
          data['base_currency_code']!,
          _baseCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyCodeMeta);
    }
    if (data.containsKey('quote_currency_code')) {
      context.handle(
        _quoteCurrencyCodeMeta,
        quoteCurrencyCode.isAcceptableOrUnknown(
          data['quote_currency_code']!,
          _quoteCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quoteCurrencyCodeMeta);
    }
    if (data.containsKey('scaled_rate')) {
      context.handle(
        _scaledRateMeta,
        scaledRate.isAcceptableOrUnknown(data['scaled_rate']!, _scaledRateMeta),
      );
    } else if (isInserting) {
      context.missing(_scaledRateMeta);
    }
    if (data.containsKey('fetched_at_utc_milliseconds')) {
      context.handle(
        _fetchedAtUtcMillisecondsMeta,
        fetchedAtUtcMilliseconds.isAcceptableOrUnknown(
          data['fetched_at_utc_milliseconds']!,
          _fetchedAtUtcMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtUtcMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    requestedDate,
    baseCurrencyCode,
    quoteCurrencyCode,
  };
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      requestedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_date'],
      )!,
      sourceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_date'],
      )!,
      baseCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency_code'],
      )!,
      quoteCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency_code'],
      )!,
      scaledRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scaled_rate'],
      )!,
      fetchedAtUtcMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_utc_milliseconds'],
      )!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final String requestedDate;
  final String sourceDate;
  final String baseCurrencyCode;
  final String quoteCurrencyCode;
  final int scaledRate;
  final int fetchedAtUtcMilliseconds;
  const ExchangeRate({
    required this.requestedDate,
    required this.sourceDate,
    required this.baseCurrencyCode,
    required this.quoteCurrencyCode,
    required this.scaledRate,
    required this.fetchedAtUtcMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['requested_date'] = Variable<String>(requestedDate);
    map['source_date'] = Variable<String>(sourceDate);
    map['base_currency_code'] = Variable<String>(baseCurrencyCode);
    map['quote_currency_code'] = Variable<String>(quoteCurrencyCode);
    map['scaled_rate'] = Variable<int>(scaledRate);
    map['fetched_at_utc_milliseconds'] = Variable<int>(
      fetchedAtUtcMilliseconds,
    );
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      requestedDate: Value(requestedDate),
      sourceDate: Value(sourceDate),
      baseCurrencyCode: Value(baseCurrencyCode),
      quoteCurrencyCode: Value(quoteCurrencyCode),
      scaledRate: Value(scaledRate),
      fetchedAtUtcMilliseconds: Value(fetchedAtUtcMilliseconds),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      requestedDate: serializer.fromJson<String>(json['requestedDate']),
      sourceDate: serializer.fromJson<String>(json['sourceDate']),
      baseCurrencyCode: serializer.fromJson<String>(json['baseCurrencyCode']),
      quoteCurrencyCode: serializer.fromJson<String>(json['quoteCurrencyCode']),
      scaledRate: serializer.fromJson<int>(json['scaledRate']),
      fetchedAtUtcMilliseconds: serializer.fromJson<int>(
        json['fetchedAtUtcMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestedDate': serializer.toJson<String>(requestedDate),
      'sourceDate': serializer.toJson<String>(sourceDate),
      'baseCurrencyCode': serializer.toJson<String>(baseCurrencyCode),
      'quoteCurrencyCode': serializer.toJson<String>(quoteCurrencyCode),
      'scaledRate': serializer.toJson<int>(scaledRate),
      'fetchedAtUtcMilliseconds': serializer.toJson<int>(
        fetchedAtUtcMilliseconds,
      ),
    };
  }

  ExchangeRate copyWith({
    String? requestedDate,
    String? sourceDate,
    String? baseCurrencyCode,
    String? quoteCurrencyCode,
    int? scaledRate,
    int? fetchedAtUtcMilliseconds,
  }) => ExchangeRate(
    requestedDate: requestedDate ?? this.requestedDate,
    sourceDate: sourceDate ?? this.sourceDate,
    baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
    quoteCurrencyCode: quoteCurrencyCode ?? this.quoteCurrencyCode,
    scaledRate: scaledRate ?? this.scaledRate,
    fetchedAtUtcMilliseconds:
        fetchedAtUtcMilliseconds ?? this.fetchedAtUtcMilliseconds,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      requestedDate: data.requestedDate.present
          ? data.requestedDate.value
          : this.requestedDate,
      sourceDate: data.sourceDate.present
          ? data.sourceDate.value
          : this.sourceDate,
      baseCurrencyCode: data.baseCurrencyCode.present
          ? data.baseCurrencyCode.value
          : this.baseCurrencyCode,
      quoteCurrencyCode: data.quoteCurrencyCode.present
          ? data.quoteCurrencyCode.value
          : this.quoteCurrencyCode,
      scaledRate: data.scaledRate.present
          ? data.scaledRate.value
          : this.scaledRate,
      fetchedAtUtcMilliseconds: data.fetchedAtUtcMilliseconds.present
          ? data.fetchedAtUtcMilliseconds.value
          : this.fetchedAtUtcMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('requestedDate: $requestedDate, ')
          ..write('sourceDate: $sourceDate, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('quoteCurrencyCode: $quoteCurrencyCode, ')
          ..write('scaledRate: $scaledRate, ')
          ..write('fetchedAtUtcMilliseconds: $fetchedAtUtcMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    requestedDate,
    sourceDate,
    baseCurrencyCode,
    quoteCurrencyCode,
    scaledRate,
    fetchedAtUtcMilliseconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.requestedDate == this.requestedDate &&
          other.sourceDate == this.sourceDate &&
          other.baseCurrencyCode == this.baseCurrencyCode &&
          other.quoteCurrencyCode == this.quoteCurrencyCode &&
          other.scaledRate == this.scaledRate &&
          other.fetchedAtUtcMilliseconds == this.fetchedAtUtcMilliseconds);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<String> requestedDate;
  final Value<String> sourceDate;
  final Value<String> baseCurrencyCode;
  final Value<String> quoteCurrencyCode;
  final Value<int> scaledRate;
  final Value<int> fetchedAtUtcMilliseconds;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.requestedDate = const Value.absent(),
    this.sourceDate = const Value.absent(),
    this.baseCurrencyCode = const Value.absent(),
    this.quoteCurrencyCode = const Value.absent(),
    this.scaledRate = const Value.absent(),
    this.fetchedAtUtcMilliseconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required String requestedDate,
    required String sourceDate,
    required String baseCurrencyCode,
    required String quoteCurrencyCode,
    required int scaledRate,
    required int fetchedAtUtcMilliseconds,
    this.rowid = const Value.absent(),
  }) : requestedDate = Value(requestedDate),
       sourceDate = Value(sourceDate),
       baseCurrencyCode = Value(baseCurrencyCode),
       quoteCurrencyCode = Value(quoteCurrencyCode),
       scaledRate = Value(scaledRate),
       fetchedAtUtcMilliseconds = Value(fetchedAtUtcMilliseconds);
  static Insertable<ExchangeRate> custom({
    Expression<String>? requestedDate,
    Expression<String>? sourceDate,
    Expression<String>? baseCurrencyCode,
    Expression<String>? quoteCurrencyCode,
    Expression<int>? scaledRate,
    Expression<int>? fetchedAtUtcMilliseconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestedDate != null) 'requested_date': requestedDate,
      if (sourceDate != null) 'source_date': sourceDate,
      if (baseCurrencyCode != null) 'base_currency_code': baseCurrencyCode,
      if (quoteCurrencyCode != null) 'quote_currency_code': quoteCurrencyCode,
      if (scaledRate != null) 'scaled_rate': scaledRate,
      if (fetchedAtUtcMilliseconds != null)
        'fetched_at_utc_milliseconds': fetchedAtUtcMilliseconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<String>? requestedDate,
    Value<String>? sourceDate,
    Value<String>? baseCurrencyCode,
    Value<String>? quoteCurrencyCode,
    Value<int>? scaledRate,
    Value<int>? fetchedAtUtcMilliseconds,
    Value<int>? rowid,
  }) {
    return ExchangeRatesCompanion(
      requestedDate: requestedDate ?? this.requestedDate,
      sourceDate: sourceDate ?? this.sourceDate,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      quoteCurrencyCode: quoteCurrencyCode ?? this.quoteCurrencyCode,
      scaledRate: scaledRate ?? this.scaledRate,
      fetchedAtUtcMilliseconds:
          fetchedAtUtcMilliseconds ?? this.fetchedAtUtcMilliseconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestedDate.present) {
      map['requested_date'] = Variable<String>(requestedDate.value);
    }
    if (sourceDate.present) {
      map['source_date'] = Variable<String>(sourceDate.value);
    }
    if (baseCurrencyCode.present) {
      map['base_currency_code'] = Variable<String>(baseCurrencyCode.value);
    }
    if (quoteCurrencyCode.present) {
      map['quote_currency_code'] = Variable<String>(quoteCurrencyCode.value);
    }
    if (scaledRate.present) {
      map['scaled_rate'] = Variable<int>(scaledRate.value);
    }
    if (fetchedAtUtcMilliseconds.present) {
      map['fetched_at_utc_milliseconds'] = Variable<int>(
        fetchedAtUtcMilliseconds.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('requestedDate: $requestedDate, ')
          ..write('sourceDate: $sourceDate, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('quoteCurrencyCode: $quoteCurrencyCode, ')
          ..write('scaledRate: $scaledRate, ')
          ..write('fetchedAtUtcMilliseconds: $fetchedAtUtcMilliseconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _baseCurrencyCodeMeta = const VerificationMeta(
    'baseCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> baseCurrencyCode = GeneratedColumn<String>(
    'base_currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMillisecondsMeta =
      const VerificationMeta('updatedAtUtcMilliseconds');
  @override
  late final GeneratedColumn<int> updatedAtUtcMilliseconds =
      GeneratedColumn<int>(
        'updated_at_utc_milliseconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseCurrencyCode,
    updatedAtUtcMilliseconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_currency_code')) {
      context.handle(
        _baseCurrencyCodeMeta,
        baseCurrencyCode.isAcceptableOrUnknown(
          data['base_currency_code']!,
          _baseCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyCodeMeta);
    }
    if (data.containsKey('updated_at_utc_milliseconds')) {
      context.handle(
        _updatedAtUtcMillisecondsMeta,
        updatedAtUtcMilliseconds.isAcceptableOrUnknown(
          data['updated_at_utc_milliseconds']!,
          _updatedAtUtcMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      baseCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency_code'],
      )!,
      updatedAtUtcMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_milliseconds'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final int id;
  final String baseCurrencyCode;
  final int updatedAtUtcMilliseconds;
  const AppPreference({
    required this.id,
    required this.baseCurrencyCode,
    required this.updatedAtUtcMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_currency_code'] = Variable<String>(baseCurrencyCode);
    map['updated_at_utc_milliseconds'] = Variable<int>(
      updatedAtUtcMilliseconds,
    );
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      id: Value(id),
      baseCurrencyCode: Value(baseCurrencyCode),
      updatedAtUtcMilliseconds: Value(updatedAtUtcMilliseconds),
    );
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      id: serializer.fromJson<int>(json['id']),
      baseCurrencyCode: serializer.fromJson<String>(json['baseCurrencyCode']),
      updatedAtUtcMilliseconds: serializer.fromJson<int>(
        json['updatedAtUtcMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseCurrencyCode': serializer.toJson<String>(baseCurrencyCode),
      'updatedAtUtcMilliseconds': serializer.toJson<int>(
        updatedAtUtcMilliseconds,
      ),
    };
  }

  AppPreference copyWith({
    int? id,
    String? baseCurrencyCode,
    int? updatedAtUtcMilliseconds,
  }) => AppPreference(
    id: id ?? this.id,
    baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
    updatedAtUtcMilliseconds:
        updatedAtUtcMilliseconds ?? this.updatedAtUtcMilliseconds,
  );
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      id: data.id.present ? data.id.value : this.id,
      baseCurrencyCode: data.baseCurrencyCode.present
          ? data.baseCurrencyCode.value
          : this.baseCurrencyCode,
      updatedAtUtcMilliseconds: data.updatedAtUtcMilliseconds.present
          ? data.updatedAtUtcMilliseconds.value
          : this.updatedAtUtcMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('updatedAtUtcMilliseconds: $updatedAtUtcMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, baseCurrencyCode, updatedAtUtcMilliseconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.id == this.id &&
          other.baseCurrencyCode == this.baseCurrencyCode &&
          other.updatedAtUtcMilliseconds == this.updatedAtUtcMilliseconds);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<int> id;
  final Value<String> baseCurrencyCode;
  final Value<int> updatedAtUtcMilliseconds;
  const AppPreferencesCompanion({
    this.id = const Value.absent(),
    this.baseCurrencyCode = const Value.absent(),
    this.updatedAtUtcMilliseconds = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required String baseCurrencyCode,
    required int updatedAtUtcMilliseconds,
  }) : baseCurrencyCode = Value(baseCurrencyCode),
       updatedAtUtcMilliseconds = Value(updatedAtUtcMilliseconds);
  static Insertable<AppPreference> custom({
    Expression<int>? id,
    Expression<String>? baseCurrencyCode,
    Expression<int>? updatedAtUtcMilliseconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseCurrencyCode != null) 'base_currency_code': baseCurrencyCode,
      if (updatedAtUtcMilliseconds != null)
        'updated_at_utc_milliseconds': updatedAtUtcMilliseconds,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? baseCurrencyCode,
    Value<int>? updatedAtUtcMilliseconds,
  }) {
    return AppPreferencesCompanion(
      id: id ?? this.id,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      updatedAtUtcMilliseconds:
          updatedAtUtcMilliseconds ?? this.updatedAtUtcMilliseconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseCurrencyCode.present) {
      map['base_currency_code'] = Variable<String>(baseCurrencyCode.value);
    }
    if (updatedAtUtcMilliseconds.present) {
      map['updated_at_utc_milliseconds'] = Variable<int>(
        updatedAtUtcMilliseconds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('updatedAtUtcMilliseconds: $updatedAtUtcMilliseconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final Index expensesOccurredAtUtc = Index(
    'expenses_occurred_at_utc',
    'CREATE INDEX expenses_occurred_at_utc ON expenses (occurred_at_utc_milliseconds)',
  );
  late final Index expensesCurrencyCode = Index(
    'expenses_currency_code',
    'CREATE INDEX expenses_currency_code ON expenses (currency_code)',
  );
  late final Index expensesCategoryId = Index(
    'expenses_category_id',
    'CREATE INDEX expenses_category_id ON expenses (category_id)',
  );
  late final Index exchangeRatesRequestedDate = Index(
    'exchange_rates_requested_date',
    'CREATE INDEX exchange_rates_requested_date ON exchange_rates (requested_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    expenses,
    exchangeRates,
    appPreferences,
    expensesOccurredAtUtc,
    expensesCurrencyCode,
    expensesCategoryId,
    exchangeRatesRequestedDate,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      Value<String?> parentId,
      required String name,
      required int sortOrder,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> name,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$AppDatabase db) =>
      db.categories.createAlias('categories__parent_id__categories__id');

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'categories__id__expenses__category_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool parentId, bool expensesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required int sortOrder,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$CategoriesTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$CategoriesTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Expense
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool parentId, bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int amountMinor,
      required String currencyCode,
      required String categoryId,
      required int occurredAtUtcMilliseconds,
      required int occurredTimezoneOffsetMinutes,
      Value<String?> note,
      required int createdAtUtcMilliseconds,
      required int updatedAtUtcMilliseconds,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> categoryId,
      Value<int> occurredAtUtcMilliseconds,
      Value<int> occurredTimezoneOffsetMinutes,
      Value<String?> note,
      Value<int> createdAtUtcMilliseconds,
      Value<int> updatedAtUtcMilliseconds,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('expenses__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtUtcMilliseconds => $composableBuilder(
    column: $table.occurredAtUtcMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredTimezoneOffsetMinutes => $composableBuilder(
    column: $table.occurredTimezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMilliseconds => $composableBuilder(
    column: $table.createdAtUtcMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtUtcMilliseconds => $composableBuilder(
    column: $table.occurredAtUtcMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredTimezoneOffsetMinutes => $composableBuilder(
    column: $table.occurredTimezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMilliseconds => $composableBuilder(
    column: $table.createdAtUtcMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtUtcMilliseconds => $composableBuilder(
    column: $table.occurredAtUtcMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredTimezoneOffsetMinutes => $composableBuilder(
    column: $table.occurredTimezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMilliseconds => $composableBuilder(
    column: $table.createdAtUtcMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> occurredAtUtcMilliseconds = const Value.absent(),
                Value<int> occurredTimezoneOffsetMinutes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtUtcMilliseconds = const Value.absent(),
                Value<int> updatedAtUtcMilliseconds = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                categoryId: categoryId,
                occurredAtUtcMilliseconds: occurredAtUtcMilliseconds,
                occurredTimezoneOffsetMinutes: occurredTimezoneOffsetMinutes,
                note: note,
                createdAtUtcMilliseconds: createdAtUtcMilliseconds,
                updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountMinor,
                required String currencyCode,
                required String categoryId,
                required int occurredAtUtcMilliseconds,
                required int occurredTimezoneOffsetMinutes,
                Value<String?> note = const Value.absent(),
                required int createdAtUtcMilliseconds,
                required int updatedAtUtcMilliseconds,
              }) => ExpensesCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                categoryId: categoryId,
                occurredAtUtcMilliseconds: occurredAtUtcMilliseconds,
                occurredTimezoneOffsetMinutes: occurredTimezoneOffsetMinutes,
                note: note,
                createdAtUtcMilliseconds: createdAtUtcMilliseconds,
                updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ExpensesTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      required String requestedDate,
      required String sourceDate,
      required String baseCurrencyCode,
      required String quoteCurrencyCode,
      required int scaledRate,
      required int fetchedAtUtcMilliseconds,
      Value<int> rowid,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<String> requestedDate,
      Value<String> sourceDate,
      Value<String> baseCurrencyCode,
      Value<String> quoteCurrencyCode,
      Value<int> scaledRate,
      Value<int> fetchedAtUtcMilliseconds,
      Value<int> rowid,
    });

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrencyCode => $composableBuilder(
    column: $table.quoteCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scaledRate => $composableBuilder(
    column: $table.scaledRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtUtcMilliseconds => $composableBuilder(
    column: $table.fetchedAtUtcMilliseconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrencyCode => $composableBuilder(
    column: $table.quoteCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scaledRate => $composableBuilder(
    column: $table.scaledRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtUtcMilliseconds => $composableBuilder(
    column: $table.fetchedAtUtcMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrencyCode => $composableBuilder(
    column: $table.quoteCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scaledRate => $composableBuilder(
    column: $table.scaledRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAtUtcMilliseconds => $composableBuilder(
    column: $table.fetchedAtUtcMilliseconds,
    builder: (column) => column,
  );
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (
            ExchangeRate,
            BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
          ),
          ExchangeRate,
          PrefetchHooks Function()
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> requestedDate = const Value.absent(),
                Value<String> sourceDate = const Value.absent(),
                Value<String> baseCurrencyCode = const Value.absent(),
                Value<String> quoteCurrencyCode = const Value.absent(),
                Value<int> scaledRate = const Value.absent(),
                Value<int> fetchedAtUtcMilliseconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion(
                requestedDate: requestedDate,
                sourceDate: sourceDate,
                baseCurrencyCode: baseCurrencyCode,
                quoteCurrencyCode: quoteCurrencyCode,
                scaledRate: scaledRate,
                fetchedAtUtcMilliseconds: fetchedAtUtcMilliseconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestedDate,
                required String sourceDate,
                required String baseCurrencyCode,
                required String quoteCurrencyCode,
                required int scaledRate,
                required int fetchedAtUtcMilliseconds,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion.insert(
                requestedDate: requestedDate,
                sourceDate: sourceDate,
                baseCurrencyCode: baseCurrencyCode,
                quoteCurrencyCode: quoteCurrencyCode,
                scaledRate: scaledRate,
                fetchedAtUtcMilliseconds: fetchedAtUtcMilliseconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (
        ExchangeRate,
        BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
      ),
      ExchangeRate,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<int> id,
      required String baseCurrencyCode,
      required int updatedAtUtcMilliseconds,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<int> id,
      Value<String> baseCurrencyCode,
      Value<int> updatedAtUtcMilliseconds,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMilliseconds => $composableBuilder(
    column: $table.updatedAtUtcMilliseconds,
    builder: (column) => column,
  );
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> baseCurrencyCode = const Value.absent(),
                Value<int> updatedAtUtcMilliseconds = const Value.absent(),
              }) => AppPreferencesCompanion(
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String baseCurrencyCode,
                required int updatedAtUtcMilliseconds,
              }) => AppPreferencesCompanion.insert(
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}

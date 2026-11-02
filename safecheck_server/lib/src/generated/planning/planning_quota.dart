/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// Server-only counters. Trip text and model responses are never stored here.
abstract class PlanningQuota
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PlanningQuota._({
    this.id,
    required this.ownerId,
    required this.windowStartedAt,
    required this.windowCount,
    required this.dayStartedAt,
    required this.dayCount,
  });

  factory PlanningQuota({
    int? id,
    required String ownerId,
    required DateTime windowStartedAt,
    required int windowCount,
    required DateTime dayStartedAt,
    required int dayCount,
  }) = _PlanningQuotaImpl;

  factory PlanningQuota.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlanningQuota(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      windowStartedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['windowStartedAt'],
      ),
      windowCount: jsonSerialization['windowCount'] as int,
      dayStartedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['dayStartedAt'],
      ),
      dayCount: jsonSerialization['dayCount'] as int,
    );
  }

  static final t = PlanningQuotaTable();

  static const db = PlanningQuotaRepository._();

  @override
  int? id;

  String ownerId;

  DateTime windowStartedAt;

  int windowCount;

  DateTime dayStartedAt;

  int dayCount;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PlanningQuota]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlanningQuota copyWith({
    int? id,
    String? ownerId,
    DateTime? windowStartedAt,
    int? windowCount,
    DateTime? dayStartedAt,
    int? dayCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlanningQuota',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'windowStartedAt': windowStartedAt.toJson(),
      'windowCount': windowCount,
      'dayStartedAt': dayStartedAt.toJson(),
      'dayCount': dayCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PlanningQuotaInclude include() {
    return PlanningQuotaInclude._();
  }

  static PlanningQuotaIncludeList includeList({
    _is.WhereExpressionBuilder<PlanningQuotaTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    PlanningQuotaInclude? include,
  }) {
    return PlanningQuotaIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlanningQuotaImpl extends PlanningQuota {
  _PlanningQuotaImpl({
    int? id,
    required String ownerId,
    required DateTime windowStartedAt,
    required int windowCount,
    required DateTime dayStartedAt,
    required int dayCount,
  }) : super._(
         id: id,
         ownerId: ownerId,
         windowStartedAt: windowStartedAt,
         windowCount: windowCount,
         dayStartedAt: dayStartedAt,
         dayCount: dayCount,
       );

  /// Returns a shallow copy of this [PlanningQuota]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlanningQuota copyWith({
    Object? id = _Undefined,
    String? ownerId,
    DateTime? windowStartedAt,
    int? windowCount,
    DateTime? dayStartedAt,
    int? dayCount,
  }) {
    return PlanningQuota(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      windowStartedAt: windowStartedAt ?? this.windowStartedAt,
      windowCount: windowCount ?? this.windowCount,
      dayStartedAt: dayStartedAt ?? this.dayStartedAt,
      dayCount: dayCount ?? this.dayCount,
    );
  }
}

class PlanningQuotaUpdateTable extends _is.UpdateTable<PlanningQuotaTable> {
  PlanningQuotaUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> windowStartedAt(DateTime value) =>
      _is.ColumnValue(
        table.windowStartedAt,
        value,
      );

  _is.ColumnValue<int, int> windowCount(int value) => _is.ColumnValue(
    table.windowCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dayStartedAt(DateTime value) =>
      _is.ColumnValue(
        table.dayStartedAt,
        value,
      );

  _is.ColumnValue<int, int> dayCount(int value) => _is.ColumnValue(
    table.dayCount,
    value,
  );
}

class PlanningQuotaTable extends _is.Table<int?> {
  PlanningQuotaTable({super.tableRelation})
    : super(tableName: 'planning_quota') {
    updateTable = PlanningQuotaUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    windowStartedAt = _is.ColumnDateTime(
      'windowStartedAt',
      this,
    );
    windowCount = _is.ColumnInt(
      'windowCount',
      this,
    );
    dayStartedAt = _is.ColumnDateTime(
      'dayStartedAt',
      this,
    );
    dayCount = _is.ColumnInt(
      'dayCount',
      this,
    );
  }

  late final PlanningQuotaUpdateTable updateTable;

  late final _is.ColumnString ownerId;

  late final _is.ColumnDateTime windowStartedAt;

  late final _is.ColumnInt windowCount;

  late final _is.ColumnDateTime dayStartedAt;

  late final _is.ColumnInt dayCount;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    windowStartedAt,
    windowCount,
    dayStartedAt,
    dayCount,
  ];
}

class PlanningQuotaInclude extends _is.IncludeObject {
  PlanningQuotaInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PlanningQuota.t;
}

class PlanningQuotaIncludeList extends _is.IncludeList {
  PlanningQuotaIncludeList._({
    _is.WhereExpressionBuilder<PlanningQuotaTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlanningQuota.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PlanningQuota.t;
}

class PlanningQuotaRepository {
  const PlanningQuotaRepository._();

  /// Returns a list of [PlanningQuota]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PlanningQuota>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlanningQuotaTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlanningQuota>(
      where: where?.call(PlanningQuota.t),
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PlanningQuota] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PlanningQuota?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlanningQuotaTable>? where,
    int? offset,
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlanningQuota>(
      where: where?.call(PlanningQuota.t),
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlanningQuota] by its [id] or null if no such row exists.
  Future<PlanningQuota?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlanningQuota>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlanningQuota]s in the list and returns the inserted rows.
  ///
  /// The returned [PlanningQuota]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> insert(
    _is.DatabaseSession session,
    List<PlanningQuota> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlanningQuota>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlanningQuota] and returns the inserted row.
  ///
  /// The returned [PlanningQuota] will have its `id` field set.
  Future<PlanningQuota> insertRow(
    _is.DatabaseSession session,
    PlanningQuota row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlanningQuota>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PlanningQuota]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [PlanningQuota]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> upsert(
    _is.DatabaseSession session,
    List<PlanningQuota> rows, {
    required _is.ColumnSelections<PlanningQuotaTable> conflictColumns,
    _is.ColumnSelections<PlanningQuotaTable>? updateColumns,
    _is.WhereExpressionBuilder<PlanningQuotaTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlanningQuota>(
      rows,
      conflictColumns: conflictColumns(PlanningQuota.t),
      updateColumns: updateColumns?.call(PlanningQuota.t),
      updateWhere: updateWhere?.call(PlanningQuota.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlanningQuota] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [PlanningQuota] will have its `id` field set.
  Future<PlanningQuota?> upsertRow(
    _is.DatabaseSession session,
    PlanningQuota row, {
    required _is.ColumnSelections<PlanningQuotaTable> conflictColumns,
    _is.ColumnSelections<PlanningQuotaTable>? updateColumns,
    _is.WhereExpressionBuilder<PlanningQuotaTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlanningQuota>(
      row,
      conflictColumns: conflictColumns(PlanningQuota.t),
      updateColumns: updateColumns?.call(PlanningQuota.t),
      updateWhere: updateWhere?.call(PlanningQuota.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlanningQuota]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> update(
    _is.DatabaseSession session,
    List<PlanningQuota> rows, {
    _is.ColumnSelections<PlanningQuotaTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlanningQuota>(
      rows,
      columns: columns?.call(PlanningQuota.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlanningQuota]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlanningQuota> updateRow(
    _is.DatabaseSession session,
    PlanningQuota row, {
    _is.ColumnSelections<PlanningQuotaTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlanningQuota>(
      row,
      columns: columns?.call(PlanningQuota.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlanningQuota] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlanningQuota?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PlanningQuotaUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlanningQuota>(
      id,
      columnValues: columnValues(PlanningQuota.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlanningQuota]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlanningQuotaUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PlanningQuotaTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlanningQuota>(
      columnValues: columnValues(PlanningQuota.t.updateTable),
      where: where(PlanningQuota.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlanningQuota]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> delete(
    _is.DatabaseSession session,
    List<PlanningQuota> rows, {
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlanningQuota>(
      rows,
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlanningQuota].
  Future<PlanningQuota> deleteRow(
    _is.DatabaseSession session,
    PlanningQuota row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlanningQuota>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlanningQuota>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlanningQuotaTable> where,
    _is.OrderByBuilder<PlanningQuotaTable>? orderBy,
    _is.OrderByListBuilder<PlanningQuotaTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlanningQuota>(
      where: where(PlanningQuota.t),
      orderBy: orderBy?.call(PlanningQuota.t),
      orderByList: orderByList?.call(PlanningQuota.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlanningQuotaTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlanningQuota>(
      where: where?.call(PlanningQuota.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlanningQuota] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlanningQuotaTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlanningQuota>(
      where: where(PlanningQuota.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

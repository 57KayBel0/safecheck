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

/// Link credentials are hashed at rest. Explicit consent is needed to resolve.
abstract class IncidentAccess
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  IncidentAccess._({
    this.id,
    required this.tokenHash,
    required this.ownerId,
    required this.alertId,
    required this.contactName,
    required this.canResolve,
    this.trackingUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory IncidentAccess({
    int? id,
    required String tokenHash,
    required String ownerId,
    required int alertId,
    required String contactName,
    required bool canResolve,
    String? trackingUrl,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _IncidentAccessImpl;

  factory IncidentAccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentAccess(
      id: jsonSerialization['id'] as int?,
      tokenHash: jsonSerialization['tokenHash'] as String,
      ownerId: jsonSerialization['ownerId'] as String,
      alertId: jsonSerialization['alertId'] as int,
      contactName: jsonSerialization['contactName'] as String,
      canResolve: _is.BoolJsonExtension.fromJson(
        jsonSerialization['canResolve'],
      ),
      trackingUrl: jsonSerialization['trackingUrl'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = IncidentAccessTable();

  static const db = IncidentAccessRepository._();

  @override
  int? id;

  String tokenHash;

  String ownerId;

  int alertId;

  String contactName;

  bool canResolve;

  String? trackingUrl;

  DateTime createdAt;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [IncidentAccess]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IncidentAccess copyWith({
    int? id,
    String? tokenHash,
    String? ownerId,
    int? alertId,
    String? contactName,
    bool? canResolve,
    String? trackingUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentAccess',
      if (id != null) 'id': id,
      'tokenHash': tokenHash,
      'ownerId': ownerId,
      'alertId': alertId,
      'contactName': contactName,
      'canResolve': canResolve,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static IncidentAccessInclude include() {
    return IncidentAccessInclude._();
  }

  static IncidentAccessIncludeList includeList({
    _is.WhereExpressionBuilder<IncidentAccessTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    IncidentAccessInclude? include,
  }) {
    return IncidentAccessIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentAccessImpl extends IncidentAccess {
  _IncidentAccessImpl({
    int? id,
    required String tokenHash,
    required String ownerId,
    required int alertId,
    required String contactName,
    required bool canResolve,
    String? trackingUrl,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         tokenHash: tokenHash,
         ownerId: ownerId,
         alertId: alertId,
         contactName: contactName,
         canResolve: canResolve,
         trackingUrl: trackingUrl,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [IncidentAccess]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IncidentAccess copyWith({
    Object? id = _Undefined,
    String? tokenHash,
    String? ownerId,
    int? alertId,
    String? contactName,
    bool? canResolve,
    Object? trackingUrl = _Undefined,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return IncidentAccess(
      id: id is int? ? id : this.id,
      tokenHash: tokenHash ?? this.tokenHash,
      ownerId: ownerId ?? this.ownerId,
      alertId: alertId ?? this.alertId,
      contactName: contactName ?? this.contactName,
      canResolve: canResolve ?? this.canResolve,
      trackingUrl: trackingUrl is String? ? trackingUrl : this.trackingUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class IncidentAccessUpdateTable extends _is.UpdateTable<IncidentAccessTable> {
  IncidentAccessUpdateTable(super.table);

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<int, int> alertId(int value) => _is.ColumnValue(
    table.alertId,
    value,
  );

  _is.ColumnValue<String, String> contactName(String value) => _is.ColumnValue(
    table.contactName,
    value,
  );

  _is.ColumnValue<bool, bool> canResolve(bool value) => _is.ColumnValue(
    table.canResolve,
    value,
  );

  _is.ColumnValue<String, String> trackingUrl(String? value) => _is.ColumnValue(
    table.trackingUrl,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class IncidentAccessTable extends _is.Table<int?> {
  IncidentAccessTable({super.tableRelation})
    : super(tableName: 'incident_access') {
    updateTable = IncidentAccessUpdateTable(this);
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    alertId = _is.ColumnInt(
      'alertId',
      this,
    );
    contactName = _is.ColumnString(
      'contactName',
      this,
    );
    canResolve = _is.ColumnBool(
      'canResolve',
      this,
    );
    trackingUrl = _is.ColumnString(
      'trackingUrl',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final IncidentAccessUpdateTable updateTable;

  late final _is.ColumnString tokenHash;

  late final _is.ColumnString ownerId;

  late final _is.ColumnInt alertId;

  late final _is.ColumnString contactName;

  late final _is.ColumnBool canResolve;

  late final _is.ColumnString trackingUrl;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    tokenHash,
    ownerId,
    alertId,
    contactName,
    canResolve,
    trackingUrl,
    createdAt,
    expiresAt,
  ];
}

class IncidentAccessInclude extends _is.IncludeObject {
  IncidentAccessInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => IncidentAccess.t;
}

class IncidentAccessIncludeList extends _is.IncludeList {
  IncidentAccessIncludeList._({
    _is.WhereExpressionBuilder<IncidentAccessTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IncidentAccess.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => IncidentAccess.t;
}

class IncidentAccessRepository {
  const IncidentAccessRepository._();

  /// Returns a list of [IncidentAccess]s matching the given query parameters.
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
  Future<List<IncidentAccess>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAccessTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IncidentAccess>(
      where: where?.call(IncidentAccess.t),
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IncidentAccess] matching the given query parameters.
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
  Future<IncidentAccess?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAccessTable>? where,
    int? offset,
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IncidentAccess>(
      where: where?.call(IncidentAccess.t),
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IncidentAccess] by its [id] or null if no such row exists.
  Future<IncidentAccess?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IncidentAccess>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IncidentAccess]s in the list and returns the inserted rows.
  ///
  /// The returned [IncidentAccess]s will have their `id` fields set.
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
  Future<List<IncidentAccess>> insert(
    _is.DatabaseSession session,
    List<IncidentAccess> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<IncidentAccess>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [IncidentAccess] and returns the inserted row.
  ///
  /// The returned [IncidentAccess] will have its `id` field set.
  Future<IncidentAccess> insertRow(
    _is.DatabaseSession session,
    IncidentAccess row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<IncidentAccess>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [IncidentAccess]s in the list and returns the resulting rows.
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
  /// The returned [IncidentAccess]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAccess>> upsert(
    _is.DatabaseSession session,
    List<IncidentAccess> rows, {
    required _is.ColumnSelections<IncidentAccessTable> conflictColumns,
    _is.ColumnSelections<IncidentAccessTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentAccessTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<IncidentAccess>(
      rows,
      conflictColumns: conflictColumns(IncidentAccess.t),
      updateColumns: updateColumns?.call(IncidentAccess.t),
      updateWhere: updateWhere?.call(IncidentAccess.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [IncidentAccess] and returns the resulting row.
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
  /// The returned [IncidentAccess] will have its `id` field set.
  Future<IncidentAccess?> upsertRow(
    _is.DatabaseSession session,
    IncidentAccess row, {
    required _is.ColumnSelections<IncidentAccessTable> conflictColumns,
    _is.ColumnSelections<IncidentAccessTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentAccessTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<IncidentAccess>(
      row,
      conflictColumns: conflictColumns(IncidentAccess.t),
      updateColumns: updateColumns?.call(IncidentAccess.t),
      updateWhere: updateWhere?.call(IncidentAccess.t),
      transaction: transaction,
    );
  }

  /// Updates all [IncidentAccess]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAccess>> update(
    _is.DatabaseSession session,
    List<IncidentAccess> rows, {
    _is.ColumnSelections<IncidentAccessTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<IncidentAccess>(
      rows,
      columns: columns?.call(IncidentAccess.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [IncidentAccess]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IncidentAccess> updateRow(
    _is.DatabaseSession session,
    IncidentAccess row, {
    _is.ColumnSelections<IncidentAccessTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<IncidentAccess>(
      row,
      columns: columns?.call(IncidentAccess.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IncidentAccess] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IncidentAccess?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IncidentAccessUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<IncidentAccess>(
      id,
      columnValues: columnValues(IncidentAccess.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IncidentAccess]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IncidentAccess>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IncidentAccessUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IncidentAccessTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<IncidentAccess>(
      columnValues: columnValues(IncidentAccess.t.updateTable),
      where: where(IncidentAccess.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [IncidentAccess]s in the list and returns the deleted rows.
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
  Future<List<IncidentAccess>> delete(
    _is.DatabaseSession session,
    List<IncidentAccess> rows, {
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<IncidentAccess>(
      rows,
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [IncidentAccess].
  Future<IncidentAccess> deleteRow(
    _is.DatabaseSession session,
    IncidentAccess row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IncidentAccess>(
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
  Future<List<IncidentAccess>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentAccessTable> where,
    _is.OrderByBuilder<IncidentAccessTable>? orderBy,
    _is.OrderByListBuilder<IncidentAccessTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<IncidentAccess>(
      where: where(IncidentAccess.t),
      orderBy: orderBy?.call(IncidentAccess.t),
      orderByList: orderByList?.call(IncidentAccess.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentAccessTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<IncidentAccess>(
      where: where?.call(IncidentAccess.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IncidentAccess] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentAccessTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IncidentAccess>(
      where: where(IncidentAccess.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

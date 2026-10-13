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

/// A secret per-contact link to a trip's location page. Created when a trip
/// starts with location sharing on. Whether it currently shows a location
/// depends on the trip's sharing mode and state (see TrackingService).
abstract class TrackingLink
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TrackingLink._({
    this.id,
    required this.token,
    required this.ownerId,
    required this.tripId,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
  });

  factory TrackingLink({
    int? id,
    required String token,
    required String ownerId,
    required int tripId,
    required String contactName,
    required String contactPhone,
    required DateTime createdAt,
  }) = _TrackingLinkImpl;

  factory TrackingLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrackingLink(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      contactName: jsonSerialization['contactName'] as String,
      contactPhone: jsonSerialization['contactPhone'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = TrackingLinkTable();

  static const db = TrackingLinkRepository._();

  @override
  int? id;

  /// Unguessable token in the URL. No endpoint returns this model; the
  /// owner only receives the share URL through [TrackingLinkInfo].
  String token;

  String ownerId;

  int tripId;

  String contactName;

  String contactPhone;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TrackingLink]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TrackingLink copyWith({
    int? id,
    String? token,
    String? ownerId,
    int? tripId,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrackingLink',
      if (id != null) 'id': id,
      'token': token,
      'ownerId': ownerId,
      'tripId': tripId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrackingLink',
      if (id != null) 'id': id,
      'token': token,
      'ownerId': ownerId,
      'tripId': tripId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toJson(),
    };
  }

  static TrackingLinkInclude include() {
    return TrackingLinkInclude._();
  }

  static TrackingLinkIncludeList includeList({
    _is.WhereExpressionBuilder<TrackingLinkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    TrackingLinkInclude? include,
  }) {
    return TrackingLinkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TrackingLinkImpl extends TrackingLink {
  _TrackingLinkImpl({
    int? id,
    required String token,
    required String ownerId,
    required int tripId,
    required String contactName,
    required String contactPhone,
    required DateTime createdAt,
  }) : super._(
         id: id,
         token: token,
         ownerId: ownerId,
         tripId: tripId,
         contactName: contactName,
         contactPhone: contactPhone,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TrackingLink]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TrackingLink copyWith({
    Object? id = _Undefined,
    String? token,
    String? ownerId,
    int? tripId,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
  }) {
    return TrackingLink(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TrackingLinkUpdateTable extends _is.UpdateTable<TrackingLinkTable> {
  TrackingLinkUpdateTable(super.table);

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<int, int> tripId(int value) => _is.ColumnValue(
    table.tripId,
    value,
  );

  _is.ColumnValue<String, String> contactName(String value) => _is.ColumnValue(
    table.contactName,
    value,
  );

  _is.ColumnValue<String, String> contactPhone(String value) => _is.ColumnValue(
    table.contactPhone,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TrackingLinkTable extends _is.Table<int?> {
  TrackingLinkTable({super.tableRelation}) : super(tableName: 'tracking_link') {
    updateTable = TrackingLinkUpdateTable(this);
    token = _is.ColumnString(
      'token',
      this,
    );
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    tripId = _is.ColumnInt(
      'tripId',
      this,
    );
    contactName = _is.ColumnString(
      'contactName',
      this,
    );
    contactPhone = _is.ColumnString(
      'contactPhone',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final TrackingLinkUpdateTable updateTable;

  /// Unguessable token in the URL. No endpoint returns this model; the
  /// owner only receives the share URL through [TrackingLinkInfo].
  late final _is.ColumnString token;

  late final _is.ColumnString ownerId;

  late final _is.ColumnInt tripId;

  late final _is.ColumnString contactName;

  late final _is.ColumnString contactPhone;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    token,
    ownerId,
    tripId,
    contactName,
    contactPhone,
    createdAt,
  ];
}

class TrackingLinkInclude extends _is.IncludeObject {
  TrackingLinkInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TrackingLink.t;
}

class TrackingLinkIncludeList extends _is.IncludeList {
  TrackingLinkIncludeList._({
    _is.WhereExpressionBuilder<TrackingLinkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TrackingLink.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TrackingLink.t;
}

class TrackingLinkRepository {
  const TrackingLinkRepository._();

  /// Returns a list of [TrackingLink]s matching the given query parameters.
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
  Future<List<TrackingLink>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrackingLinkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TrackingLink>(
      where: where?.call(TrackingLink.t),
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TrackingLink] matching the given query parameters.
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
  Future<TrackingLink?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrackingLinkTable>? where,
    int? offset,
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TrackingLink>(
      where: where?.call(TrackingLink.t),
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TrackingLink] by its [id] or null if no such row exists.
  Future<TrackingLink?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TrackingLink>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TrackingLink]s in the list and returns the inserted rows.
  ///
  /// The returned [TrackingLink]s will have their `id` fields set.
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
  Future<List<TrackingLink>> insert(
    _is.DatabaseSession session,
    List<TrackingLink> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TrackingLink>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TrackingLink] and returns the inserted row.
  ///
  /// The returned [TrackingLink] will have its `id` field set.
  Future<TrackingLink> insertRow(
    _is.DatabaseSession session,
    TrackingLink row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TrackingLink>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TrackingLink]s in the list and returns the resulting rows.
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
  /// The returned [TrackingLink]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrackingLink>> upsert(
    _is.DatabaseSession session,
    List<TrackingLink> rows, {
    required _is.ColumnSelections<TrackingLinkTable> conflictColumns,
    _is.ColumnSelections<TrackingLinkTable>? updateColumns,
    _is.WhereExpressionBuilder<TrackingLinkTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TrackingLink>(
      rows,
      conflictColumns: conflictColumns(TrackingLink.t),
      updateColumns: updateColumns?.call(TrackingLink.t),
      updateWhere: updateWhere?.call(TrackingLink.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TrackingLink] and returns the resulting row.
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
  /// The returned [TrackingLink] will have its `id` field set.
  Future<TrackingLink?> upsertRow(
    _is.DatabaseSession session,
    TrackingLink row, {
    required _is.ColumnSelections<TrackingLinkTable> conflictColumns,
    _is.ColumnSelections<TrackingLinkTable>? updateColumns,
    _is.WhereExpressionBuilder<TrackingLinkTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TrackingLink>(
      row,
      conflictColumns: conflictColumns(TrackingLink.t),
      updateColumns: updateColumns?.call(TrackingLink.t),
      updateWhere: updateWhere?.call(TrackingLink.t),
      transaction: transaction,
    );
  }

  /// Updates all [TrackingLink]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrackingLink>> update(
    _is.DatabaseSession session,
    List<TrackingLink> rows, {
    _is.ColumnSelections<TrackingLinkTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TrackingLink>(
      rows,
      columns: columns?.call(TrackingLink.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TrackingLink]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TrackingLink> updateRow(
    _is.DatabaseSession session,
    TrackingLink row, {
    _is.ColumnSelections<TrackingLinkTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TrackingLink>(
      row,
      columns: columns?.call(TrackingLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TrackingLink] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TrackingLink?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TrackingLinkUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TrackingLink>(
      id,
      columnValues: columnValues(TrackingLink.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TrackingLink]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrackingLink>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TrackingLinkUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TrackingLinkTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TrackingLink>(
      columnValues: columnValues(TrackingLink.t.updateTable),
      where: where(TrackingLink.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TrackingLink]s in the list and returns the deleted rows.
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
  Future<List<TrackingLink>> delete(
    _is.DatabaseSession session,
    List<TrackingLink> rows, {
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TrackingLink>(
      rows,
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TrackingLink].
  Future<TrackingLink> deleteRow(
    _is.DatabaseSession session,
    TrackingLink row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TrackingLink>(
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
  Future<List<TrackingLink>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TrackingLinkTable> where,
    _is.OrderByBuilder<TrackingLinkTable>? orderBy,
    _is.OrderByListBuilder<TrackingLinkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TrackingLink>(
      where: where(TrackingLink.t),
      orderBy: orderBy?.call(TrackingLink.t),
      orderByList: orderByList?.call(TrackingLink.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrackingLinkTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TrackingLink>(
      where: where?.call(TrackingLink.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TrackingLink] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TrackingLinkTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TrackingLink>(
      where: where(TrackingLink.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

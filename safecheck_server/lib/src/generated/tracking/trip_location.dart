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

/// One GPS fix reported by the traveller's phone during a trip.
abstract class TripLocation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TripLocation._({
    this.id,
    required this.ownerId,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
    required this.receivedAt,
  });

  factory TripLocation({
    int? id,
    required String ownerId,
    required int tripId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
    required DateTime receivedAt,
  }) = _TripLocationImpl;

  factory TripLocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return TripLocation(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num?)?.toDouble(),
      recordedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  static final t = TripLocationTable();

  static const db = TripLocationRepository._();

  @override
  int? id;

  /// The auth user identifier (UUID) of the traveller.
  String ownerId;

  int tripId;

  double latitude;

  double longitude;

  /// Horizontal accuracy radius in metres, if the device reported one.
  double? accuracyMeters;

  /// When the device took the fix.
  DateTime recordedAt;

  /// When the server stored it.
  DateTime receivedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TripLocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TripLocation copyWith({
    int? id,
    String? ownerId,
    int? tripId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? recordedAt,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TripLocation',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TripLocation',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  static TripLocationInclude include() {
    return TripLocationInclude._();
  }

  static TripLocationIncludeList includeList({
    _is.WhereExpressionBuilder<TripLocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    TripLocationInclude? include,
  }) {
    return TripLocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripLocationImpl extends TripLocation {
  _TripLocationImpl({
    int? id,
    required String ownerId,
    required int tripId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         tripId: tripId,
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         recordedAt: recordedAt,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [TripLocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TripLocation copyWith({
    Object? id = _Undefined,
    String? ownerId,
    int? tripId,
    double? latitude,
    double? longitude,
    Object? accuracyMeters = _Undefined,
    DateTime? recordedAt,
    DateTime? receivedAt,
  }) {
    return TripLocation(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters is double?
          ? accuracyMeters
          : this.accuracyMeters,
      recordedAt: recordedAt ?? this.recordedAt,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class TripLocationUpdateTable extends _is.UpdateTable<TripLocationTable> {
  TripLocationUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<int, int> tripId(int value) => _is.ColumnValue(
    table.tripId,
    value,
  );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<double, double> accuracyMeters(double? value) =>
      _is.ColumnValue(
        table.accuracyMeters,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> recordedAt(DateTime value) =>
      _is.ColumnValue(
        table.recordedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class TripLocationTable extends _is.Table<int?> {
  TripLocationTable({super.tableRelation}) : super(tableName: 'trip_location') {
    updateTable = TripLocationUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    tripId = _is.ColumnInt(
      'tripId',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    accuracyMeters = _is.ColumnDouble(
      'accuracyMeters',
      this,
    );
    recordedAt = _is.ColumnDateTime(
      'recordedAt',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
  }

  late final TripLocationUpdateTable updateTable;

  /// The auth user identifier (UUID) of the traveller.
  late final _is.ColumnString ownerId;

  late final _is.ColumnInt tripId;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  /// Horizontal accuracy radius in metres, if the device reported one.
  late final _is.ColumnDouble accuracyMeters;

  /// When the device took the fix.
  late final _is.ColumnDateTime recordedAt;

  /// When the server stored it.
  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    tripId,
    latitude,
    longitude,
    accuracyMeters,
    recordedAt,
    receivedAt,
  ];
}

class TripLocationInclude extends _is.IncludeObject {
  TripLocationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TripLocation.t;
}

class TripLocationIncludeList extends _is.IncludeList {
  TripLocationIncludeList._({
    _is.WhereExpressionBuilder<TripLocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TripLocation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TripLocation.t;
}

class TripLocationRepository {
  const TripLocationRepository._();

  /// Returns a list of [TripLocation]s matching the given query parameters.
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
  Future<List<TripLocation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripLocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TripLocation>(
      where: where?.call(TripLocation.t),
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TripLocation] matching the given query parameters.
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
  Future<TripLocation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripLocationTable>? where,
    int? offset,
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TripLocation>(
      where: where?.call(TripLocation.t),
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TripLocation] by its [id] or null if no such row exists.
  Future<TripLocation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TripLocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TripLocation]s in the list and returns the inserted rows.
  ///
  /// The returned [TripLocation]s will have their `id` fields set.
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
  Future<List<TripLocation>> insert(
    _is.DatabaseSession session,
    List<TripLocation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TripLocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TripLocation] and returns the inserted row.
  ///
  /// The returned [TripLocation] will have its `id` field set.
  Future<TripLocation> insertRow(
    _is.DatabaseSession session,
    TripLocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TripLocation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TripLocation]s in the list and returns the resulting rows.
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
  /// The returned [TripLocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TripLocation>> upsert(
    _is.DatabaseSession session,
    List<TripLocation> rows, {
    required _is.ColumnSelections<TripLocationTable> conflictColumns,
    _is.ColumnSelections<TripLocationTable>? updateColumns,
    _is.WhereExpressionBuilder<TripLocationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TripLocation>(
      rows,
      conflictColumns: conflictColumns(TripLocation.t),
      updateColumns: updateColumns?.call(TripLocation.t),
      updateWhere: updateWhere?.call(TripLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TripLocation] and returns the resulting row.
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
  /// The returned [TripLocation] will have its `id` field set.
  Future<TripLocation?> upsertRow(
    _is.DatabaseSession session,
    TripLocation row, {
    required _is.ColumnSelections<TripLocationTable> conflictColumns,
    _is.ColumnSelections<TripLocationTable>? updateColumns,
    _is.WhereExpressionBuilder<TripLocationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TripLocation>(
      row,
      conflictColumns: conflictColumns(TripLocation.t),
      updateColumns: updateColumns?.call(TripLocation.t),
      updateWhere: updateWhere?.call(TripLocation.t),
      transaction: transaction,
    );
  }

  /// Updates all [TripLocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TripLocation>> update(
    _is.DatabaseSession session,
    List<TripLocation> rows, {
    _is.ColumnSelections<TripLocationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TripLocation>(
      rows,
      columns: columns?.call(TripLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TripLocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TripLocation> updateRow(
    _is.DatabaseSession session,
    TripLocation row, {
    _is.ColumnSelections<TripLocationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TripLocation>(
      row,
      columns: columns?.call(TripLocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TripLocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TripLocation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TripLocationUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TripLocation>(
      id,
      columnValues: columnValues(TripLocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TripLocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TripLocation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TripLocationUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TripLocationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TripLocation>(
      columnValues: columnValues(TripLocation.t.updateTable),
      where: where(TripLocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TripLocation]s in the list and returns the deleted rows.
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
  Future<List<TripLocation>> delete(
    _is.DatabaseSession session,
    List<TripLocation> rows, {
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TripLocation>(
      rows,
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TripLocation].
  Future<TripLocation> deleteRow(
    _is.DatabaseSession session,
    TripLocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TripLocation>(
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
  Future<List<TripLocation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TripLocationTable> where,
    _is.OrderByBuilder<TripLocationTable>? orderBy,
    _is.OrderByListBuilder<TripLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TripLocation>(
      where: where(TripLocation.t),
      orderBy: orderBy?.call(TripLocation.t),
      orderByList: orderByList?.call(TripLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripLocationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TripLocation>(
      where: where?.call(TripLocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TripLocation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TripLocationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TripLocation>(
      where: where(TripLocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

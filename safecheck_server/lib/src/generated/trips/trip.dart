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
import 'package:safecheck_server/src/generated/protocol.dart' as _iwfhb10e;
import 'package:serverpod/serverpod.dart' as _is;
import '../tracking/location_sharing.dart' as _ixmrytkl;
import '../trips/contact_snapshot.dart' as _i0udr1y1;
import '../trips/trip_status.dart' as _i7iygem4;
import '../trips/trip_type.dart' as _ix6rm8oc;

/// A trip with a check-in deadline.
abstract class Trip implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Trip._({
    this.id,
    required this.ownerId,
    this.activeOwnerId,
    required this.tripType,
    required this.description,
    required this.durationMinutes,
    required this.startedAt,
    required this.deadline,
    required this.status,
    this.endedAt,
    required this.contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) : locationSharing = locationSharing ?? _ixmrytkl.LocationSharing.off;

  factory Trip({
    int? id,
    required String ownerId,
    String? activeOwnerId,
    required _ix6rm8oc.TripType tripType,
    required String description,
    required int durationMinutes,
    required DateTime startedAt,
    required DateTime deadline,
    required _i7iygem4.TripStatus status,
    DateTime? endedAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) = _TripImpl;

  factory Trip.fromJson(Map<String, dynamic> jsonSerialization) {
    return Trip(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      activeOwnerId: jsonSerialization['activeOwnerId'] as String?,
      tripType: _ix6rm8oc.TripType.fromJson(
        (jsonSerialization['tripType'] as String),
      ),
      description: jsonSerialization['description'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      deadline: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['deadline'],
      ),
      status: _i7iygem4.TripStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      contacts: _iwfhb10e.Protocol()
          .deserialize<List<_i0udr1y1.ContactSnapshot>>(
            jsonSerialization['contacts'],
          ),
      locationSharing: jsonSerialization['locationSharing'] == null
          ? null
          : _ixmrytkl.LocationSharing.fromJson(
              (jsonSerialization['locationSharing'] as String),
            ),
    );
  }

  static final t = TripTable();

  static const db = TripRepository._();

  @override
  int? id;

  /// The auth user identifier (UUID) of the owner.
  String ownerId;

  /// Equals [ownerId] while the trip is active and is null afterwards. The
  /// unique index on this column lets the database guarantee that a user has
  /// at most one active trip (Postgres allows many NULLs in a unique index).
  String? activeOwnerId;

  _ix6rm8oc.TripType tripType;

  String description;

  int durationMinutes;

  DateTime startedAt;

  /// Server-computed time by which the owner must check in.
  DateTime deadline;

  _i7iygem4.TripStatus status;

  /// When the trip ended (check-in or missed deadline processed).
  DateTime? endedAt;

  /// Trusted contacts as they were when the trip started.
  List<_i0udr1y1.ContactSnapshot> contacts;

  /// Who may see this trip's location. Chosen when the trip starts.
  _ixmrytkl.LocationSharing locationSharing;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Trip copyWith({
    int? id,
    String? ownerId,
    String? activeOwnerId,
    _ix6rm8oc.TripType? tripType,
    String? description,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? deadline,
    _i7iygem4.TripStatus? status,
    DateTime? endedAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      if (activeOwnerId != null) 'activeOwnerId': activeOwnerId,
      'tripType': tripType.toJson(),
      'description': description,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toJson(),
      'deadline': deadline.toJson(),
      'status': status.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
      'locationSharing': locationSharing.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripType': tripType.toJson(),
      'description': description,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toJson(),
      'deadline': deadline.toJson(),
      'status': status.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'locationSharing': locationSharing.toJson(),
    };
  }

  static TripInclude include() {
    return TripInclude._();
  }

  static TripIncludeList includeList({
    _is.WhereExpressionBuilder<TripTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    TripInclude? include,
  }) {
    return TripIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripImpl extends Trip {
  _TripImpl({
    int? id,
    required String ownerId,
    String? activeOwnerId,
    required _ix6rm8oc.TripType tripType,
    required String description,
    required int durationMinutes,
    required DateTime startedAt,
    required DateTime deadline,
    required _i7iygem4.TripStatus status,
    DateTime? endedAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) : super._(
         id: id,
         ownerId: ownerId,
         activeOwnerId: activeOwnerId,
         tripType: tripType,
         description: description,
         durationMinutes: durationMinutes,
         startedAt: startedAt,
         deadline: deadline,
         status: status,
         endedAt: endedAt,
         contacts: contacts,
         locationSharing: locationSharing,
       );

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Trip copyWith({
    Object? id = _Undefined,
    String? ownerId,
    Object? activeOwnerId = _Undefined,
    _ix6rm8oc.TripType? tripType,
    String? description,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? deadline,
    _i7iygem4.TripStatus? status,
    Object? endedAt = _Undefined,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) {
    return Trip(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      activeOwnerId: activeOwnerId is String?
          ? activeOwnerId
          : this.activeOwnerId,
      tripType: tripType ?? this.tripType,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
      locationSharing: locationSharing ?? this.locationSharing,
    );
  }
}

class TripUpdateTable extends _is.UpdateTable<TripTable> {
  TripUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<String, String> activeOwnerId(String? value) =>
      _is.ColumnValue(
        table.activeOwnerId,
        value,
      );

  _is.ColumnValue<_ix6rm8oc.TripType, _ix6rm8oc.TripType> tripType(
    _ix6rm8oc.TripType value,
  ) => _is.ColumnValue(
    table.tripType,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> durationMinutes(int value) => _is.ColumnValue(
    table.durationMinutes,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startedAt(DateTime value) =>
      _is.ColumnValue(
        table.startedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> deadline(DateTime value) =>
      _is.ColumnValue(
        table.deadline,
        value,
      );

  _is.ColumnValue<_i7iygem4.TripStatus, _i7iygem4.TripStatus> status(
    _i7iygem4.TripStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> endedAt(DateTime? value) =>
      _is.ColumnValue(
        table.endedAt,
        value,
      );

  _is.ColumnValue<
    List<_i0udr1y1.ContactSnapshot>,
    List<_i0udr1y1.ContactSnapshot>
  >
  contacts(List<_i0udr1y1.ContactSnapshot> value) => _is.ColumnValue(
    table.contacts,
    value,
  );

  _is.ColumnValue<_ixmrytkl.LocationSharing, _ixmrytkl.LocationSharing>
  locationSharing(_ixmrytkl.LocationSharing value) => _is.ColumnValue(
    table.locationSharing,
    value,
  );
}

class TripTable extends _is.Table<int?> {
  TripTable({super.tableRelation}) : super(tableName: 'trip') {
    updateTable = TripUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    activeOwnerId = _is.ColumnString(
      'activeOwnerId',
      this,
    );
    tripType = _is.ColumnEnum(
      'tripType',
      this,
      _is.EnumSerialization.byName,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    durationMinutes = _is.ColumnInt(
      'durationMinutes',
      this,
    );
    startedAt = _is.ColumnDateTime(
      'startedAt',
      this,
    );
    deadline = _is.ColumnDateTime(
      'deadline',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    endedAt = _is.ColumnDateTime(
      'endedAt',
      this,
    );
    contacts = _is.ColumnSerializable<List<_i0udr1y1.ContactSnapshot>>(
      'contacts',
      this,
    );
    locationSharing = _is.ColumnEnum(
      'locationSharing',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
  }

  late final TripUpdateTable updateTable;

  /// The auth user identifier (UUID) of the owner.
  late final _is.ColumnString ownerId;

  /// Equals [ownerId] while the trip is active and is null afterwards. The
  /// unique index on this column lets the database guarantee that a user has
  /// at most one active trip (Postgres allows many NULLs in a unique index).
  late final _is.ColumnString activeOwnerId;

  late final _is.ColumnEnum<_ix6rm8oc.TripType> tripType;

  late final _is.ColumnString description;

  late final _is.ColumnInt durationMinutes;

  late final _is.ColumnDateTime startedAt;

  /// Server-computed time by which the owner must check in.
  late final _is.ColumnDateTime deadline;

  late final _is.ColumnEnum<_i7iygem4.TripStatus> status;

  /// When the trip ended (check-in or missed deadline processed).
  late final _is.ColumnDateTime endedAt;

  /// Trusted contacts as they were when the trip started.
  late final _is.ColumnSerializable<List<_i0udr1y1.ContactSnapshot>> contacts;

  /// Who may see this trip's location. Chosen when the trip starts.
  late final _is.ColumnEnum<_ixmrytkl.LocationSharing> locationSharing;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    activeOwnerId,
    tripType,
    description,
    durationMinutes,
    startedAt,
    deadline,
    status,
    endedAt,
    contacts,
    locationSharing,
  ];
}

class TripInclude extends _is.IncludeObject {
  TripInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Trip.t;
}

class TripIncludeList extends _is.IncludeList {
  TripIncludeList._({
    _is.WhereExpressionBuilder<TripTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Trip.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Trip.t;
}

class TripRepository {
  const TripRepository._();

  /// Returns a list of [Trip]s matching the given query parameters.
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
  Future<List<Trip>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Trip>(
      where: where?.call(Trip.t),
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Trip] matching the given query parameters.
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
  Future<Trip?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripTable>? where,
    int? offset,
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Trip>(
      where: where?.call(Trip.t),
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Trip] by its [id] or null if no such row exists.
  Future<Trip?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Trip>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Trip]s in the list and returns the inserted rows.
  ///
  /// The returned [Trip]s will have their `id` fields set.
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
  Future<List<Trip>> insert(
    _is.DatabaseSession session,
    List<Trip> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Trip>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Trip] and returns the inserted row.
  ///
  /// The returned [Trip] will have its `id` field set.
  Future<Trip> insertRow(
    _is.DatabaseSession session,
    Trip row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Trip>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Trip]s in the list and returns the resulting rows.
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
  /// The returned [Trip]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Trip>> upsert(
    _is.DatabaseSession session,
    List<Trip> rows, {
    required _is.ColumnSelections<TripTable> conflictColumns,
    _is.ColumnSelections<TripTable>? updateColumns,
    _is.WhereExpressionBuilder<TripTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Trip>(
      rows,
      conflictColumns: conflictColumns(Trip.t),
      updateColumns: updateColumns?.call(Trip.t),
      updateWhere: updateWhere?.call(Trip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Trip] and returns the resulting row.
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
  /// The returned [Trip] will have its `id` field set.
  Future<Trip?> upsertRow(
    _is.DatabaseSession session,
    Trip row, {
    required _is.ColumnSelections<TripTable> conflictColumns,
    _is.ColumnSelections<TripTable>? updateColumns,
    _is.WhereExpressionBuilder<TripTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Trip>(
      row,
      conflictColumns: conflictColumns(Trip.t),
      updateColumns: updateColumns?.call(Trip.t),
      updateWhere: updateWhere?.call(Trip.t),
      transaction: transaction,
    );
  }

  /// Updates all [Trip]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Trip>> update(
    _is.DatabaseSession session,
    List<Trip> rows, {
    _is.ColumnSelections<TripTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Trip>(
      rows,
      columns: columns?.call(Trip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Trip]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Trip> updateRow(
    _is.DatabaseSession session,
    Trip row, {
    _is.ColumnSelections<TripTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Trip>(
      row,
      columns: columns?.call(Trip.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Trip] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Trip?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TripUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Trip>(
      id,
      columnValues: columnValues(Trip.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Trip]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Trip>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TripUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TripTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Trip>(
      columnValues: columnValues(Trip.t.updateTable),
      where: where(Trip.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Trip]s in the list and returns the deleted rows.
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
  Future<List<Trip>> delete(
    _is.DatabaseSession session,
    List<Trip> rows, {
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Trip>(
      rows,
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Trip].
  Future<Trip> deleteRow(
    _is.DatabaseSession session,
    Trip row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Trip>(
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
  Future<List<Trip>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TripTable> where,
    _is.OrderByBuilder<TripTable>? orderBy,
    _is.OrderByListBuilder<TripTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Trip>(
      where: where(Trip.t),
      orderBy: orderBy?.call(Trip.t),
      orderByList: orderByList?.call(Trip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TripTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Trip>(
      where: where?.call(Trip.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Trip] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TripTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Trip>(
      where: where(Trip.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

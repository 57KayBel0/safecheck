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
import '../messaging/message_channel.dart' as _iz5739xg;
import '../messaging/message_status.dart' as _iogsv7ne;

/// A message to a trusted contact about a missed check-in.
///
/// Rows are written with status `pending` in the same transaction as the
/// alert (an outbox), then handed to the configured message sender. The only
/// sender today is the demo sender, which sends nothing and marks the message
/// `simulated`; the app labels those "Demo — SMS not sent" or
/// "Demo — WhatsApp not sent".
///
/// The table keeps its original name `simulated_sms` so existing rows are
/// preserved.
abstract class AlertMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AlertMessage._({
    this.id,
    required this.ownerId,
    required this.alertId,
    required this.tripId,
    required this.recipientName,
    required this.recipientPhone,
    required this.body,
    required this.createdAt,
    _iz5739xg.MessageChannel? channel,
    _iogsv7ne.MessageStatus? status,
    this.statusUpdatedAt,
    this.failureReason,
  }) : channel = channel ?? _iz5739xg.MessageChannel.sms,
       status = status ?? _iogsv7ne.MessageStatus.pending;

  factory AlertMessage({
    int? id,
    required String ownerId,
    required int alertId,
    required int tripId,
    required String recipientName,
    required String recipientPhone,
    required String body,
    required DateTime createdAt,
    _iz5739xg.MessageChannel? channel,
    _iogsv7ne.MessageStatus? status,
    DateTime? statusUpdatedAt,
    String? failureReason,
  }) = _AlertMessageImpl;

  factory AlertMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AlertMessage(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      alertId: jsonSerialization['alertId'] as int,
      tripId: jsonSerialization['tripId'] as int,
      recipientName: jsonSerialization['recipientName'] as String,
      recipientPhone: jsonSerialization['recipientPhone'] as String,
      body: jsonSerialization['body'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      channel: jsonSerialization['channel'] == null
          ? null
          : _iz5739xg.MessageChannel.fromJson(
              (jsonSerialization['channel'] as String),
            ),
      status: jsonSerialization['status'] == null
          ? null
          : _iogsv7ne.MessageStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      statusUpdatedAt: jsonSerialization['statusUpdatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['statusUpdatedAt'],
            ),
      failureReason: jsonSerialization['failureReason'] as String?,
    );
  }

  static final t = AlertMessageTable();

  static const db = AlertMessageRepository._();

  @override
  int? id;

  /// The auth user identifier (UUID) of the traveller.
  String ownerId;

  int alertId;

  int tripId;

  String recipientName;

  String recipientPhone;

  String body;

  DateTime createdAt;

  /// Channel the message is meant for. WhatsApp is only chosen for contacts
  /// who accepted their invite.
  _iz5739xg.MessageChannel channel;

  _iogsv7ne.MessageStatus status;

  /// When the sender last changed [status].
  DateTime? statusUpdatedAt;

  /// Error from the sender, if [status] is `failed`.
  String? failureReason;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AlertMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AlertMessage copyWith({
    int? id,
    String? ownerId,
    int? alertId,
    int? tripId,
    String? recipientName,
    String? recipientPhone,
    String? body,
    DateTime? createdAt,
    _iz5739xg.MessageChannel? channel,
    _iogsv7ne.MessageStatus? status,
    DateTime? statusUpdatedAt,
    String? failureReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AlertMessage',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'alertId': alertId,
      'tripId': tripId,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'body': body,
      'createdAt': createdAt.toJson(),
      'channel': channel.toJson(),
      'status': status.toJson(),
      if (statusUpdatedAt != null) 'statusUpdatedAt': statusUpdatedAt?.toJson(),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AlertMessage',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'alertId': alertId,
      'tripId': tripId,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'body': body,
      'createdAt': createdAt.toJson(),
      'channel': channel.toJson(),
      'status': status.toJson(),
      if (statusUpdatedAt != null) 'statusUpdatedAt': statusUpdatedAt?.toJson(),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }

  static AlertMessageInclude include() {
    return AlertMessageInclude._();
  }

  static AlertMessageIncludeList includeList({
    _is.WhereExpressionBuilder<AlertMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    AlertMessageInclude? include,
  }) {
    return AlertMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AlertMessageImpl extends AlertMessage {
  _AlertMessageImpl({
    int? id,
    required String ownerId,
    required int alertId,
    required int tripId,
    required String recipientName,
    required String recipientPhone,
    required String body,
    required DateTime createdAt,
    _iz5739xg.MessageChannel? channel,
    _iogsv7ne.MessageStatus? status,
    DateTime? statusUpdatedAt,
    String? failureReason,
  }) : super._(
         id: id,
         ownerId: ownerId,
         alertId: alertId,
         tripId: tripId,
         recipientName: recipientName,
         recipientPhone: recipientPhone,
         body: body,
         createdAt: createdAt,
         channel: channel,
         status: status,
         statusUpdatedAt: statusUpdatedAt,
         failureReason: failureReason,
       );

  /// Returns a shallow copy of this [AlertMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AlertMessage copyWith({
    Object? id = _Undefined,
    String? ownerId,
    int? alertId,
    int? tripId,
    String? recipientName,
    String? recipientPhone,
    String? body,
    DateTime? createdAt,
    _iz5739xg.MessageChannel? channel,
    _iogsv7ne.MessageStatus? status,
    Object? statusUpdatedAt = _Undefined,
    Object? failureReason = _Undefined,
  }) {
    return AlertMessage(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      alertId: alertId ?? this.alertId,
      tripId: tripId ?? this.tripId,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt is DateTime?
          ? statusUpdatedAt
          : this.statusUpdatedAt,
      failureReason: failureReason is String?
          ? failureReason
          : this.failureReason,
    );
  }
}

class AlertMessageUpdateTable extends _is.UpdateTable<AlertMessageTable> {
  AlertMessageUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<int, int> alertId(int value) => _is.ColumnValue(
    table.alertId,
    value,
  );

  _is.ColumnValue<int, int> tripId(int value) => _is.ColumnValue(
    table.tripId,
    value,
  );

  _is.ColumnValue<String, String> recipientName(String value) =>
      _is.ColumnValue(
        table.recipientName,
        value,
      );

  _is.ColumnValue<String, String> recipientPhone(String value) =>
      _is.ColumnValue(
        table.recipientPhone,
        value,
      );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<_iz5739xg.MessageChannel, _iz5739xg.MessageChannel> channel(
    _iz5739xg.MessageChannel value,
  ) => _is.ColumnValue(
    table.channel,
    value,
  );

  _is.ColumnValue<_iogsv7ne.MessageStatus, _iogsv7ne.MessageStatus> status(
    _iogsv7ne.MessageStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> statusUpdatedAt(DateTime? value) =>
      _is.ColumnValue(
        table.statusUpdatedAt,
        value,
      );

  _is.ColumnValue<String, String> failureReason(String? value) =>
      _is.ColumnValue(
        table.failureReason,
        value,
      );
}

class AlertMessageTable extends _is.Table<int?> {
  AlertMessageTable({super.tableRelation}) : super(tableName: 'simulated_sms') {
    updateTable = AlertMessageUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    alertId = _is.ColumnInt(
      'alertId',
      this,
    );
    tripId = _is.ColumnInt(
      'tripId',
      this,
    );
    recipientName = _is.ColumnString(
      'recipientName',
      this,
    );
    recipientPhone = _is.ColumnString(
      'recipientPhone',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    channel = _is.ColumnEnum(
      'channel',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    statusUpdatedAt = _is.ColumnDateTime(
      'statusUpdatedAt',
      this,
    );
    failureReason = _is.ColumnString(
      'failureReason',
      this,
    );
  }

  late final AlertMessageUpdateTable updateTable;

  /// The auth user identifier (UUID) of the traveller.
  late final _is.ColumnString ownerId;

  late final _is.ColumnInt alertId;

  late final _is.ColumnInt tripId;

  late final _is.ColumnString recipientName;

  late final _is.ColumnString recipientPhone;

  late final _is.ColumnString body;

  late final _is.ColumnDateTime createdAt;

  /// Channel the message is meant for. WhatsApp is only chosen for contacts
  /// who accepted their invite.
  late final _is.ColumnEnum<_iz5739xg.MessageChannel> channel;

  late final _is.ColumnEnum<_iogsv7ne.MessageStatus> status;

  /// When the sender last changed [status].
  late final _is.ColumnDateTime statusUpdatedAt;

  /// Error from the sender, if [status] is `failed`.
  late final _is.ColumnString failureReason;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    alertId,
    tripId,
    recipientName,
    recipientPhone,
    body,
    createdAt,
    channel,
    status,
    statusUpdatedAt,
    failureReason,
  ];
}

class AlertMessageInclude extends _is.IncludeObject {
  AlertMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AlertMessage.t;
}

class AlertMessageIncludeList extends _is.IncludeList {
  AlertMessageIncludeList._({
    _is.WhereExpressionBuilder<AlertMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AlertMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AlertMessage.t;
}

class AlertMessageRepository {
  const AlertMessageRepository._();

  /// Returns a list of [AlertMessage]s matching the given query parameters.
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
  Future<List<AlertMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlertMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AlertMessage>(
      where: where?.call(AlertMessage.t),
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AlertMessage] matching the given query parameters.
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
  Future<AlertMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlertMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AlertMessage>(
      where: where?.call(AlertMessage.t),
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AlertMessage] by its [id] or null if no such row exists.
  Future<AlertMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AlertMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AlertMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [AlertMessage]s will have their `id` fields set.
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
  Future<List<AlertMessage>> insert(
    _is.DatabaseSession session,
    List<AlertMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AlertMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AlertMessage] and returns the inserted row.
  ///
  /// The returned [AlertMessage] will have its `id` field set.
  Future<AlertMessage> insertRow(
    _is.DatabaseSession session,
    AlertMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AlertMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AlertMessage]s in the list and returns the resulting rows.
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
  /// The returned [AlertMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AlertMessage>> upsert(
    _is.DatabaseSession session,
    List<AlertMessage> rows, {
    required _is.ColumnSelections<AlertMessageTable> conflictColumns,
    _is.ColumnSelections<AlertMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AlertMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AlertMessage>(
      rows,
      conflictColumns: conflictColumns(AlertMessage.t),
      updateColumns: updateColumns?.call(AlertMessage.t),
      updateWhere: updateWhere?.call(AlertMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AlertMessage] and returns the resulting row.
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
  /// The returned [AlertMessage] will have its `id` field set.
  Future<AlertMessage?> upsertRow(
    _is.DatabaseSession session,
    AlertMessage row, {
    required _is.ColumnSelections<AlertMessageTable> conflictColumns,
    _is.ColumnSelections<AlertMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AlertMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AlertMessage>(
      row,
      conflictColumns: conflictColumns(AlertMessage.t),
      updateColumns: updateColumns?.call(AlertMessage.t),
      updateWhere: updateWhere?.call(AlertMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [AlertMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AlertMessage>> update(
    _is.DatabaseSession session,
    List<AlertMessage> rows, {
    _is.ColumnSelections<AlertMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AlertMessage>(
      rows,
      columns: columns?.call(AlertMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AlertMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AlertMessage> updateRow(
    _is.DatabaseSession session,
    AlertMessage row, {
    _is.ColumnSelections<AlertMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AlertMessage>(
      row,
      columns: columns?.call(AlertMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AlertMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AlertMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AlertMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AlertMessage>(
      id,
      columnValues: columnValues(AlertMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AlertMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AlertMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AlertMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AlertMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AlertMessage>(
      columnValues: columnValues(AlertMessage.t.updateTable),
      where: where(AlertMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AlertMessage]s in the list and returns the deleted rows.
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
  Future<List<AlertMessage>> delete(
    _is.DatabaseSession session,
    List<AlertMessage> rows, {
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AlertMessage>(
      rows,
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AlertMessage].
  Future<AlertMessage> deleteRow(
    _is.DatabaseSession session,
    AlertMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AlertMessage>(
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
  Future<List<AlertMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AlertMessageTable> where,
    _is.OrderByBuilder<AlertMessageTable>? orderBy,
    _is.OrderByListBuilder<AlertMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AlertMessage>(
      where: where(AlertMessage.t),
      orderBy: orderBy?.call(AlertMessage.t),
      orderByList: orderByList?.call(AlertMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlertMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AlertMessage>(
      where: where?.call(AlertMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AlertMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AlertMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AlertMessage>(
      where: where(AlertMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

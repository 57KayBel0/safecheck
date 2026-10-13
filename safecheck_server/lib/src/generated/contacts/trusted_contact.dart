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
import '../contacts/contact_opt_in_status.dart' as _ilcrz8k8;

/// A person who should be alerted when the owner misses a check-in.
/// A user can have at most five trusted contacts.
abstract class TrustedContact
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TrustedContact._({
    this.id,
    required this.ownerId,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    required this.createdAt,
    required this.updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    this.optInRespondedAt,
    this.inviteToken,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : optInStatus = optInStatus ?? _ilcrz8k8.ContactOptInStatus.pending,
       notifyByWhatsapp = notifyByWhatsapp ?? true,
       notifyBySms = notifyBySms ?? true;

  factory TrustedContact({
    int? id,
    required String ownerId,
    required String name,
    required String phoneNumber,
    String? relationship,
    required DateTime createdAt,
    required DateTime updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    String? inviteToken,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) = _TrustedContactImpl;

  factory TrustedContact.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrustedContact(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      name: jsonSerialization['name'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String,
      relationship: jsonSerialization['relationship'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      optInStatus: jsonSerialization['optInStatus'] == null
          ? null
          : _ilcrz8k8.ContactOptInStatus.fromJson(
              (jsonSerialization['optInStatus'] as String),
            ),
      optInRespondedAt: jsonSerialization['optInRespondedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['optInRespondedAt'],
            ),
      inviteToken: jsonSerialization['inviteToken'] as String?,
      notifyByWhatsapp: jsonSerialization['notifyByWhatsapp'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['notifyByWhatsapp'],
            ),
      notifyBySms: jsonSerialization['notifyBySms'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['notifyBySms']),
    );
  }

  static final t = TrustedContactTable();

  static const db = TrustedContactRepository._();

  @override
  int? id;

  /// The auth user identifier (UUID) of the owner.
  String ownerId;

  String name;

  /// South African phone number in E.164 format (+27...).
  String phoneNumber;

  /// Optional relationship, e.g. "Sister" or "Housemate".
  String? relationship;

  DateTime createdAt;

  DateTime updatedAt;

  /// The contact's answer to their invite. Reset to `pending` when the phone
  /// number changes, because the number may belong to someone else.
  _ilcrz8k8.ContactOptInStatus optInStatus;

  /// When the contact accepted or declined.
  DateTime? optInRespondedAt;

  /// Secret token in the contact's invite link. Never sent to clients.
  String? inviteToken;

  /// Whether this contact prefers WhatsApp alerts.
  bool notifyByWhatsapp;

  /// Whether SMS should be used as a fallback or alternate alert channel.
  bool notifyBySms;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TrustedContact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TrustedContact copyWith({
    int? id,
    String? ownerId,
    String? name,
    String? phoneNumber,
    String? relationship,
    DateTime? createdAt,
    DateTime? updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    String? inviteToken,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrustedContact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'optInStatus': optInStatus.toJson(),
      if (optInRespondedAt != null)
        'optInRespondedAt': optInRespondedAt?.toJson(),
      if (inviteToken != null) 'inviteToken': inviteToken,
      'notifyByWhatsapp': notifyByWhatsapp,
      'notifyBySms': notifyBySms,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrustedContact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'optInStatus': optInStatus.toJson(),
      if (optInRespondedAt != null)
        'optInRespondedAt': optInRespondedAt?.toJson(),
      'notifyByWhatsapp': notifyByWhatsapp,
      'notifyBySms': notifyBySms,
    };
  }

  static TrustedContactInclude include() {
    return TrustedContactInclude._();
  }

  static TrustedContactIncludeList includeList({
    _is.WhereExpressionBuilder<TrustedContactTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    TrustedContactInclude? include,
  }) {
    return TrustedContactIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TrustedContactImpl extends TrustedContact {
  _TrustedContactImpl({
    int? id,
    required String ownerId,
    required String name,
    required String phoneNumber,
    String? relationship,
    required DateTime createdAt,
    required DateTime updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    String? inviteToken,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : super._(
         id: id,
         ownerId: ownerId,
         name: name,
         phoneNumber: phoneNumber,
         relationship: relationship,
         createdAt: createdAt,
         updatedAt: updatedAt,
         optInStatus: optInStatus,
         optInRespondedAt: optInRespondedAt,
         inviteToken: inviteToken,
         notifyByWhatsapp: notifyByWhatsapp,
         notifyBySms: notifyBySms,
       );

  /// Returns a shallow copy of this [TrustedContact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TrustedContact copyWith({
    Object? id = _Undefined,
    String? ownerId,
    String? name,
    String? phoneNumber,
    Object? relationship = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    Object? optInRespondedAt = _Undefined,
    Object? inviteToken = _Undefined,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) {
    return TrustedContact(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship is String? ? relationship : this.relationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      optInStatus: optInStatus ?? this.optInStatus,
      optInRespondedAt: optInRespondedAt is DateTime?
          ? optInRespondedAt
          : this.optInRespondedAt,
      inviteToken: inviteToken is String? ? inviteToken : this.inviteToken,
      notifyByWhatsapp: notifyByWhatsapp ?? this.notifyByWhatsapp,
      notifyBySms: notifyBySms ?? this.notifyBySms,
    );
  }
}

class TrustedContactUpdateTable extends _is.UpdateTable<TrustedContactTable> {
  TrustedContactUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> phoneNumber(String value) => _is.ColumnValue(
    table.phoneNumber,
    value,
  );

  _is.ColumnValue<String, String> relationship(String? value) =>
      _is.ColumnValue(
        table.relationship,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<_ilcrz8k8.ContactOptInStatus, _ilcrz8k8.ContactOptInStatus>
  optInStatus(_ilcrz8k8.ContactOptInStatus value) => _is.ColumnValue(
    table.optInStatus,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> optInRespondedAt(DateTime? value) =>
      _is.ColumnValue(
        table.optInRespondedAt,
        value,
      );

  _is.ColumnValue<String, String> inviteToken(String? value) => _is.ColumnValue(
    table.inviteToken,
    value,
  );

  _is.ColumnValue<bool, bool> notifyByWhatsapp(bool value) => _is.ColumnValue(
    table.notifyByWhatsapp,
    value,
  );

  _is.ColumnValue<bool, bool> notifyBySms(bool value) => _is.ColumnValue(
    table.notifyBySms,
    value,
  );
}

class TrustedContactTable extends _is.Table<int?> {
  TrustedContactTable({super.tableRelation})
    : super(tableName: 'trusted_contact') {
    updateTable = TrustedContactUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    phoneNumber = _is.ColumnString(
      'phoneNumber',
      this,
    );
    relationship = _is.ColumnString(
      'relationship',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    optInStatus = _is.ColumnEnum(
      'optInStatus',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    optInRespondedAt = _is.ColumnDateTime(
      'optInRespondedAt',
      this,
    );
    inviteToken = _is.ColumnString(
      'inviteToken',
      this,
    );
    notifyByWhatsapp = _is.ColumnBool(
      'notifyByWhatsapp',
      this,
      hasDefault: true,
    );
    notifyBySms = _is.ColumnBool(
      'notifyBySms',
      this,
      hasDefault: true,
    );
  }

  late final TrustedContactUpdateTable updateTable;

  /// The auth user identifier (UUID) of the owner.
  late final _is.ColumnString ownerId;

  late final _is.ColumnString name;

  /// South African phone number in E.164 format (+27...).
  late final _is.ColumnString phoneNumber;

  /// Optional relationship, e.g. "Sister" or "Housemate".
  late final _is.ColumnString relationship;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  /// The contact's answer to their invite. Reset to `pending` when the phone
  /// number changes, because the number may belong to someone else.
  late final _is.ColumnEnum<_ilcrz8k8.ContactOptInStatus> optInStatus;

  /// When the contact accepted or declined.
  late final _is.ColumnDateTime optInRespondedAt;

  /// Secret token in the contact's invite link. Never sent to clients.
  late final _is.ColumnString inviteToken;

  /// Whether this contact prefers WhatsApp alerts.
  late final _is.ColumnBool notifyByWhatsapp;

  /// Whether SMS should be used as a fallback or alternate alert channel.
  late final _is.ColumnBool notifyBySms;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    name,
    phoneNumber,
    relationship,
    createdAt,
    updatedAt,
    optInStatus,
    optInRespondedAt,
    inviteToken,
    notifyByWhatsapp,
    notifyBySms,
  ];
}

class TrustedContactInclude extends _is.IncludeObject {
  TrustedContactInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TrustedContact.t;
}

class TrustedContactIncludeList extends _is.IncludeList {
  TrustedContactIncludeList._({
    _is.WhereExpressionBuilder<TrustedContactTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TrustedContact.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TrustedContact.t;
}

class TrustedContactRepository {
  const TrustedContactRepository._();

  /// Returns a list of [TrustedContact]s matching the given query parameters.
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
  Future<List<TrustedContact>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrustedContactTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TrustedContact>(
      where: where?.call(TrustedContact.t),
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TrustedContact] matching the given query parameters.
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
  Future<TrustedContact?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrustedContactTable>? where,
    int? offset,
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TrustedContact>(
      where: where?.call(TrustedContact.t),
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TrustedContact] by its [id] or null if no such row exists.
  Future<TrustedContact?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TrustedContact>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TrustedContact]s in the list and returns the inserted rows.
  ///
  /// The returned [TrustedContact]s will have their `id` fields set.
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
  Future<List<TrustedContact>> insert(
    _is.DatabaseSession session,
    List<TrustedContact> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TrustedContact>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TrustedContact] and returns the inserted row.
  ///
  /// The returned [TrustedContact] will have its `id` field set.
  Future<TrustedContact> insertRow(
    _is.DatabaseSession session,
    TrustedContact row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TrustedContact>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TrustedContact]s in the list and returns the resulting rows.
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
  /// The returned [TrustedContact]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrustedContact>> upsert(
    _is.DatabaseSession session,
    List<TrustedContact> rows, {
    required _is.ColumnSelections<TrustedContactTable> conflictColumns,
    _is.ColumnSelections<TrustedContactTable>? updateColumns,
    _is.WhereExpressionBuilder<TrustedContactTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TrustedContact>(
      rows,
      conflictColumns: conflictColumns(TrustedContact.t),
      updateColumns: updateColumns?.call(TrustedContact.t),
      updateWhere: updateWhere?.call(TrustedContact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TrustedContact] and returns the resulting row.
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
  /// The returned [TrustedContact] will have its `id` field set.
  Future<TrustedContact?> upsertRow(
    _is.DatabaseSession session,
    TrustedContact row, {
    required _is.ColumnSelections<TrustedContactTable> conflictColumns,
    _is.ColumnSelections<TrustedContactTable>? updateColumns,
    _is.WhereExpressionBuilder<TrustedContactTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TrustedContact>(
      row,
      conflictColumns: conflictColumns(TrustedContact.t),
      updateColumns: updateColumns?.call(TrustedContact.t),
      updateWhere: updateWhere?.call(TrustedContact.t),
      transaction: transaction,
    );
  }

  /// Updates all [TrustedContact]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrustedContact>> update(
    _is.DatabaseSession session,
    List<TrustedContact> rows, {
    _is.ColumnSelections<TrustedContactTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TrustedContact>(
      rows,
      columns: columns?.call(TrustedContact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TrustedContact]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TrustedContact> updateRow(
    _is.DatabaseSession session,
    TrustedContact row, {
    _is.ColumnSelections<TrustedContactTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TrustedContact>(
      row,
      columns: columns?.call(TrustedContact.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TrustedContact] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TrustedContact?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TrustedContactUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TrustedContact>(
      id,
      columnValues: columnValues(TrustedContact.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TrustedContact]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TrustedContact>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TrustedContactUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TrustedContactTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TrustedContact>(
      columnValues: columnValues(TrustedContact.t.updateTable),
      where: where(TrustedContact.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TrustedContact]s in the list and returns the deleted rows.
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
  Future<List<TrustedContact>> delete(
    _is.DatabaseSession session,
    List<TrustedContact> rows, {
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TrustedContact>(
      rows,
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TrustedContact].
  Future<TrustedContact> deleteRow(
    _is.DatabaseSession session,
    TrustedContact row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TrustedContact>(
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
  Future<List<TrustedContact>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TrustedContactTable> where,
    _is.OrderByBuilder<TrustedContactTable>? orderBy,
    _is.OrderByListBuilder<TrustedContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TrustedContact>(
      where: where(TrustedContact.t),
      orderBy: orderBy?.call(TrustedContact.t),
      orderByList: orderByList?.call(TrustedContact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TrustedContactTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TrustedContact>(
      where: where?.call(TrustedContact.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TrustedContact] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TrustedContactTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TrustedContact>(
      where: where(TrustedContact.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

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
import '../companion/alert_reason.dart' as _ijoowf6j;
import '../companion/brief_status.dart' as _i531ttm8;
import '../companion/incident_brief.dart' as _i2a7cxt8;
import '../trips/contact_snapshot.dart' as _i0udr1y1;
import '../trips/trip_type.dart' as _ix6rm8oc;

/// Created by the server when a trip's deadline passes without a check-in.
/// At most one alert exists per trip.
abstract class SafetyAlert
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SafetyAlert._({
    this.id,
    required this.ownerId,
    required this.tripId,
    required this.travellerName,
    required this.travellerPhone,
    required this.tripType,
    required this.tripDescription,
    required this.deadline,
    required this.createdAt,
    required this.contacts,
    _ijoowf6j.AlertReason? reason,
    this.brief,
    _i531ttm8.BriefStatus? briefStatus,
    this.briefAttemptedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionActor,
    this.resolutionNote,
  }) : reason = reason ?? _ijoowf6j.AlertReason.missedCheckIn,
       briefStatus = briefStatus ?? _i531ttm8.BriefStatus.fallback;

  factory SafetyAlert({
    int? id,
    required String ownerId,
    required int tripId,
    required String travellerName,
    required String travellerPhone,
    required _ix6rm8oc.TripType tripType,
    required String tripDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionActor,
    String? resolutionNote,
  }) = _SafetyAlertImpl;

  factory SafetyAlert.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyAlert(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      travellerName: jsonSerialization['travellerName'] as String,
      travellerPhone: jsonSerialization['travellerPhone'] as String,
      tripType: _ix6rm8oc.TripType.fromJson(
        (jsonSerialization['tripType'] as String),
      ),
      tripDescription: jsonSerialization['tripDescription'] as String,
      deadline: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['deadline'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      contacts: _iwfhb10e.Protocol()
          .deserialize<List<_i0udr1y1.ContactSnapshot>>(
            jsonSerialization['contacts'],
          ),
      reason: jsonSerialization['reason'] == null
          ? null
          : _ijoowf6j.AlertReason.fromJson(
              (jsonSerialization['reason'] as String),
            ),
      brief: jsonSerialization['brief'] == null
          ? null
          : _iwfhb10e.Protocol().deserialize<_i2a7cxt8.IncidentBrief>(
              jsonSerialization['brief'],
            ),
      briefStatus: jsonSerialization['briefStatus'] == null
          ? null
          : _i531ttm8.BriefStatus.fromJson(
              (jsonSerialization['briefStatus'] as String),
            ),
      briefAttemptedAt: jsonSerialization['briefAttemptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['briefAttemptedAt'],
            ),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
      resolvedBy: jsonSerialization['resolvedBy'] as String?,
      resolutionActor: jsonSerialization['resolutionActor'] as String?,
      resolutionNote: jsonSerialization['resolutionNote'] as String?,
    );
  }

  static final t = SafetyAlertTable();

  static const db = SafetyAlertRepository._();

  @override
  int? id;

  /// The auth user identifier (UUID) of the traveller.
  String ownerId;

  int tripId;

  String travellerName;

  String travellerPhone;

  _ix6rm8oc.TripType tripType;

  String tripDescription;

  DateTime deadline;

  DateTime createdAt;

  /// Contacts the alert is addressed to, copied from the trip.
  List<_i0udr1y1.ContactSnapshot> contacts;

  _ijoowf6j.AlertReason reason;

  _i2a7cxt8.IncidentBrief? brief;

  _i531ttm8.BriefStatus briefStatus;

  DateTime? briefAttemptedAt;

  DateTime? resolvedAt;

  String? resolvedBy;

  String? resolutionActor;

  String? resolutionNote;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SafetyAlert]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SafetyAlert copyWith({
    int? id,
    String? ownerId,
    int? tripId,
    String? travellerName,
    String? travellerPhone,
    _ix6rm8oc.TripType? tripType,
    String? tripDescription,
    DateTime? deadline,
    DateTime? createdAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionActor,
    String? resolutionNote,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyAlert',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'travellerName': travellerName,
      'travellerPhone': travellerPhone,
      'tripType': tripType.toJson(),
      'tripDescription': tripDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
      'reason': reason.toJson(),
      if (brief != null) 'brief': brief?.toJson(),
      'briefStatus': briefStatus.toJson(),
      if (briefAttemptedAt != null)
        'briefAttemptedAt': briefAttemptedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SafetyAlert',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'travellerName': travellerName,
      'travellerPhone': travellerPhone,
      'tripType': tripType.toJson(),
      'tripDescription': tripDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'reason': reason.toJson(),
      if (brief != null) 'brief': brief?.toJsonForProtocol(),
      'briefStatus': briefStatus.toJson(),
      if (briefAttemptedAt != null)
        'briefAttemptedAt': briefAttemptedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
    };
  }

  static SafetyAlertInclude include() {
    return SafetyAlertInclude._();
  }

  static SafetyAlertIncludeList includeList({
    _is.WhereExpressionBuilder<SafetyAlertTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    SafetyAlertInclude? include,
  }) {
    return SafetyAlertIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyAlertImpl extends SafetyAlert {
  _SafetyAlertImpl({
    int? id,
    required String ownerId,
    required int tripId,
    required String travellerName,
    required String travellerPhone,
    required _ix6rm8oc.TripType tripType,
    required String tripDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionActor,
    String? resolutionNote,
  }) : super._(
         id: id,
         ownerId: ownerId,
         tripId: tripId,
         travellerName: travellerName,
         travellerPhone: travellerPhone,
         tripType: tripType,
         tripDescription: tripDescription,
         deadline: deadline,
         createdAt: createdAt,
         contacts: contacts,
         reason: reason,
         brief: brief,
         briefStatus: briefStatus,
         briefAttemptedAt: briefAttemptedAt,
         resolvedAt: resolvedAt,
         resolvedBy: resolvedBy,
         resolutionActor: resolutionActor,
         resolutionNote: resolutionNote,
       );

  /// Returns a shallow copy of this [SafetyAlert]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SafetyAlert copyWith({
    Object? id = _Undefined,
    String? ownerId,
    int? tripId,
    String? travellerName,
    String? travellerPhone,
    _ix6rm8oc.TripType? tripType,
    String? tripDescription,
    DateTime? deadline,
    DateTime? createdAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ijoowf6j.AlertReason? reason,
    Object? brief = _Undefined,
    _i531ttm8.BriefStatus? briefStatus,
    Object? briefAttemptedAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? resolvedBy = _Undefined,
    Object? resolutionActor = _Undefined,
    Object? resolutionNote = _Undefined,
  }) {
    return SafetyAlert(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      travellerName: travellerName ?? this.travellerName,
      travellerPhone: travellerPhone ?? this.travellerPhone,
      tripType: tripType ?? this.tripType,
      tripDescription: tripDescription ?? this.tripDescription,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
      reason: reason ?? this.reason,
      brief: brief is _i2a7cxt8.IncidentBrief? ? brief : this.brief?.copyWith(),
      briefStatus: briefStatus ?? this.briefStatus,
      briefAttemptedAt: briefAttemptedAt is DateTime?
          ? briefAttemptedAt
          : this.briefAttemptedAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      resolvedBy: resolvedBy is String? ? resolvedBy : this.resolvedBy,
      resolutionActor: resolutionActor is String?
          ? resolutionActor
          : this.resolutionActor,
      resolutionNote: resolutionNote is String?
          ? resolutionNote
          : this.resolutionNote,
    );
  }
}

class SafetyAlertUpdateTable extends _is.UpdateTable<SafetyAlertTable> {
  SafetyAlertUpdateTable(super.table);

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<int, int> tripId(int value) => _is.ColumnValue(
    table.tripId,
    value,
  );

  _is.ColumnValue<String, String> travellerName(String value) =>
      _is.ColumnValue(
        table.travellerName,
        value,
      );

  _is.ColumnValue<String, String> travellerPhone(String value) =>
      _is.ColumnValue(
        table.travellerPhone,
        value,
      );

  _is.ColumnValue<_ix6rm8oc.TripType, _ix6rm8oc.TripType> tripType(
    _ix6rm8oc.TripType value,
  ) => _is.ColumnValue(
    table.tripType,
    value,
  );

  _is.ColumnValue<String, String> tripDescription(String value) =>
      _is.ColumnValue(
        table.tripDescription,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> deadline(DateTime value) =>
      _is.ColumnValue(
        table.deadline,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
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

  _is.ColumnValue<_ijoowf6j.AlertReason, _ijoowf6j.AlertReason> reason(
    _ijoowf6j.AlertReason value,
  ) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<_i2a7cxt8.IncidentBrief, _i2a7cxt8.IncidentBrief> brief(
    _i2a7cxt8.IncidentBrief? value,
  ) => _is.ColumnValue(
    table.brief,
    value,
  );

  _is.ColumnValue<_i531ttm8.BriefStatus, _i531ttm8.BriefStatus> briefStatus(
    _i531ttm8.BriefStatus value,
  ) => _is.ColumnValue(
    table.briefStatus,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> briefAttemptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.briefAttemptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );

  _is.ColumnValue<String, String> resolvedBy(String? value) => _is.ColumnValue(
    table.resolvedBy,
    value,
  );

  _is.ColumnValue<String, String> resolutionActor(String? value) =>
      _is.ColumnValue(
        table.resolutionActor,
        value,
      );

  _is.ColumnValue<String, String> resolutionNote(String? value) =>
      _is.ColumnValue(
        table.resolutionNote,
        value,
      );
}

class SafetyAlertTable extends _is.Table<int?> {
  SafetyAlertTable({super.tableRelation}) : super(tableName: 'safety_alert') {
    updateTable = SafetyAlertUpdateTable(this);
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    tripId = _is.ColumnInt(
      'tripId',
      this,
    );
    travellerName = _is.ColumnString(
      'travellerName',
      this,
    );
    travellerPhone = _is.ColumnString(
      'travellerPhone',
      this,
    );
    tripType = _is.ColumnEnum(
      'tripType',
      this,
      _is.EnumSerialization.byName,
    );
    tripDescription = _is.ColumnString(
      'tripDescription',
      this,
    );
    deadline = _is.ColumnDateTime(
      'deadline',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    contacts = _is.ColumnSerializable<List<_i0udr1y1.ContactSnapshot>>(
      'contacts',
      this,
    );
    reason = _is.ColumnEnum(
      'reason',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    brief = _is.ColumnSerializable<_i2a7cxt8.IncidentBrief>(
      'brief',
      this,
    );
    briefStatus = _is.ColumnEnum(
      'briefStatus',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    briefAttemptedAt = _is.ColumnDateTime(
      'briefAttemptedAt',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
    resolvedBy = _is.ColumnString(
      'resolvedBy',
      this,
    );
    resolutionActor = _is.ColumnString(
      'resolutionActor',
      this,
    );
    resolutionNote = _is.ColumnString(
      'resolutionNote',
      this,
    );
  }

  late final SafetyAlertUpdateTable updateTable;

  /// The auth user identifier (UUID) of the traveller.
  late final _is.ColumnString ownerId;

  late final _is.ColumnInt tripId;

  late final _is.ColumnString travellerName;

  late final _is.ColumnString travellerPhone;

  late final _is.ColumnEnum<_ix6rm8oc.TripType> tripType;

  late final _is.ColumnString tripDescription;

  late final _is.ColumnDateTime deadline;

  late final _is.ColumnDateTime createdAt;

  /// Contacts the alert is addressed to, copied from the trip.
  late final _is.ColumnSerializable<List<_i0udr1y1.ContactSnapshot>> contacts;

  late final _is.ColumnEnum<_ijoowf6j.AlertReason> reason;

  late final _is.ColumnSerializable<_i2a7cxt8.IncidentBrief> brief;

  late final _is.ColumnEnum<_i531ttm8.BriefStatus> briefStatus;

  late final _is.ColumnDateTime briefAttemptedAt;

  late final _is.ColumnDateTime resolvedAt;

  late final _is.ColumnString resolvedBy;

  late final _is.ColumnString resolutionActor;

  late final _is.ColumnString resolutionNote;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    tripId,
    travellerName,
    travellerPhone,
    tripType,
    tripDescription,
    deadline,
    createdAt,
    contacts,
    reason,
    brief,
    briefStatus,
    briefAttemptedAt,
    resolvedAt,
    resolvedBy,
    resolutionActor,
    resolutionNote,
  ];
}

class SafetyAlertInclude extends _is.IncludeObject {
  SafetyAlertInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SafetyAlert.t;
}

class SafetyAlertIncludeList extends _is.IncludeList {
  SafetyAlertIncludeList._({
    _is.WhereExpressionBuilder<SafetyAlertTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SafetyAlert.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SafetyAlert.t;
}

class SafetyAlertRepository {
  const SafetyAlertRepository._();

  /// Returns a list of [SafetyAlert]s matching the given query parameters.
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
  Future<List<SafetyAlert>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SafetyAlertTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SafetyAlert>(
      where: where?.call(SafetyAlert.t),
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SafetyAlert] matching the given query parameters.
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
  Future<SafetyAlert?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SafetyAlertTable>? where,
    int? offset,
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SafetyAlert>(
      where: where?.call(SafetyAlert.t),
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SafetyAlert] by its [id] or null if no such row exists.
  Future<SafetyAlert?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SafetyAlert>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SafetyAlert]s in the list and returns the inserted rows.
  ///
  /// The returned [SafetyAlert]s will have their `id` fields set.
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
  Future<List<SafetyAlert>> insert(
    _is.DatabaseSession session,
    List<SafetyAlert> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SafetyAlert>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SafetyAlert] and returns the inserted row.
  ///
  /// The returned [SafetyAlert] will have its `id` field set.
  Future<SafetyAlert> insertRow(
    _is.DatabaseSession session,
    SafetyAlert row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SafetyAlert>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SafetyAlert]s in the list and returns the resulting rows.
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
  /// The returned [SafetyAlert]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SafetyAlert>> upsert(
    _is.DatabaseSession session,
    List<SafetyAlert> rows, {
    required _is.ColumnSelections<SafetyAlertTable> conflictColumns,
    _is.ColumnSelections<SafetyAlertTable>? updateColumns,
    _is.WhereExpressionBuilder<SafetyAlertTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SafetyAlert>(
      rows,
      conflictColumns: conflictColumns(SafetyAlert.t),
      updateColumns: updateColumns?.call(SafetyAlert.t),
      updateWhere: updateWhere?.call(SafetyAlert.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SafetyAlert] and returns the resulting row.
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
  /// The returned [SafetyAlert] will have its `id` field set.
  Future<SafetyAlert?> upsertRow(
    _is.DatabaseSession session,
    SafetyAlert row, {
    required _is.ColumnSelections<SafetyAlertTable> conflictColumns,
    _is.ColumnSelections<SafetyAlertTable>? updateColumns,
    _is.WhereExpressionBuilder<SafetyAlertTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SafetyAlert>(
      row,
      conflictColumns: conflictColumns(SafetyAlert.t),
      updateColumns: updateColumns?.call(SafetyAlert.t),
      updateWhere: updateWhere?.call(SafetyAlert.t),
      transaction: transaction,
    );
  }

  /// Updates all [SafetyAlert]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SafetyAlert>> update(
    _is.DatabaseSession session,
    List<SafetyAlert> rows, {
    _is.ColumnSelections<SafetyAlertTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SafetyAlert>(
      rows,
      columns: columns?.call(SafetyAlert.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SafetyAlert]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SafetyAlert> updateRow(
    _is.DatabaseSession session,
    SafetyAlert row, {
    _is.ColumnSelections<SafetyAlertTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SafetyAlert>(
      row,
      columns: columns?.call(SafetyAlert.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SafetyAlert] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SafetyAlert?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SafetyAlertUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SafetyAlert>(
      id,
      columnValues: columnValues(SafetyAlert.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SafetyAlert]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SafetyAlert>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SafetyAlertUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SafetyAlertTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SafetyAlert>(
      columnValues: columnValues(SafetyAlert.t.updateTable),
      where: where(SafetyAlert.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SafetyAlert]s in the list and returns the deleted rows.
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
  Future<List<SafetyAlert>> delete(
    _is.DatabaseSession session,
    List<SafetyAlert> rows, {
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SafetyAlert>(
      rows,
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SafetyAlert].
  Future<SafetyAlert> deleteRow(
    _is.DatabaseSession session,
    SafetyAlert row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SafetyAlert>(
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
  Future<List<SafetyAlert>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SafetyAlertTable> where,
    _is.OrderByBuilder<SafetyAlertTable>? orderBy,
    _is.OrderByListBuilder<SafetyAlertTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SafetyAlert>(
      where: where(SafetyAlert.t),
      orderBy: orderBy?.call(SafetyAlert.t),
      orderByList: orderByList?.call(SafetyAlert.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SafetyAlertTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SafetyAlert>(
      where: where?.call(SafetyAlert.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SafetyAlert] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SafetyAlertTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SafetyAlert>(
      where: where(SafetyAlert.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

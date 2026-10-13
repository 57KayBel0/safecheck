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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
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
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      createdAt: _isc.DateTimeJsonExtension.fromJson(
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
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['statusUpdatedAt'],
            ),
      failureReason: jsonSerialization['failureReason'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [AlertMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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

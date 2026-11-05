/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:safecheck_server/src/generated/alerts/alert_message.dart'
    as _ibat3zb3;
import 'package:safecheck_server/src/generated/alerts/safety_alert.dart'
    as _iuq30u7q;
import 'package:safecheck_server/src/generated/contacts/trusted_contact.dart'
    as _imtfj37e;
import 'package:safecheck_server/src/generated/tracking/location_point.dart'
    as _inw09ail;
import 'package:safecheck_server/src/generated/tracking/tracking_link_info.dart'
    as _i0kaao2i;
import 'package:safecheck_server/src/generated/tracking/trip_location.dart'
    as _ibdprtnr;
import 'package:safecheck_server/src/generated/trips/trip.dart' as _ianfkq79;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'alerts/alert_message.dart' as _isas3mld;
import 'alerts/safety_alert.dart' as _i79al053;
import 'common/safecheck_exception.dart' as _iontdvzq;
import 'companion/alert_reason.dart' as _iwolc6uz;
import 'companion/brief_status.dart' as _i4443g4d;
import 'companion/incident_access.dart' as _i0z2fbwj;
import 'companion/incident_brief.dart' as _i42dowtq;
import 'companion/incident_view.dart' as _intz7cqw;
import 'companion/journey_request.dart' as _i1v3s9cv;
import 'contacts/contact_invite.dart' as _i3noworj;
import 'contacts/contact_opt_in_status.dart' as _iz3pr2uv;
import 'contacts/trusted_contact.dart' as _ixhyrlmy;
import 'future_calls_generated_models/incident_summary_future_call_generate_model.dart'
    as _ipdwtssp;
import 'future_calls_generated_models/trip_deadline_future_call_process_deadline_model.dart'
    as _ih51nflp;
import 'messaging/message_channel.dart' as _i9p5tz3d;
import 'messaging/message_status.dart' as _i5yj6jmy;
import 'planning/planning_quota.dart' as _id4akxn0;
import 'profile/user_profile.dart' as _ik2xsncp;
import 'tracking/location_point.dart' as _irmr9nnk;
import 'tracking/location_sharing.dart' as _idx5cm0c;
import 'tracking/tracking_link.dart' as _idf2vf11;
import 'tracking/tracking_link_info.dart' as _ij184lk4;
import 'tracking/trip_location.dart' as _igycq0nv;
import 'trips/contact_snapshot.dart' as _ie7zf2se;
import 'trips/trip.dart' as _i2i2066w;
import 'trips/trip_snapshot.dart' as _i7v6k0fj;
import 'trips/trip_status.dart' as _ind0qj5m;
import 'trips/trip_type.dart' as _ie9y6u8r;
export 'alerts/alert_message.dart';
export 'alerts/safety_alert.dart';
export 'common/safecheck_exception.dart';
export 'companion/alert_reason.dart';
export 'companion/brief_status.dart';
export 'companion/incident_access.dart';
export 'companion/incident_brief.dart';
export 'companion/incident_view.dart';
export 'companion/journey_request.dart';
export 'contacts/contact_invite.dart';
export 'contacts/contact_opt_in_status.dart';
export 'contacts/trusted_contact.dart';
export 'messaging/message_channel.dart';
export 'messaging/message_status.dart';
export 'planning/planning_quota.dart';
export 'profile/user_profile.dart';
export 'tracking/location_point.dart';
export 'tracking/location_sharing.dart';
export 'tracking/tracking_link.dart';
export 'tracking/tracking_link_info.dart';
export 'tracking/trip_location.dart';
export 'trips/contact_snapshot.dart';
export 'trips/trip.dart';
export 'trips/trip_snapshot.dart';
export 'trips/trip_status.dart';
export 'trips/trip_type.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'incident_access',
      dartName: 'IncidentAccess',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'tokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'alertId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'contactName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'canResolve',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'trackingUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'incident_access_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tokenHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'incident_access_alert_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'alertId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'planning_quota',
      dartName: 'PlanningQuota',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'windowStartedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'windowCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'dayStartedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'dayCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'planning_quota_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'safety_alert',
      dartName: 'SafetyAlert',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tripId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'travellerName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'travellerPhone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tripType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TripType',
        ),
        _isp.ColumnDefinition(
          name: 'tripDescription',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'deadline',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'contacts',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:ContactSnapshot>',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AlertReason',
          columnDefault: '\'missedCheckIn\'',
        ),
        _isp.ColumnDefinition(
          name: 'brief',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:IncidentBrief?',
        ),
        _isp.ColumnDefinition(
          name: 'briefStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:BriefStatus',
          columnDefault: '\'fallback\'',
        ),
        _isp.ColumnDefinition(
          name: 'briefAttemptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resolutionActor',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resolutionNote',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'safety_alert_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'safety_alert_trip_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tripId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'simulated_sms',
      dartName: 'AlertMessage',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'alertId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tripId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'recipientName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientPhone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'body',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'channel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MessageChannel',
          columnDefault: '\'sms\'',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MessageStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'statusUpdatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'failureReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'simulated_sms_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'simulated_sms_alert_recipient_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'alertId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientPhone',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'channel',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'simulated_sms_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'tracking_link',
      dartName: 'TrackingLink',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tripId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'contactName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contactPhone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'tracking_link_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'tracking_link_trip_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tripId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'trip',
      dartName: 'Trip',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'activeOwnerId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'tripType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TripType',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'durationMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'startedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'deadline',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TripStatus',
        ),
        _isp.ColumnDefinition(
          name: 'endedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'contacts',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:ContactSnapshot>',
        ),
        _isp.ColumnDefinition(
          name: 'locationSharing',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:LocationSharing',
          columnDefault: '\'off\'',
        ),
        _isp.ColumnDefinition(
          name: 'companionMode',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'graceMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'alertAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'safetyPlanJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'useAiIncidentSummary',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'helpRequestedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'trip_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'trip_active_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'activeOwnerId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'trip_status_deadline_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deadline',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'trip_location',
      dartName: 'TripLocation',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tripId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'accuracyMeters',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'recordedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'trip_location_trip_time_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tripId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recordedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'trip_location_received_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'receivedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'trusted_contact',
      dartName: 'TrustedContact',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'phoneNumber',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'relationship',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'optInStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ContactOptInStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'optInRespondedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'inviteToken',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'notifyByWhatsapp',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'notifyBySms',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'trusted_contact_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'trusted_contact_invite_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'inviteToken',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_profile',
      dartName: 'UserProfile',
      schema: 'public',
      module: 'safecheck',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'phoneNumber',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_profile_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _isas3mld.AlertMessage) {
      return _isas3mld.AlertMessage.fromJson(data) as T;
    }
    if (t == _i79al053.SafetyAlert) {
      return _i79al053.SafetyAlert.fromJson(data) as T;
    }
    if (t == _iontdvzq.SafeCheckException) {
      return _iontdvzq.SafeCheckException.fromJson(data) as T;
    }
    if (t == _iwolc6uz.AlertReason) {
      return _iwolc6uz.AlertReason.fromJson(data) as T;
    }
    if (t == _i4443g4d.BriefStatus) {
      return _i4443g4d.BriefStatus.fromJson(data) as T;
    }
    if (t == _i0z2fbwj.IncidentAccess) {
      return _i0z2fbwj.IncidentAccess.fromJson(data) as T;
    }
    if (t == _i42dowtq.IncidentBrief) {
      return _i42dowtq.IncidentBrief.fromJson(data) as T;
    }
    if (t == _intz7cqw.IncidentView) {
      return _intz7cqw.IncidentView.fromJson(data) as T;
    }
    if (t == _i1v3s9cv.JourneyRequest) {
      return _i1v3s9cv.JourneyRequest.fromJson(data) as T;
    }
    if (t == _i3noworj.ContactInvite) {
      return _i3noworj.ContactInvite.fromJson(data) as T;
    }
    if (t == _iz3pr2uv.ContactOptInStatus) {
      return _iz3pr2uv.ContactOptInStatus.fromJson(data) as T;
    }
    if (t == _ixhyrlmy.TrustedContact) {
      return _ixhyrlmy.TrustedContact.fromJson(data) as T;
    }
    if (t == _ipdwtssp.IncidentSummaryFutureCallGenerateModel) {
      return _ipdwtssp.IncidentSummaryFutureCallGenerateModel.fromJson(data)
          as T;
    }
    if (t == _ih51nflp.TripDeadlineFutureCallProcessDeadlineModel) {
      return _ih51nflp.TripDeadlineFutureCallProcessDeadlineModel.fromJson(data)
          as T;
    }
    if (t == _i9p5tz3d.MessageChannel) {
      return _i9p5tz3d.MessageChannel.fromJson(data) as T;
    }
    if (t == _i5yj6jmy.MessageStatus) {
      return _i5yj6jmy.MessageStatus.fromJson(data) as T;
    }
    if (t == _id4akxn0.PlanningQuota) {
      return _id4akxn0.PlanningQuota.fromJson(data) as T;
    }
    if (t == _ik2xsncp.UserProfile) {
      return _ik2xsncp.UserProfile.fromJson(data) as T;
    }
    if (t == _irmr9nnk.LocationPoint) {
      return _irmr9nnk.LocationPoint.fromJson(data) as T;
    }
    if (t == _idx5cm0c.LocationSharing) {
      return _idx5cm0c.LocationSharing.fromJson(data) as T;
    }
    if (t == _idf2vf11.TrackingLink) {
      return _idf2vf11.TrackingLink.fromJson(data) as T;
    }
    if (t == _ij184lk4.TrackingLinkInfo) {
      return _ij184lk4.TrackingLinkInfo.fromJson(data) as T;
    }
    if (t == _igycq0nv.TripLocation) {
      return _igycq0nv.TripLocation.fromJson(data) as T;
    }
    if (t == _ie7zf2se.ContactSnapshot) {
      return _ie7zf2se.ContactSnapshot.fromJson(data) as T;
    }
    if (t == _i2i2066w.Trip) {
      return _i2i2066w.Trip.fromJson(data) as T;
    }
    if (t == _i7v6k0fj.TripSnapshot) {
      return _i7v6k0fj.TripSnapshot.fromJson(data) as T;
    }
    if (t == _ind0qj5m.TripStatus) {
      return _ind0qj5m.TripStatus.fromJson(data) as T;
    }
    if (t == _ie9y6u8r.TripType) {
      return _ie9y6u8r.TripType.fromJson(data) as T;
    }
    if (t == _is.getType<_isas3mld.AlertMessage?>()) {
      return (data != null ? _isas3mld.AlertMessage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i79al053.SafetyAlert?>()) {
      return (data != null ? _i79al053.SafetyAlert.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iontdvzq.SafeCheckException?>()) {
      return (data != null ? _iontdvzq.SafeCheckException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwolc6uz.AlertReason?>()) {
      return (data != null ? _iwolc6uz.AlertReason.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4443g4d.BriefStatus?>()) {
      return (data != null ? _i4443g4d.BriefStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0z2fbwj.IncidentAccess?>()) {
      return (data != null ? _i0z2fbwj.IncidentAccess.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i42dowtq.IncidentBrief?>()) {
      return (data != null ? _i42dowtq.IncidentBrief.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_intz7cqw.IncidentView?>()) {
      return (data != null ? _intz7cqw.IncidentView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1v3s9cv.JourneyRequest?>()) {
      return (data != null ? _i1v3s9cv.JourneyRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3noworj.ContactInvite?>()) {
      return (data != null ? _i3noworj.ContactInvite.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iz3pr2uv.ContactOptInStatus?>()) {
      return (data != null ? _iz3pr2uv.ContactOptInStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixhyrlmy.TrustedContact?>()) {
      return (data != null ? _ixhyrlmy.TrustedContact.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipdwtssp.IncidentSummaryFutureCallGenerateModel?>()) {
      return (data != null
              ? _ipdwtssp.IncidentSummaryFutureCallGenerateModel.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_ih51nflp.TripDeadlineFutureCallProcessDeadlineModel?>()) {
      return (data != null
              ? _ih51nflp.TripDeadlineFutureCallProcessDeadlineModel.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_i9p5tz3d.MessageChannel?>()) {
      return (data != null ? _i9p5tz3d.MessageChannel.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i5yj6jmy.MessageStatus?>()) {
      return (data != null ? _i5yj6jmy.MessageStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_id4akxn0.PlanningQuota?>()) {
      return (data != null ? _id4akxn0.PlanningQuota.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ik2xsncp.UserProfile?>()) {
      return (data != null ? _ik2xsncp.UserProfile.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irmr9nnk.LocationPoint?>()) {
      return (data != null ? _irmr9nnk.LocationPoint.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idx5cm0c.LocationSharing?>()) {
      return (data != null ? _idx5cm0c.LocationSharing.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idf2vf11.TrackingLink?>()) {
      return (data != null ? _idf2vf11.TrackingLink.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ij184lk4.TrackingLinkInfo?>()) {
      return (data != null ? _ij184lk4.TrackingLinkInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igycq0nv.TripLocation?>()) {
      return (data != null ? _igycq0nv.TripLocation.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ie7zf2se.ContactSnapshot?>()) {
      return (data != null ? _ie7zf2se.ContactSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2i2066w.Trip?>()) {
      return (data != null ? _i2i2066w.Trip.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7v6k0fj.TripSnapshot?>()) {
      return (data != null ? _i7v6k0fj.TripSnapshot.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ind0qj5m.TripStatus?>()) {
      return (data != null ? _ind0qj5m.TripStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ie9y6u8r.TripType?>()) {
      return (data != null ? _ie9y6u8r.TripType.fromJson(data) : null) as T;
    }
    if (t == List<_ie7zf2se.ContactSnapshot>) {
      return (data as List)
              .map((e) => deserialize<_ie7zf2se.ContactSnapshot>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_iuq30u7q.SafetyAlert>) {
      return (data as List)
              .map((e) => deserialize<_iuq30u7q.SafetyAlert>(e))
              .toList()
          as T;
    }
    if (t == List<_ibat3zb3.AlertMessage>) {
      return (data as List)
              .map((e) => deserialize<_ibat3zb3.AlertMessage>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_imtfj37e.TrustedContact>) {
      return (data as List)
              .map((e) => deserialize<_imtfj37e.TrustedContact>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_inw09ail.LocationPoint>) {
      return (data as List)
              .map((e) => deserialize<_inw09ail.LocationPoint>(e))
              .toList()
          as T;
    }
    if (t == List<_ibdprtnr.TripLocation>) {
      return (data as List)
              .map((e) => deserialize<_ibdprtnr.TripLocation>(e))
              .toList()
          as T;
    }
    if (t == List<_ianfkq79.Trip>) {
      return (data as List).map((e) => deserialize<_ianfkq79.Trip>(e)).toList()
          as T;
    }
    if (t == List<_i0kaao2i.TrackingLinkInfo>) {
      return (data as List)
              .map((e) => deserialize<_i0kaao2i.TrackingLinkInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _isas3mld.AlertMessage => 'AlertMessage',
      _i79al053.SafetyAlert => 'SafetyAlert',
      _iontdvzq.SafeCheckException => 'SafeCheckException',
      _iwolc6uz.AlertReason => 'AlertReason',
      _i4443g4d.BriefStatus => 'BriefStatus',
      _i0z2fbwj.IncidentAccess => 'IncidentAccess',
      _i42dowtq.IncidentBrief => 'IncidentBrief',
      _intz7cqw.IncidentView => 'IncidentView',
      _i1v3s9cv.JourneyRequest => 'JourneyRequest',
      _i3noworj.ContactInvite => 'ContactInvite',
      _iz3pr2uv.ContactOptInStatus => 'ContactOptInStatus',
      _ixhyrlmy.TrustedContact => 'TrustedContact',
      _ipdwtssp.IncidentSummaryFutureCallGenerateModel =>
        'IncidentSummaryFutureCallGenerateModel',
      _ih51nflp.TripDeadlineFutureCallProcessDeadlineModel =>
        'TripDeadlineFutureCallProcessDeadlineModel',
      _i9p5tz3d.MessageChannel => 'MessageChannel',
      _i5yj6jmy.MessageStatus => 'MessageStatus',
      _id4akxn0.PlanningQuota => 'PlanningQuota',
      _ik2xsncp.UserProfile => 'UserProfile',
      _irmr9nnk.LocationPoint => 'LocationPoint',
      _idx5cm0c.LocationSharing => 'LocationSharing',
      _idf2vf11.TrackingLink => 'TrackingLink',
      _ij184lk4.TrackingLinkInfo => 'TrackingLinkInfo',
      _igycq0nv.TripLocation => 'TripLocation',
      _ie7zf2se.ContactSnapshot => 'ContactSnapshot',
      _i2i2066w.Trip => 'Trip',
      _i7v6k0fj.TripSnapshot => 'TripSnapshot',
      _ind0qj5m.TripStatus => 'TripStatus',
      _ie9y6u8r.TripType => 'TripType',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('safecheck.', '');
    }

    switch (data) {
      case _isas3mld.AlertMessage():
        return 'AlertMessage';
      case _i79al053.SafetyAlert():
        return 'SafetyAlert';
      case _iontdvzq.SafeCheckException():
        return 'SafeCheckException';
      case _iwolc6uz.AlertReason():
        return 'AlertReason';
      case _i4443g4d.BriefStatus():
        return 'BriefStatus';
      case _i0z2fbwj.IncidentAccess():
        return 'IncidentAccess';
      case _i42dowtq.IncidentBrief():
        return 'IncidentBrief';
      case _intz7cqw.IncidentView():
        return 'IncidentView';
      case _i1v3s9cv.JourneyRequest():
        return 'JourneyRequest';
      case _i3noworj.ContactInvite():
        return 'ContactInvite';
      case _iz3pr2uv.ContactOptInStatus():
        return 'ContactOptInStatus';
      case _ixhyrlmy.TrustedContact():
        return 'TrustedContact';
      case _ipdwtssp.IncidentSummaryFutureCallGenerateModel():
        return 'IncidentSummaryFutureCallGenerateModel';
      case _ih51nflp.TripDeadlineFutureCallProcessDeadlineModel():
        return 'TripDeadlineFutureCallProcessDeadlineModel';
      case _i9p5tz3d.MessageChannel():
        return 'MessageChannel';
      case _i5yj6jmy.MessageStatus():
        return 'MessageStatus';
      case _id4akxn0.PlanningQuota():
        return 'PlanningQuota';
      case _ik2xsncp.UserProfile():
        return 'UserProfile';
      case _irmr9nnk.LocationPoint():
        return 'LocationPoint';
      case _idx5cm0c.LocationSharing():
        return 'LocationSharing';
      case _idf2vf11.TrackingLink():
        return 'TrackingLink';
      case _ij184lk4.TrackingLinkInfo():
        return 'TrackingLinkInfo';
      case _igycq0nv.TripLocation():
        return 'TripLocation';
      case _ie7zf2se.ContactSnapshot():
        return 'ContactSnapshot';
      case _i2i2066w.Trip():
        return 'Trip';
      case _i7v6k0fj.TripSnapshot():
        return 'TripSnapshot';
      case _ind0qj5m.TripStatus():
        return 'TripStatus';
      case _ie9y6u8r.TripType():
        return 'TripType';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AlertMessage') {
      return deserialize<_isas3mld.AlertMessage>(data['data']);
    }
    if (dataClassName == 'SafetyAlert') {
      return deserialize<_i79al053.SafetyAlert>(data['data']);
    }
    if (dataClassName == 'SafeCheckException') {
      return deserialize<_iontdvzq.SafeCheckException>(data['data']);
    }
    if (dataClassName == 'AlertReason') {
      return deserialize<_iwolc6uz.AlertReason>(data['data']);
    }
    if (dataClassName == 'BriefStatus') {
      return deserialize<_i4443g4d.BriefStatus>(data['data']);
    }
    if (dataClassName == 'IncidentAccess') {
      return deserialize<_i0z2fbwj.IncidentAccess>(data['data']);
    }
    if (dataClassName == 'IncidentBrief') {
      return deserialize<_i42dowtq.IncidentBrief>(data['data']);
    }
    if (dataClassName == 'IncidentView') {
      return deserialize<_intz7cqw.IncidentView>(data['data']);
    }
    if (dataClassName == 'JourneyRequest') {
      return deserialize<_i1v3s9cv.JourneyRequest>(data['data']);
    }
    if (dataClassName == 'ContactInvite') {
      return deserialize<_i3noworj.ContactInvite>(data['data']);
    }
    if (dataClassName == 'ContactOptInStatus') {
      return deserialize<_iz3pr2uv.ContactOptInStatus>(data['data']);
    }
    if (dataClassName == 'TrustedContact') {
      return deserialize<_ixhyrlmy.TrustedContact>(data['data']);
    }
    if (dataClassName == 'IncidentSummaryFutureCallGenerateModel') {
      return deserialize<_ipdwtssp.IncidentSummaryFutureCallGenerateModel>(
        data['data'],
      );
    }
    if (dataClassName == 'TripDeadlineFutureCallProcessDeadlineModel') {
      return deserialize<_ih51nflp.TripDeadlineFutureCallProcessDeadlineModel>(
        data['data'],
      );
    }
    if (dataClassName == 'MessageChannel') {
      return deserialize<_i9p5tz3d.MessageChannel>(data['data']);
    }
    if (dataClassName == 'MessageStatus') {
      return deserialize<_i5yj6jmy.MessageStatus>(data['data']);
    }
    if (dataClassName == 'PlanningQuota') {
      return deserialize<_id4akxn0.PlanningQuota>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_ik2xsncp.UserProfile>(data['data']);
    }
    if (dataClassName == 'LocationPoint') {
      return deserialize<_irmr9nnk.LocationPoint>(data['data']);
    }
    if (dataClassName == 'LocationSharing') {
      return deserialize<_idx5cm0c.LocationSharing>(data['data']);
    }
    if (dataClassName == 'TrackingLink') {
      return deserialize<_idf2vf11.TrackingLink>(data['data']);
    }
    if (dataClassName == 'TrackingLinkInfo') {
      return deserialize<_ij184lk4.TrackingLinkInfo>(data['data']);
    }
    if (dataClassName == 'TripLocation') {
      return deserialize<_igycq0nv.TripLocation>(data['data']);
    }
    if (dataClassName == 'ContactSnapshot') {
      return deserialize<_ie7zf2se.ContactSnapshot>(data['data']);
    }
    if (dataClassName == 'Trip') {
      return deserialize<_i2i2066w.Trip>(data['data']);
    }
    if (dataClassName == 'TripSnapshot') {
      return deserialize<_i7v6k0fj.TripSnapshot>(data['data']);
    }
    if (dataClassName == 'TripStatus') {
      return deserialize<_ind0qj5m.TripStatus>(data['data']);
    }
    if (dataClassName == 'TripType') {
      return deserialize<_ie9y6u8r.TripType>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('safecheck', this);
    _iacs.Protocol().registerHostProtocol('safecheck', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _isas3mld.AlertMessage:
        return _isas3mld.AlertMessage.t;
      case _i79al053.SafetyAlert:
        return _i79al053.SafetyAlert.t;
      case _i0z2fbwj.IncidentAccess:
        return _i0z2fbwj.IncidentAccess.t;
      case _ixhyrlmy.TrustedContact:
        return _ixhyrlmy.TrustedContact.t;
      case _id4akxn0.PlanningQuota:
        return _id4akxn0.PlanningQuota.t;
      case _ik2xsncp.UserProfile:
        return _ik2xsncp.UserProfile.t;
      case _idf2vf11.TrackingLink:
        return _idf2vf11.TrackingLink.t;
      case _igycq0nv.TripLocation:
        return _igycq0nv.TripLocation.t;
      case _i2i2066w.Trip:
        return _i2i2066w.Trip.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'safecheck';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

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

/// Delivery state of an [AlertMessage].
enum MessageStatus implements _is.SerializableModel {
  /// Saved, not yet handed to a sender.
  pending,

  /// Claimed by a dispatcher and being handed to the sender.
  sending,

  /// Handled by the demo sender: nothing was sent.
  simulated,

  /// Accepted by a real provider.
  sent,

  /// Confirmed delivered by a real provider.
  delivered,

  /// A real provider rejected or could not deliver it.
  failed,

  /// Not sent because another preferred channel succeeded.
  skipped;

  static MessageStatus fromJson(String name) {
    switch (name) {
      case 'pending':
        return MessageStatus.pending;
      case 'sending':
        return MessageStatus.sending;
      case 'simulated':
        return MessageStatus.simulated;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'failed':
        return MessageStatus.failed;
      case 'skipped':
        return MessageStatus.skipped;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "MessageStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

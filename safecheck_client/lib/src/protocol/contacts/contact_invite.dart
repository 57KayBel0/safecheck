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

/// An invite link for a trusted contact, plus a suggested message the owner
/// can send from their own phone.
abstract class ContactInvite
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ContactInvite._({
    required this.url,
    required this.message,
  });

  factory ContactInvite({
    required String url,
    required String message,
  }) = _ContactInviteImpl;

  factory ContactInvite.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContactInvite(
      url: jsonSerialization['url'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  String url;

  String message;

  /// Returns a shallow copy of this [ContactInvite]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ContactInvite copyWith({
    String? url,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContactInvite',
      'url': url,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ContactInvite',
      'url': url,
      'message': message,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ContactInviteImpl extends ContactInvite {
  _ContactInviteImpl({
    required String url,
    required String message,
  }) : super._(
         url: url,
         message: message,
       );

  /// Returns a shallow copy of this [ContactInvite]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ContactInvite copyWith({
    String? url,
    String? message,
  }) {
    return ContactInvite(
      url: url ?? this.url,
      message: message ?? this.message,
    );
  }
}
